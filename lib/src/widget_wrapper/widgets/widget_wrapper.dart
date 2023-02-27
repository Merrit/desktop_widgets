import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import '../../desktop_widgets/desktop_widgets.dart';
import '../../window/app_window.dart';
import '../widget_wrapper.dart';

/// A wrapper widget that handles the window management for a widget.
class WidgetWrapper extends StatefulWidget with WindowListener {
  const WidgetWrapper({Key? key}) : super(key: key);

  @override
  State<WidgetWrapper> createState() => _WidgetWrapperState();
}

class _WidgetWrapperState extends State<WidgetWrapper> with WindowListener {
  final focusNode = FocusNode();

  @override
  void onWindowBlur() {
    // When the window loses focus, we want to remove focus from the child
    // widget so that it doesn't continue to receive keyboard events,
    // text fields don't continue to show a flashing cursor, etc.
    focusNode.requestFocus();
    super.onWindowBlur();
  }

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wrapperCubit = context.read<WrapperCubit>();

    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: MouseRegion(
        onEnter: (_) => wrapperCubit.updateIsHovered(true),
        onExit: (_) => wrapperCubit.updateIsHovered(false),
        child: BlocBuilder<WrapperCubit, WrapperState>(
          builder: (context, state) {
            Widget wrappedWidget;
            switch (state.widgetModel.widgetType) {
              case 'ClockWidget':
                wrappedWidget = const NewClockWidget();
                break;
              case 'Notes':
                wrappedWidget = NotesWidget(state.widgetModel);
                break;
              case 'Placeholder':
                wrappedWidget = const PlaceholderWidget();
                break;
              default:
                wrappedWidget = const Placeholder();
            }

            return Focus(
              focusNode: focusNode,
              child: Container(
                color: state.isLocked
                    ? Colors.transparent
                    : Colors.grey.withOpacity(0.2),
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: wrappedWidget,
                      ),
                    ),
                    const _LockMoveControls(),
                    const _ResizeControl(Alignment.topLeft),
                    const _ResizeControl(Alignment.topRight),
                    const _ResizeControl(Alignment.bottomRight),
                    const _ResizeControl(Alignment.bottomLeft),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LockMoveControls extends StatelessWidget {
  const _LockMoveControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wrapperCubit = context.read<WrapperCubit>();

    return Positioned.fill(
      child: Align(
        alignment: Alignment.centerRight,
        child: BlocBuilder<WrapperCubit, WrapperState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: (state.isHovered || !state.isLocked) ? 0.8 : 0,
                  child: GestureDetector(
                    onTap: () => wrapperCubit.toggleIsLocked(),
                    child: Icon(
                      state.isLocked ? Icons.lock : Icons.lock_open,
                    ),
                  ),
                ),
                Visibility(
                  visible: !state.isLocked,
                  maintainAnimation: true,
                  maintainSize: true,
                  maintainState: true,
                  child: Opacity(
                    opacity: 0.8,
                    child: GestureDetector(
                      onTapDown: (details) {
                        if (state.isLocked) return;

                        windowManager.startDragging();
                      },
                      onTapUp: (_) => appWindow
                          .saveWindowSizeAndPosition(state.widgetModel.id),
                      child: const Icon(Icons.drag_indicator),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResizeControl extends StatefulWidget {
  final Alignment alignment;

  const _ResizeControl(
    this.alignment, {
    Key? key,
  }) : super(key: key);

  @override
  State<_ResizeControl> createState() => _ResizeControlState();
}

class _ResizeControlState extends State<_ResizeControl> {
  late final SystemMouseCursor cursor;
  late final ResizeEdge resizeEdge;

  @override
  void initState() {
    if (widget.alignment == Alignment.topLeft) {
      cursor = SystemMouseCursors.resizeUpLeftDownRight;
      resizeEdge = ResizeEdge.topLeft;
    } else if (widget.alignment == Alignment.topRight) {
      cursor = SystemMouseCursors.resizeUpRightDownLeft;
      resizeEdge = ResizeEdge.topRight;
    } else if (widget.alignment == Alignment.bottomRight) {
      cursor = SystemMouseCursors.resizeUpLeftDownRight;
      resizeEdge = ResizeEdge.bottomRight;
    } else if (widget.alignment == Alignment.bottomLeft) {
      cursor = SystemMouseCursors.resizeUpRightDownLeft;
      resizeEdge = ResizeEdge.bottomLeft;
    } else {
      throw Exception('Only corner alignments are supported.');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: widget.alignment,
        child: MouseRegion(
          cursor: cursor,
          child: BlocBuilder<WrapperCubit, WrapperState>(
            builder: (context, state) {
              return Opacity(
                opacity: state.isLocked ? 0 : 0.8,
                child: GestureDetector(
                  onTapDown: (details) async {
                    if (state.isLocked) return;

                    await windowManager.startResizing(resizeEdge);
                    // await appWindow.saveWindowSizeAndPosition();
                  },
                  onTapUp: (_) =>
                      appWindow.saveWindowSizeAndPosition(state.widgetModel.id),
                  child: Transform.scale(
                    scale: 0.8,
                    child: const Icon(Icons.circle),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
