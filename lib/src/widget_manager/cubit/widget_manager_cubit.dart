import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../desktop_widgets/desktop_widgets.dart';
import '../../storage/storage_service.dart';
import '../../window/multi_window_service.dart';

part 'widget_manager_state.dart';

late final WidgetManagerCubit widgetManagerCubit;

class WidgetManagerCubit extends Cubit<WidgetManagerState> {
  final MultiWindowService _multiWindowService;
  final StorageService _storageService;

  WidgetManagerCubit(this._multiWindowService, this._storageService)
      : super(const WidgetManagerState(
          runningWidgets: [],
        )) {
    widgetManagerCubit = this;
    initialize();
  }

  Future<void> initialize() async {
    List<DesktopWidgetModel> widgetModels = [];

    // Find widgets for any already open widget windows.
    final List<int> windowIds = await _multiWindowService.getSubWindowIds();

    if (windowIds.isNotEmpty) {
      for (var windowId in windowIds) {
        final widgetJson = await _multiWindowService.invokeMethod(
          targetWindowId: windowId,
          method: 'getWidgetInfo',
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

      final window = await _multiWindowService.createWindow(arguments: args);

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

    final window = await _multiWindowService.createWindow(arguments: args);

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

  Future<void> removeDesktopWidget(DesktopWidgetModel widgetModel) async {
    final window = _multiWindowService.getWindowController(
      widgetModel.windowId,
    );
    await window.close();
    await _storageService.deleteValue(
      widgetModel.id,
      storageArea: 'savedWidgets',
    );

    // Delete any saved values for this widget.
    await _storageService.deleteStorageAreaValues(widgetModel.id);

    state.runningWidgets.removeWhere((element) => element.id == widgetModel.id);
    emit(state.copyWith(
      runningWidgets: [...state.runningWidgets],
    ));
  }
}
