import '../desktop_widgets.dart';
import 'audio_widget.dart';

class Audio implements WidgetModel {
  @override
  final String uuid;

  const Audio(this.uuid);

  @override
  DesktopWidget get widget => AudioWidget(widgetModel: this);

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(json['uuid']);
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uuid': uuid,
      'widgetType': runtimeType.toString(),
    };
  }
}
