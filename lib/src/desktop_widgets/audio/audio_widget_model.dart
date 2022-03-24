import 'dart:ui';

import '../desktop_widgets.dart';
import 'audio_widget.dart';

class AudioWidgetModel implements WidgetModel {
  @override
  final String uuid;

  @override
  Offset position;

  AudioWidgetModel({
    required this.uuid,
    required this.position,
  });

  @override
  DesktopWidget get widget => AudioWidget(widgetModel: this);

  factory AudioWidgetModel.fromJson(Map<String, dynamic> json) {
    final positionMap = json['position'] as Map<String, dynamic>?;
    final position = (positionMap == null)
        ? const Offset(100, 100)
        : Offset(positionMap['dx']!, positionMap['dy']!);

    return AudioWidgetModel(
      uuid: json['uuid'] ?? '',
      position: position,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uuid': uuid,
      'position': {'dx': position.dx, 'dy': position.dy},
      'widgetType': runtimeType.toString(),
    };
  }
}
