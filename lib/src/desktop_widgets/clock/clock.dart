import '../desktop_widgets.dart';
import 'clock_widget.dart';

class Clock implements WidgetModel {
  @override
  final String uuid;

  const Clock(
    this.uuid,
  );

  @override
  DesktopWidget get widget => ClockWidget(widgetModel: this);

  factory Clock.fromJson(Map<String, dynamic> json) {
    return Clock(json['uuid']);
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uuid': uuid,
      'widgetType': runtimeType.toString(),
      // 'widgetType': widgetType.toString(),
    };
  }
}
