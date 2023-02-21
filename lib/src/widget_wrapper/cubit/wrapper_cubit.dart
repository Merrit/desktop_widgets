import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../desktop_widgets/desktop_widgets.dart';
import '../../window/app_window.dart';

part 'wrapper_state.dart';

late final WrapperCubit wrapperCubit;

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
    wrapperCubit = this;

    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      if (call.arguments.toString() == "ping") {
        return "pong";
      }

      if (call.method == 'getWidgetInfo') {
        return Future.value(state.widgetModel.toJson());
      }

      if (call.method == 'setWindowPosition') {
        await AppWindow.instance.setWindowSizeAndPosition(state.widgetModel.id);
        return Future.value(null);
      }

      return Future.value();
    });
  }

  void toggleIsLocked() => emit(state.copyWith(isLocked: !state.isLocked));

  void updateIsHovered(bool value) => emit(state.copyWith(isHovered: value));
}
