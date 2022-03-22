import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../desktop_widgets/audio/audio.dart';
import '../desktop_widgets/clock/clock.dart';
import '../desktop_widgets/desktop_widgets.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  final Box _settingsBox;
  final Box _widgetsBox;

  SettingsService({
    required Box settingsBox,
    required Box widgetsBox,
  })  : _settingsBox = settingsBox,
        _widgetsBox = widgetsBox;

  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async => ThemeMode.system;

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.
  }

  Rect? getSavedWindowPosition() {
    final rectJson = _settingsBox.get('windowPosition');
    if (rectJson == null) return null;

    return RectHelper.fromJson(rectJson);
  }

  Future<void> saveWindowPosition(Rect windowFrame) async {
    await _settingsBox.put('windowPosition', windowFrame.toJson());
  }

  /// [key] should be the widget's uuid.
  Future<void> saveWidget({required String key, required String value}) async {
    await _widgetsBox.put(key, value);
  }

  List<WidgetModel> loadWidgets() {
    final rawWidgets = _widgetsBox.values.cast<String>();
    final widgetMaps = rawWidgets.map<Map<String, dynamic>>(
      (e) => json.decode(e),
    );

    final widgets = <WidgetModel>[];

    for (var json in widgetMaps) {
      switch (json['widgetType']) {
        case 'Audio':
          widgets.add(Audio.fromJson(json));
          break;
        case 'Clock':
          widgets.add(Clock.fromJson(json));
          break;
      }
    }

    return widgets;
  }
}

extension RectHelper on Rect {
  String toJson() => json.encode({
        'left': left,
        'top': top,
        'right': right,
        'bottom': bottom,
      });

  static Rect fromJson(String jsonString) {
    final rectMap = json.decode(jsonString);
    return Rect.fromLTRB(
      rectMap['left'],
      rectMap['top'],
      rectMap['right'],
      rectMap['bottom'],
    );
  }
}
