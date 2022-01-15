import 'dart:async';
import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_size/window_size.dart' as window;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'sample_item.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatefulWidget {
  const SampleItemListView({
    Key? key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
  }) : super(key: key);

  static const routeName = '/';

  final List<SampleItem> items;

  @override
  State<SampleItemListView> createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  String _time = 'time!';
  String _date = 'date!';
  double _volumeAsDouble = 0.00;
  String _volumeAsPercentage = '';
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    // setWindowEffect(effect);
    _getTime();
    getVolume();
    getMuteState();
    subscribeToVolume();
    Timer.periodic(Duration(seconds: 10), (_) {
      _getTime();
    });
  }

  void _getTime() {
    final dateTime = DateTime.now();
    // MM/dd/yyyy
    final formattedTime = DateFormat('h:mm a').format(dateTime);
    final formattedDate = DateFormat('EEEE, MMMM d').format(dateTime);
    setState(() {
      _time = formattedTime;
      _date = formattedDate;
    });
  }

  Future<String> getSinks() async {
    final sinkName = await Process.run(
      'bash',
      ['-c', 'pactl list short sinks'],
    );
    print('stdout: ${sinkName.stdout}');
    print('stderr: ${sinkName.stderr}');
    return sinkName.stdout as String;
  }

  double _volumePercentToDouble(String volumePercent) {
    volumePercent = volumePercent.substring(0, volumePercent.length - 1);
    volumePercent = '0.' + volumePercent;
    final volumeDouble = double.tryParse(volumePercent);
    return volumeDouble ?? 0.00;
  }

  final speakersSink = 'alsa_output.pci-0000_2d_00.4.analog-stereo';

  Future<String> getVolume() async {
    final result = await Process.run(
      'bash',
      ['-c', 'pactl  get-sink-volume $speakersSink'],
    );
    final output = result.stdout as String;
    final volumeAsString = output.split(' ').firstWhere(
          (element) => element.contains('%'),
        );
    final volumeAsDouble = _volumePercentToDouble(volumeAsString);
    setState(() {
      _volumeAsDouble = volumeAsDouble;
      _volumeAsPercentage = volumeAsString;
    });
    return volumeAsString;
  }

  Future<void> getMuteState() async {
    final result = await Process.run(
      'bash',
      ['-c', 'pactl  get-sink-mute $speakersSink'],
    );
    String resultString = result.stdout as String;
    resultString = resultString.split(' ').last.trim();
    setState(() => _muted = (resultString == 'yes') ? true : false);
  }

  Future<void> subscribeToVolume() async {
    final process = await Process.start(
      'bash',
      [
        '-c',
        'pactl subscribe | grep --line-buffered "sink" | while read -r UNUSED_LINE; do echo volumeChanged; done'
      ],
    );
    stderr.addStream(process.stderr);
    process.stdout.listen((event) {
      getVolume();
      getMuteState();
    });
  }

  Widget _volumeIcon() {
    final icon = (_muted) ? Icons.volume_off : Icons.volume_up;
    final color = (_muted) ? Colors.grey : null;
    return Icon(
      icon,
      color: color,
    );
  }

  AcrylicEffect effect = AcrylicEffect.transparent;
  Color color =
      Platform.isWindows ? Colors.white.withOpacity(0.2) : Colors.transparent;

  void setWindowEffect(AcrylicEffect? value) {
    Acrylic.setEffect(effect: value!, gradientColor: color);
    setState(() => effect = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Card(
            child: Container(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    _time,
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.grey[300],
                    ),
                  ),
                  Text(
                    _date,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Container(
              // width: 300,
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _volumeIcon(),
                  LinearPercentIndicator(
                    width: 130,
                    progressColor: Colors.blue,
                    percent: _volumeAsDouble,
                  ),
                  Text(
                    _volumeAsPercentage,
                  ),
                ],
              ),
            ),
          ),
          // IconButton(
          //   onPressed: () async {
          //     // appWindow.maximize();
          //     // setWindowEffect(AcrylicEffect.transparent);
          //     // final result = await window.();
          //     // print(result);
          //     print('hi');
          //   },
          //   icon: Icon(Icons.hot_tub),
          // ),
          // IconButton(
          //   onPressed: () async {
          //     final currentScreen = await window.getCurrentScreen();
          //     if (currentScreen == null) return;
          //     final screenFrame = currentScreen.visibleFrame;
          //     window.setWindowFrame(screenFrame);
          //     final box = await Hive.openBox('screen');
          //     await box.put(
          //       'previousRect',
          //       {
          //         'left': screenFrame.left,
          //         'top': screenFrame.top,
          //         'right': screenFrame.right,
          //         'bottom': screenFrame.bottom,
          //       },
          //     );
          //     // currentScreen.visibleFrame.
          //     // window.set
          //     // currentScreen.visibleFrame
          //     var end;
          //   },
          //   icon: Icon(Icons.close),
          // ),
        ],
      ),
    );
  }
}
