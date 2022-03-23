import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';

import '../../desktop_widgets/audio/audio.dart';
import '../../desktop_widgets/audio/audio_widget.dart';
import '../../desktop_widgets/clock/clock.dart';
import '../../desktop_widgets/clock/clock_widget.dart';
import '../../desktop_widgets/desktop_widgets.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../settings/settings_service.dart';
import '../../window/window.dart';

part 'app_state.dart';

late final AppCubit appCubit;

class AppCubit extends Cubit<AppState> {
  final SettingsCubit _settingsCubit;
  final SettingsService _settingsService;
  final Window _window;

  AppCubit({
    required Window window,
    required SettingsCubit settingsCubit,
    required SettingsService settingsService,
  })  : _settingsCubit = settingsCubit,
        _settingsService = settingsService,
        _window = window,
        super(const AppState.initial()) {
    appCubit = this;
    initialize();
  }

  Future<void> initialize() async {
    final availableWidgets = <DesktopWidget>[
      Audio(uuid: '', position: const Offset(100, 100)).widget,
      Clock(uuid: '', position: const Offset(100, 100)).widget,
    ];

    final savedWidgets = _settingsCubit.loadWidgets();
    // uuid: WidgetModel
    final widgets = {
      for (var widget in savedWidgets) //
        widget.uuid: widget,
    };

    emit(state.copyWith(
      screens: await _window.getScreenList(),
      availableWidgets: availableWidgets,
      widgets: widgets,
    ));
  }

  Future<void> moveToScreen(Screen screen) async {
    await _window.moveToScreen(screen);

    emit(state.copyWith(
      currentAppScreen: await _window.getCurrentScreen(),
    ));

    await _settingsService.saveWindowPosition(screen.visibleFrame);
  }

  Future<void> showSettings([bool shouldShow = true]) async {
    emit(state.copyWith(
      currentAppScreen: await _window.getCurrentScreen(),
      shouldShowSettings: shouldShow,
    ));
  }

  void addingWidgets() {
    emit(state.copyWith(addingWidgets: true));
    emit(state.copyWith(addingWidgets: false));
  }

  void editWidgets() {
    emit(state.copyWith(editing: true));
    emit(state.copyWith(editing: false));
  }

  void addWidget(DesktopWidget widget) {
    WidgetModel widgetModel;

    final newUuid = const Uuid().v4();

    switch (widget.runtimeType) {
      case AudioWidget:
        widgetModel = Audio(uuid: newUuid, position: const Offset(100, 100));
        widget = widgetModel.widget;
        break;
      case ClockWidget:
        widgetModel = Clock(uuid: newUuid, position: const Offset(100, 100));
        widget = widgetModel.widget;
        break;
      default:
        throw Exception('Unable to add widget, unknown type.');
    }

    final widgets = Map<String, WidgetModel>.from(state.widgets);
    widgets[newUuid] = widgetModel;

    emit(state.copyWith(widgets: widgets));

    _settingsCubit.saveWidget(widgetModel);
  }

  void updateWidget(WidgetModel widgetModel) {
    final widgets = Map<String, WidgetModel>.from(state.widgets);
    widgets[widgetModel.uuid] = widgetModel;

    emit(state.copyWith(widgets: widgets));

    _settingsCubit.saveWidget(widgetModel);
  }
}
