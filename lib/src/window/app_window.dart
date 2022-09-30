// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window;

import '../storage/storage_service.dart';

late final AppWindow appWindow;

class AppWindow {
  final WindowController? _windowController;
  final bool isWidget;

  AppWindow._(this._windowController) : isWidget = (_windowController != null) {
    appWindow = this;
    instance = this;
  }

  static late final AppWindow instance;
  static bool _initialized = false;

  factory AppWindow({WindowController? windowController}) {
    if (_initialized) return instance;

    _initialized = true;
    return AppWindow._(windowController);
  }

  void initializeMainWindow() {
    WindowOptions windowOptions = const WindowOptions();
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
    });
  }

  void initializeWidgetWindow(String widgetId) {
    WindowOptions windowOptions = const WindowOptions(
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      // await windowManager.setMaximizable(false); // Not implemented.
      await windowManager.setAlwaysOnBottom(true);
      await windowManager.setBackgroundColor(Colors.transparent); // Broken
      await windowManager.setMaximumSize(const Size(800, 800));
      await windowManager.setMinimumSize(const Size(110, 110));
      await setWindowSizeAndPosition(widgetId);
      await windowManager.show();
    });
  }

  void close() => exit(0);

  Future<void> resetPosition() async {
    print('Centering widget.');
    Offset position = await windowManager.getPosition();
    print('x: ${position.dx}, y: ${position.dy}');
    await windowManager.center();
    position = await windowManager.getPosition();
    print('Widget has been centered. New position:');
    print('x: ${position.dx}, y: ${position.dy}');
  }

  Future<String> _getScreenConfigId() async {
    final screenList = await window.getScreenList();
    return screenList.map((e) => e.frame.toString()).toList().toString();
  }

  Future<Rect?> getSavedWindowSizeAndPosition(String widgetId) async {
    final savedPosition = await StorageService //
        .instance!
        .getValue(widgetId, storageArea: 'widgetPositions');
    if (savedPosition == null) return null;

    final windowRect = rectFromJson(savedPosition);
    return windowRect;
  }

  Future<void> saveWindowSizeAndPosition(String widgetId) async {
    print('Saving window size and position. id: $widgetId');
    final windowInfo = await window.getWindowInfo();
    Rect bounds = windowInfo.frame;

    // Rect bounds = await windowManager.getBounds();

    // if (isWidget) {
    // bounds = await _windowController.
    // }

    // final screens = await window.getScreenList();
    // screens.first.

    await StorageService.instance!.saveValue(
      key: widgetId,
      value: bounds.toJson(),
      storageArea: 'widgetPositions',
    );
  }

  Future<void> setWindowSizeAndPosition(String widgetId) async {
    print('Setting window size and position for $widgetId');
    // Rect currentWindowFrame = await windowManager.getBounds();
    final windowInfo = await window.getWindowInfo();
    Rect currentWindowFrame = windowInfo.frame;

    Rect? targetWindowFrame = await getSavedWindowSizeAndPosition(widgetId);
    targetWindowFrame ??= const Rect.fromLTWH(0, 0, 300, 180);

    if (targetWindowFrame == currentWindowFrame) {
      print('Target matches current window frame, nothing to do.');
      return;
    }

    assert(targetWindowFrame.size >= const Size(110, 110));

    window.setWindowFrame(targetWindowFrame);
    await _windowController?.setFrame(targetWindowFrame);
  }
}

extension on Rect {
  Map<String, dynamic> toMap() {
    return {
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
    };
  }

  String toJson() => json.encode(toMap());
}

Rect rectFromJson(String source) {
  final Map<String, dynamic> map = json.decode(source);
  return Rect.fromLTRB(
    map['left'],
    map['top'],
    map['right'],
    map['bottom'],
  );
}
