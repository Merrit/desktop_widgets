import 'dart:convert';

import 'package:equatable/equatable.dart';

class DesktopWidgetModel extends Equatable {
  final String id;
  final String widgetType;
  final int windowId;

  const DesktopWidgetModel({
    required this.id,
    required this.widgetType,
    required this.windowId,
  });

  @override
  List<Object> get props => [id, widgetType, windowId];

  DesktopWidgetModel copyWith({
    String? id,
    String? widgetType,
    int? windowId,
  }) {
    return DesktopWidgetModel(
      id: id ?? this.id,
      widgetType: widgetType ?? this.widgetType,
      windowId: windowId ?? this.windowId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'widgetType': widgetType,
      'windowId': windowId,
    };
  }

  factory DesktopWidgetModel.fromMap(Map<String, dynamic> map) {
    return DesktopWidgetModel(
      id: map['id'] ?? '',
      widgetType: map['widgetType'] ?? '',
      windowId: map['windowId']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DesktopWidgetModel.fromJson(String source) =>
      DesktopWidgetModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'DesktopWidgetModel(id: $id, widgetType: $widgetType, windowId: $windowId)';
}
