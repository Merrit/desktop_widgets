import 'package:flutter/material.dart';

import 'desktop_widgets.dart';

class DesktopWidgetContainer extends StatefulWidget {
  final DesktopWidget child;

  const DesktopWidgetContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _DesktopWidgetContainerState createState() => _DesktopWidgetContainerState();
}

class _DesktopWidgetContainerState extends State<DesktopWidgetContainer> {
  Offset position = const Offset(100, 100);

  void updatePosition(Offset newPosition) =>
      setState(() => position = newPosition);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Draggable(
            maxSimultaneousDrags: 1,
            feedback: widget.child,
            childWhenDragging: Opacity(
              opacity: .3,
              child: widget.child,
            ),
            onDragEnd: (details) => updatePosition(details.offset),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
