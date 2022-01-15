import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_size/window_size.dart' as window;

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Acrylic.initialize();

  await Hive.initFlutter();
  // await Window.initialize();

  // await Acrylic.setEffect(
  //   effect: WindowEffect.mica,
  //   dark: true,
  // );

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));

  final box = await Hive.openBox('screen');
  final rawMap = box.get('previousRect');
  Map<String, double>? previousRect;
  if (rawMap != null) {
    previousRect = Map<String, double>.from(rawMap);
  }
  showWindow(previousRect);

  // doWhenWindowReady(() {
  //   final box = await Hive.openBox('screen');
  //   final initialSize = Size(600, 450);
  //   appWindow.minSize = initialSize;
  //   appWindow.size = initialSize;
  //   appWindow.alignment = Alignment.center;
  //   appWindow.show();
  // });
}

void showWindow(Map<String, double>? previousRect) {
  if (previousRect != null) {
    final rect = Rect.fromLTRB(
      previousRect['left']!,
      previousRect['top']!,
      previousRect['right']!,
      previousRect['bottom']!,
    );
    window.setWindowFrame(rect);
    window.setWindowMaxSize(rect.size);
    window.setWindowMinSize(rect.size);
  }
  window.setWindowVisibility(visible: true);
}
