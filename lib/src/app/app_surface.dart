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
        buildWhen: (previous, current) => previous.widgets != current.widgets,
        builder: (context, state) {
          return Stack(
            children: [
              (state.editing)
                  ? const Positioned.fill(child: GridPaper(subdivisions: 2))
                  : const SizedBox(),
              for (var widget in state.widgets.values)
                DesktopWidgetContainer(child: widget.widget),
            ],
          );
        },
      ),
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
