import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../desktop_widgets.dart';
import 'clock.dart';

class ClockWidget extends StatefulWidget implements DesktopWidget {
  @override
  final Clock widgetModel;

  const ClockWidget({
    Key? key,
    required this.widgetModel,
  }) : super(key: key);

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  @override
  void initState() {
    _getTime();

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime _dateTime = DateTime.now();
  Timer? _timer;

  void _getTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        const Duration(seconds: 1) -
            Duration(milliseconds: _dateTime.millisecond),
        _getTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              DateFormat('h:mm a').format(_dateTime),
              style: TextStyle(
                fontSize: 50,
                color: Colors.grey[300],
              ),
            ),
            Text(
              DateFormat('EEEE, MMMM d').format(_dateTime),
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
