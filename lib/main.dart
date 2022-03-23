import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' hide Window;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import 'src/app/app_widget.dart';
import 'src/app/cubit/app_cubit.dart';
import 'src/settings/cubit/settings_cubit.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/window/window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await Acrylic.initialize();
  await Hive.initFlutter();

  final settingsBox = await Hive.openBox('settings');
  final widgetsBox = await Hive.openBox('widgets');
  final settingsService = SettingsService(
    settingsBox: settingsBox,
    widgetsBox: widgetsBox,
  );
  final settingsController = SettingsController(settingsService);
  await settingsController.loadSettings();
  final _settingsCubit = SettingsCubit(settingsService);

  final _windowManager = WindowManager.instance;
  final window = Window(windowManager: _windowManager);

  final _appCubit = AppCubit(
    settingsCubit: _settingsCubit,
    settingsService: settingsService,
    window: window,
  );

  await initSystemTray(window);

  _windowManager.waitUntilReadyToShow().then((_) async {
    await _windowManager.setTitleBarStyle('hidden');
    final windowPosition = settingsService.getSavedWindowPosition() ??
        const Rect.fromLTWH(0, 0, 800, 600);
    await _windowManager.setBounds(windowPosition);
    await _windowManager.setMinimizable(false);
    await _windowManager.setClosable(false);
    await _windowManager.setMovable(false);
    await _windowManager.setResizable(false);
    await _windowManager.setSkipTaskbar(false);
    await _windowManager.maximize();
    await _windowManager.show();
  });

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _appCubit),
        BlocProvider.value(value: _settingsCubit),
      ],
      child: AppWidget(settingsController: settingsController),
    ),
  );
}

Future<void> initSystemTray(Window window) async {
  String path = (Platform.isWindows) //
      ? 'assets/app_icon.ico'
      : 'assets/app_icon.png';

  final menu = [
    MenuItem(label: 'Add Widgets', onClicked: appCubit.addingWidgets),
    MenuItem(label: 'Edit Widgets', onClicked: appCubit.toggleEditWidgets),
    MenuItem(label: 'Settings', onClicked: appCubit.showSettings),
    MenuItem(label: 'Exit', onClicked: window.close),
  ];

  final _systemTray = SystemTray();

  // We first init the systray menu and then add the menu entries
  await _systemTray.initSystemTray(
    title: "Desktop Widgets",
    iconPath: path,
  );

  await _systemTray.setContextMenu(menu);

  // handle system tray event
  _systemTray.registerSystemTrayEventHandler((eventName) {
    debugPrint("eventName: $eventName");

    switch (eventName) {
      case 'leftMouseDown':
        break;
      case 'leftMouseUp':
        _systemTray.popUpContextMenu();
        break;
      case 'rightMouseDown':
        break;
      case 'rightMouseUp':
        window.show();
        break;
    }
  });
}
