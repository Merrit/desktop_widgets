import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                child,
                BlocBuilder<AppCubit, AppState>(
                  builder: (context, state) {
                    return (state.editing)
                        ? Positioned(
                            top: -20,
                            right: -10,
                            child: SizedBox(
                              width: 30,
                              child: FloatingActionButton(
                                onPressed: () {
                                  appCubit.removeWidget(child.widgetModel);
                                },
                                backgroundColor: Colors.red.shade400,
                                child: const Icon(Icons.close),
                              ),
                            ),
                          )
                        : const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
