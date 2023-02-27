import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../desktop_widgets/desktop_widgets.dart';
import '../../logs/logging_manager.dart';
import '../../window/app_window.dart';

part 'wrapper_state.dart';

class WrapperCubit extends Cubit<WrapperState> {
  // ignored until we figure out how to handle this
  // ignore: unused_field
  final WindowController _windowController;

  WrapperCubit({
    required DesktopWidgetModel widgetModel,
    required WindowController windowController,
  })  : _windowController = windowController,
        super(WrapperState(
          isHovered: false,
          isLocked: true,
          widgetModel: widgetModel,
        )) {
    log.v(
        'Created WrapperCubit. WidgetId: ${state.widgetModel.id}, WindowId: ${_windowController.windowId}');
    init();
  }

  Future<void> init() async {
    DesktopMultiWindow.setMethodHandler(_handleMethodCalls);
    await AppWindow.instance.setWidgetWindowSizeAndPosition(
      widgetId: state.widgetModel.id,
      windowController: _windowController,
    );
  }

  /// Method handler for DesktopMultiWindow seems unreliable.
  Future<dynamic> _handleMethodCalls(MethodCall call, int fromWindowId) async {
    if (call.arguments.toString() == "ping") {
      return "pong";
    }

    if (call.method == 'getWidgetInfo') {
      return Future.value(state.widgetModel.toJson());
    }

    if (call.method == 'setWindowPosition') {
      // await AppWindow.instance.setWidgetWindowSizeAndPosition(
      //   widgetId: state.widgetModel.id,
      //   windowController: _windowController,
      // );

      // return Future.value(null);
    }

    return Future.value();
  }

  void toggleIsLocked() => emit(state.copyWith(isLocked: !state.isLocked));

  void updateIsHovered(bool value) => emit(state.copyWith(isHovered: value));
}
