import 'dart:io';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;

/// Wrapper for the `window_size` plugin, since it has no class.
///
/// This is cleaner *and* it will allow passing a mock for tests.
class Window {
  final WindowManager _windowManager;

  static Window? _instance;

  const Window._({
    required WindowManager windowManager,
  }) : _windowManager = windowManager;

  factory Window({required WindowManager windowManager}) {
    return (_instance != null)
        ? _instance!
        : Window._(windowManager: windowManager);
  }

  Future<List<Screen>> getScreenList() async {
    final screens = await window_size.getScreenList();
    return screens
        .map((screen) => Screen(
              screen.frame,
              screen.visibleFrame,
              screen.scaleFactor,
            ))
        // Use toSet() because if a user is mirroring a display it will show
        // up here as a duplicate, which we want to ignore.
        .toSet()
        .toList();
  }

  Future<Screen?> getCurrentScreen() async {
    final currentScreen = await window_size.getCurrentScreen();
    if (currentScreen == null) return null;

    return Screen(
      currentScreen.frame,
      currentScreen.visibleFrame,
      currentScreen.scaleFactor,
    );
  }

  Future<void> moveToScreen(Screen screen) async {
    window_size.setWindowVisibility(visible: false);
    final frame = screen.visibleFrame;

    window_size.setWindowFrame(screen.visibleFrame);

    final windowInfo = await getWindowInfo();
    if (windowInfo != screen.visibleFrame) {
      debugPrint('''
Failed to move window properly!

Window:

$windowInfo

Intended target:

$frame''');
    }

    window_size.setWindowVisibility(visible: true);
  }

  void hide() => window_size.setWindowVisibility(visible: false);

  void show() => window_size.setWindowVisibility(visible: true);

  Future<Rect> getWindowInfo() async {
    final window = await window_size.getWindowInfo();
    return window.frame;
  }

  void close() => exit(0);
}

class Screen extends Equatable implements window_size.Screen {
  const Screen(this.frame, this.visibleFrame, this.scaleFactor);

  /// The frame of the screen, in screen coordinates.
  @override
  final Rect frame;

  /// The portion of the screen's frame that is available for use by application
  /// windows. E.g., on macOS, this excludes the menu bar.
  @override
  final Rect visibleFrame;

  /// The number of pixels per screen coordinate for this screen.
  @override
  final double scaleFactor;

  @override
  List<Object> get props => [frame, visibleFrame, scaleFactor];
}

// final box = await Hive.openBox('screen');
// final rawMap = box.get('previousRect');
// Map<String, double>? previousRect;
// if (rawMap != null) {
//   previousRect = Map<String, double>.from(rawMap);
// }
// await showWindow(previousRect);

Future<void> showWindow(Map<String, double>? previousRect) async {
  // if (previousRect != null) {
  //   final rect = Rect.fromLTRB(
  //     previousRect['left']!,
  //     previousRect['top']!,
  //     previousRect['right']!,
  //     previousRect['bottom']!,
  //   );

  //   window.setWindowFrame(rect);
  //   window.setWindowMaxSize(rect.size);
  //   window.setWindowMinSize(rect.size);
  // }

  // Rect allRect;

  // for (var screen in screens) {
  //   screen.frame.
  // }

  window_size.setWindowVisibility(visible: true);
}
