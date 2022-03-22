import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
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
  double _volumeAsDouble = 0.00;
  String _volumeAsPercentage = '';
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    getVolume();
    getMuteState();
    subscribeToVolume();
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
      backgroundColor: Colors.pink.withAlpha(20),
      // backgroundColor: Colors.transparent,
      body: Column(
        children: [
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
        ],
      ),
    );
  }
}
