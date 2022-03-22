import 'package:flutter/widgets.dart';

abstract class WidgetModel {
  final String uuid;

  const WidgetModel(
    this.uuid,
  );

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
