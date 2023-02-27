// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window;

import '../logs/logs.dart';
import '../storage/storage_service.dart';

late final AppWindow appWindow;

class AppWindow {
  // ignored until we figure out how to handle this
  // ignore: unused_field
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

  Future<void> initializeWidgetWindow(String widgetId) async {
    WindowOptions windowOptions = const WindowOptions(
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setAsFrameless();
      await windowManager.setAlwaysOnBottom(true);
      // Transparent background color is broken in sub-windows.
      // https://github.com/leanflutter/window_manager/issues/179
      await windowManager.setBackgroundColor(Colors.transparent);
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
    final largestScreenRect = _getLargestScreenRect(screenList);
    return largestScreenRect.toJson();
  }

  /// Converts a list of [window.Screen] objects into a [Rect] with the largest values.
  Rect _getLargestScreenRect(List<window.Screen> screens) {
    double left = 0.0;
    double top = 0.0;
    double right = 0.0;
    double bottom = 0.0;

    for (final screen in screens) {
      final frame = screen.frame;
      right = frame.right > right ? frame.right : right;
      bottom = frame.bottom > bottom ? frame.bottom : bottom;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Future<PositionInfo?> getSavedWindowSizeAndPosition(String widgetId) async {
    final String? positionInfoString = await StorageService //
        .instance
        .getValue(widgetId, storageArea: 'widgetPositions');
    if (positionInfoString == null) return null;

    final PositionInfo positionInfo = PositionInfo.fromJson(positionInfoString);
    return positionInfo;
  }

  Future<void> saveWindowSizeAndPosition(String widgetId) async {
    print('Saving window size and position. id: $widgetId');

    final screens = await window.getScreenList();
    print(screens.map((e) => e.frame.toJson()).toList());

    final windowInfo = await window.getWindowInfo();
    Rect bounds = windowInfo.frame;

    final positionInfo = PositionInfo(
      bounds: bounds,
      screenConfigId: await _getScreenConfigId(),
    );

    await StorageService.instance.saveValue(
      key: widgetId,
      value: positionInfo.toJson(),
      storageArea: 'widgetPositions',
    );
  }

  Future<void> setWidgetWindowSizeAndPosition({
    required String widgetId,
    required WindowController windowController,
  }) async {
    log.v('''
widgetId: $widgetId
windowId: ${windowController.windowId}
Setting window size and position''');

    final currentWindowFrame = await windowManager.getBounds();
    final savedPositionInfo = await getSavedWindowSizeAndPosition(widgetId);
    final currentScreenConfigId = await _getScreenConfigId();

    Rect? targetWindowFrame;
    if (savedPositionInfo != null &&
        savedPositionInfo.screenConfigId == currentScreenConfigId) {
      targetWindowFrame = savedPositionInfo.bounds;
    } else {
      targetWindowFrame = const Rect.fromLTWH(0, 0, 300, 180);
    }

    if (targetWindowFrame == currentWindowFrame) {
      log.v('''
widgetId: $widgetId
windowId: ${windowController.windowId}
Target matches current window frame, nothing to do.''');
      return;
    }

    assert(targetWindowFrame.size >= const Size(110, 110));

    await windowManager.setBounds(targetWindowFrame);
    Rect newBounds = await windowManager.getBounds();

    if (newBounds != targetWindowFrame) {
      // Adjust the target window frame to account for the title bar.
      targetWindowFrame = _adjustTargetWindowFrameForTitleBar(
        targetWindowFrame: targetWindowFrame,
        newBounds: newBounds,
      );

      await windowController.setFrame(targetWindowFrame);
      newBounds = await windowManager.getBounds();
    }

    log.v('''
widgetId: $widgetId
windowId: ${windowController.windowId}
currentWindowFrame: ${currentWindowFrame.toDebugString()}
savedPositionInfo: ${savedPositionInfo?.bounds.toDebugString()}
targetWindowFrame: ${targetWindowFrame.toDebugString()}
newBounds: ${newBounds.toDebugString()}''');

    await windowManager.show();
  }

  /// Adjust the widget window frame to account for the title bar.
  ///
  /// This is a workaround for the fact that sometimes requesting to set a
  /// window frame to a specific size will result in a slightly different size
  /// being set because we are hiding the window decorations.
  Rect _adjustTargetWindowFrameForTitleBar({
    required Rect targetWindowFrame,
    required Rect newBounds,
  }) {
    final max = (targetWindowFrame.top > newBounds.top)
        ? targetWindowFrame.top
        : newBounds.top;

    final min = (targetWindowFrame.top < newBounds.top)
        ? targetWindowFrame.top
        : newBounds.top;

    final topDiff = max - min;
    if (topDiff.abs() > 50) {
      return targetWindowFrame;
    }

    return Rect.fromLTWH(
      targetWindowFrame.left,
      targetWindowFrame.top + topDiff,
      targetWindowFrame.width,
      targetWindowFrame.height,
    );
  }
}

class PositionInfo {
  final Rect bounds;
  final String screenConfigId;

  PositionInfo({
    required this.bounds,
    required this.screenConfigId,
  });

  Map<String, dynamic> toMap() {
    return {
      'bounds': bounds.toJson(),
      'screenConfigId': screenConfigId,
    };
  }

  String toJson() => json.encode(toMap());

  factory PositionInfo.fromJson(String source) =>
      PositionInfo.fromMap(json.decode(source));

  factory PositionInfo.fromMap(Map<String, dynamic> map) {
    return PositionInfo(
      bounds: rectFromJson(map['bounds']),
      screenConfigId: map['screenConfigId'],
    );
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

  /// toString that shows the width and height of the rect.
  String toDebugString() {
    return 'left: $left, top: $top, width: $width, height: $height';
  }
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
