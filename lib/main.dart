import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'src/app.dart';
import 'src/desktop_widgets/desktop_widgets.dart';
import 'src/logs/logs.dart';
import 'src/storage/storage_service.dart';
import 'src/system_tray/system_tray_manager.dart';
import 'src/widget_manager/cubit/cubit.dart';
import 'src/widget_wrapper/widget_wrapper.dart';
import 'src/window/app_window.dart';
import 'src/window/multi_window_service.dart';

late final StorageService storageService;

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handle platform errors not caught by Flutter.
  PlatformDispatcher.instance.onError = (error, stack) {
    log.e('Uncaught platform error', error, stack);
    return true;
  };

  storageService = await StorageService.initialize();
  await LoggingManager.initialize(verbose: true);

  await windowManager.ensureInitialized();

  final isMainProcess = args.firstOrNull != 'multi_window';

  if (isMainProcess) {
    initializeMainProcess();
  } else {
    initializeWidgetProcess(args);
  }
}

Future<void> initializeMainProcess() async {
  log.i('Initializing main process.');
  final appWindow = AppWindow();
  final systemTray = SystemTrayManager(appWindow);
  await systemTray.initialize();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => WidgetManagerCubit(
          MultiWindowService(),
          storageService,
        ),
      ),
    ],
    child: const AppWidget(isMainProcess: true),
  ));

  appWindow.initializeMainWindow();
}

Future<void> initializeWidgetProcess(List<String> args) async {
  final int windowId = int.parse(args[1]);
  log.v('''
Initializing widget process.
windowId: $windowId''');

  final Map<String, dynamic> customArgs = (args[2].isEmpty)
      ? const {}
      : jsonDecode(args[2]) as Map<String, dynamic>;

  final widgetModel = DesktopWidgetModel.fromJson(customArgs['widgetJson']);
  final windowController = WindowController.fromWindowId(windowId);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WrapperCubit(
            widgetModel: widgetModel.copyWith(
              windowId: windowController.windowId,
            ),
            // widgetType: customArgs['widget'],
            windowController: windowController,
          ),
        ),
      ],
      child: const AppWidget(isMainProcess: false),
    ),
  );

  final appWindow = AppWindow(windowController: windowController);
  await appWindow.initializeWidgetWindow(widgetModel.id);
}

class TempCubit extends Cubit<int> {
  TempCubit() : super(5);
}
