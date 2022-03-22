import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
      const Audio('').widget,
      const Clock('').widget,
    ];

    emit(state.copyWith(
      screens: await _window.getScreenList(),
      availableWidgets: availableWidgets,
      widgets: _settingsCubit.loadWidgets().map((e) => e.widget).toList(),
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
        widgetModel = Audio(newUuid);
        widget = widgetModel.widget;
        break;
      case ClockWidget:
        widgetModel = Clock(newUuid);
        widget = widgetModel.widget;
        break;
      default:
        throw Exception('Unable to add widget, unknown type.');
    }

    final widgets = List<DesktopWidget>.from(state.widgets)..add(widget);
    emit(state.copyWith(widgets: widgets));

    _settingsCubit.saveNewWidget(widgetModel);
  }
}
