import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../desktop_widgets/desktop_widgets.dart';

part 'wrapper_state.dart';

late final WrapperCubit wrapperCubit;

class WrapperCubit extends Cubit<WrapperState> {
  final WindowController _windowController;

  WrapperCubit({
    required DesktopWidgetModel widgetModel,
    // required String widgetType,
    required WindowController windowController,
  })  : _windowController = windowController,
        super(WrapperState(
          isHovered: false,
          isLocked: false,
          widgetModel: widgetModel,
          // widgetType: widgetType,
        )) {
    wrapperCubit = this;

    DesktopMultiWindow.setMethodHandler((call, fromWindowId) {
      if (call.method == 'getWidgetInfo') {
        return Future.value(state.widgetModel.toJson());
      }

      return Future.value();
    });
  }

  void toggleIsLocked() => emit(state.copyWith(isLocked: !state.isLocked));

  void updateIsHovered(bool value) => emit(state.copyWith(isHovered: value));
}
