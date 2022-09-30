import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../desktop_widgets/clock/clock_widget.dart';
import '../../desktop_widgets/models/desktop_widget_model.dart';
import '../../desktop_widgets/placeholder/placeholder_widget.dart';
import '../widget_manager.dart';

class WidgetManager extends StatefulWidget {
  const WidgetManager({Key? key}) : super(key: key);

  @override
  State<WidgetManager> createState() => _WidgetManagerState();
}

// Timer? timer;

class _WidgetManagerState extends State<WidgetManager>
    with TrayListener, WindowListener {
  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  // @override
  // void onWindowEvent(String eventName) {
  //   if (eventName == 'move' || eventName == 'resize') {
  //     /// Set a timer between events that trigger saving the window size and
  //     /// location. This is required because there is no notification available
  //     /// for when these events *finish*, and therefore it would be triggered
  //     /// hundreds of times otherwise during a move event.
  //     timer?.cancel();
  //     timer = null;
  //     timer = Timer(
  //       const Duration(seconds: 30),
  //       () {
  //         print('Timer triggered');
  //         appWindow.setWindowSizeAndPosition();
  //       },
  //     );
  //   }
  //   super.onWindowEvent(eventName);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          Flexible(
            child: ListView(
              children: [
                const Text('Available Widgets'),
                const SizedBox(height: 50),
                const Center(child: Text('Clock')),
                InkWell(
                  onTap: () async {
                    widgetManagerCubit.createDesktopWidget('ClockWidget');
                  },
                  child: const NewClockWidget(),
                ),
                const SizedBox(height: 50),
                const Center(child: Text('Placeholder')),
                InkWell(
                  onTap: () async {
                    widgetManagerCubit.createDesktopWidget('Placeholder');
                  },
                  child: const PlaceholderWidget(),
                ),
              ],
            ),
          ),
          const VerticalDivider(),
          Flexible(
            child: Column(
              children: [
                const Text('Running Widgets'),
                Expanded(
                  child: BlocBuilder<WidgetManagerCubit, WidgetManagerState>(
                    builder: (context, state) {
                      return ListView(
                        children: state.runningWidgets
                            .map((DesktopWidgetModel widget) => Card(
                                  child: ListTile(
                                    key: ValueKey(widget),
                                    title: Text(widget.widgetType),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        widgetManagerCubit
                                            .deleteDesktopWidget(widget);
                                        // Not updating when widget removed, so setState.
                                        setState(() {});
                                      },
                                    ),
                                    subtitle: Text('''
                              windowId: ${widget.windowId}'''),
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
