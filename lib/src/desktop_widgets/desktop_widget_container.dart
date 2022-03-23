import 'package:flutter/material.dart';

import '../app/cubit/app_cubit.dart';
import 'desktop_widgets.dart';

class DesktopWidgetContainer extends StatelessWidget {
  final DesktopWidget child;

  const DesktopWidgetContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: child.widgetModel.position.dx,
          top: child.widgetModel.position.dy,
          child: Draggable(
            maxSimultaneousDrags: 1,
            feedback: child,
            childWhenDragging: const SizedBox(),
            onDragEnd: (details) {
              child.widgetModel.position = details.offset;
              appCubit.updateWidget(child.widgetModel);
            },
            child: child,
          ),
        ),
      ],
    );
  }
}
