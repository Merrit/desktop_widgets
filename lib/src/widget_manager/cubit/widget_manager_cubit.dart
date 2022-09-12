import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../desktop_widgets/desktop_widgets.dart';
import '../../storage/storage_service.dart';

part 'widget_manager_state.dart';

late final WidgetManagerCubit widgetManagerCubit;

class WidgetManagerCubit extends Cubit<WidgetManagerState> {
  final StorageService _storageService;

  WidgetManagerCubit(this._storageService)
      : super(const WidgetManagerState(
          runningWidgets: [],
        )) {
    widgetManagerCubit = this;
    initialize();
  }

  Future<void> initialize() async {
    List<DesktopWidgetModel> widgetModels = [];

    // Find widgets for any already open widget windows.
    final List<int> windowIds = await DesktopMultiWindow.getAllSubWindowIds();

    if (windowIds.isNotEmpty) {
      for (var windowId in windowIds) {
        final widgetJson = await DesktopMultiWindow.invokeMethod(
          windowId,
          'getWidgetInfo',
        ) as String;

        widgetModels.add(DesktopWidgetModel.fromJson(widgetJson));
      }
    }

    // Get saved widgets from storage.
    final Iterable savedWidgetsJson = await _storageService //
        .getStorageAreaValues('savedWidgets');

    final List<DesktopWidgetModel> savedWidgetModels = savedWidgetsJson //
        .map((e) => DesktopWidgetModel.fromJson(e))
        .toList();

    for (var widget in widgetModels) {
      // If already running, we don't restore from saved again.
      savedWidgetModels.removeWhere((element) => element.id == widget.id);
    }

    for (var widgetModel in savedWidgetModels) {
      final args = jsonEncode({
        'widgetJson': widgetModel.toJson(),
      });

      final window = await DesktopMultiWindow.createWindow(args);

      widgetModels.add(widgetModel.copyWith(windowId: window.windowId));
    }

    emit(state.copyWith(runningWidgets: widgetModels));
  }

  Future<void> createDesktopWidget(String widgetType) async {
    final id = const Uuid().v4();

    final model = DesktopWidgetModel(
      id: id,
      widgetType: widgetType,
      windowId: 0,
    );

    final args = jsonEncode({
      'widgetJson': model.toJson(),
    });

    final window = await DesktopMultiWindow.createWindow(args);

    _storageService.saveValue(
      key: id,
      value: model.toJson(),
      storageArea: 'savedWidgets',
    );

    emit(state.copyWith(
      runningWidgets: [
        ...state.runningWidgets,
        model.copyWith(windowId: window.windowId),
      ],
    ));
  }

  Future<void> deleteDesktopWidget(DesktopWidgetModel widgetModel) async {
    final window = WindowController.fromWindowId(widgetModel.windowId);
    await window.close();
    await _storageService.deleteValue(
      widgetModel.id,
      storageArea: 'savedWidgets',
    );

    state.runningWidgets.removeWhere((element) => element.id == widgetModel.id);
    emit(state.copyWith(
      runningWidgets: List<DesktopWidgetModel>.from(state.runningWidgets),
    ));
  }
}
