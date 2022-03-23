import 'package:flutter/widgets.dart';

abstract class WidgetModel {
  final String uuid;
  Offset position;

  WidgetModel({
    required this.uuid,
    required this.position,
  });

  DesktopWidget get widget;

  Map<String, dynamic> toJson();
}

abstract class DesktopWidget extends Widget {
  final WidgetModel widgetModel;

  const DesktopWidget({
    Key? key,
    required this.widgetModel,
  }) : super(key: key);
}
