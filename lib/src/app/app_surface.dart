import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../desktop_widgets/desktop_widget_container.dart';
import '../window/window.dart';
import 'cubit/app_cubit.dart';

class AppSurface extends StatelessWidget {
  static const routeName = 'app_surface';

  const AppSurface({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listener: (context, state) async {
        if (state.addingWidgets) {
          await showDialog(
              context: context,
              builder: (context) {
                return const AddWidgetsDialog();
              });
        }

        if (state.shouldShowSettings) {
          await showDialog(
              context: context,
              builder: (context) {
                return const SettingsDialog();
              });
        }
      },
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return Stack(
            children: [
              (state.editing)
                  ? Positioned.fill(
                      child: GridPaper(
                        subdivisions: 1,
                        color: const Color(0x7FC3E8F3).withOpacity(0.2),
                      ),
                    )
                  : const SizedBox(),
              for (var widget in state.widgets.values)
                DesktopWidgetContainer(child: widget.widget),
              (state.editing) ? const FinishEditingDialog() : const SizedBox(),
            ],
          );
        },
      ),
    );
  }
}

class FinishEditingDialog extends StatefulWidget {
  const FinishEditingDialog({Key? key}) : super(key: key);

  @override
  State<FinishEditingDialog> createState() => _FinishEditingDialogState();
}

class _FinishEditingDialogState extends State<FinishEditingDialog> {
  Offset position = const Offset(300, 300);

  Widget? child;

  @override
  Widget build(BuildContext context) {
    child = Card(
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade900,
            height: 40,
            width: 200,
            child: const Center(
                child: Text(
              'Edit Mode',
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: () {
                appCubit.toggleEditWidgets();
                // Navigator.pushReplacementNamed(context, AppSurface.routeName);
              },
              child: const Text('Exit edit mode'),
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Draggable(
            feedback: child!,
            childWhenDragging: const SizedBox(),
            onDragEnd: (details) => setState(() => position = details.offset),
            child: child!,
          ),
        ),
      ],
    );
  }
}

class AddWidgetsDialog extends StatelessWidget {
  const AddWidgetsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final availableWidgets = appCubit.state.availableWidgets;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Add Widgets'),
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppSurface.routeName);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: availableWidgets.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: InkWell(
                onTap: () {
                  appCubit.addWidget(availableWidgets[index]);
                  Navigator.pushReplacementNamed(context, AppSurface.routeName);
                },
                child: availableWidgets[index],
              ),
            );
          },
        ),
      ),
    );
  }
}

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              const Text('Display on screen:'),
              BlocBuilder<AppCubit, AppState>(
                builder: (context, state) {
                  final screens = state.screens;

                  return SizedBox(
                    width: 150,
                    child: DropdownButtonFormField<Screen>(
                      isExpanded: true,
                      isDense: false,
                      itemHeight: 80,
                      value: state.currentAppScreen,
                      items: [
                        for (var i = 0; i < screens.length; i++)
                          _screenDropdownItem(index: i, screen: screens[i]),
                      ],
                      onChanged: (Screen? screen) async {
                        if (screen == null) return;

                        await appCubit.moveToScreen(screen);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  _screenDropdownItem({required int index, required Screen screen}) {
    final frame = screen.frame;

    return DropdownMenuItem(
      value: screen,
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Screen $index',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  height: 2.0,
                ),
              ),
              TextSpan(
                text: '\n${frame.width.toInt()}x${frame.height.toInt()}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
