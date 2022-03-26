import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'audio_output_device.dart';

class AudioService {
  AudioService._() {
    _subscribeToVolume();
  }

  static AudioService? _instance;
  factory AudioService() => _instance ?? AudioService._();

  Future<void> _subscribeToVolume() async {
    final process = await Process.start('bash', [
      '-c',
      'pactl subscribe | grep --line-buffered "sink" | while read -r UNUSED_LINE; do echo volumeChanged; done'
    ]);

    process.stderr.listen((event) {
      debugPrint('Encountered issue listening for audio updates: $event');
    });

    process.stdout.listen((event) => _audioUpdatesController.add(event));
  }

  final _audioUpdatesController = StreamController();
  Stream? _audioUpdatesStream;

  Stream get audioUpdates {
    _audioUpdatesStream ??= _audioUpdatesController.stream.asBroadcastStream();

    return _audioUpdatesStream!;
  }

  List<AudioOutputDevice>? _outputDevices;

  Future<List<AudioOutputDevice>> outputDevices() async {
    if (_outputDevices != null) return Future.value(_outputDevices);

    final result = await Process.run('pactl', ['list', 'sinks']);

    if (result.stderr != '') {
      debugPrint('Error connecting to pactl: ${result.stderr}');
      final restartAudioResult = await Process.run('bash', [
        '-c',
        'systemctl --user restart pipewire pipewire-pulse',
      ]);
      if (restartAudioResult.stderr == '') {
        debugPrint('Successfully restarted audio service.');
      }
    }

    // The raw, multi-line String from `pactl list sinks`, one list item for
    // every sink reported.
    final rawSinks = (result.stdout as String).split(RegExp(r'\n\n'));

    _outputDevices = [];

    for (var sink in rawSinks) {
      // Extract the `node.nick` (human-readable name) property.
      final name = _extractDotValue(sink, 'node.nick');
      final id = _extractDotValue(sink, 'node.name');

      if (name == null || id == null) continue;

      _outputDevices?.add(
        AudioOutputDevice(
          this,
          id: id,
          name: name,
          volume: 0.00,
          isMuted: await getMuteState(id),
        ),
      );
    }

    return Future.value(_outputDevices);
  }

  String? _extractDotValue(String source, String key) {
    return RegExp('(?<=$key = ")(.*)(?=")')
        .allMatches(source)
        .map((e) => e.group(0))
        .first;
  }

  Future<double> getVolume(String id) async {
    final result = await Process.run(
      'bash',
      ['-c', 'pactl  get-sink-volume $id'],
    );
    final output = result.stdout as String;
    final volumeAsString = output.split(' ').firstWhere(
          (element) => element.contains('%'),
        );
    final volumeAsDouble = _volumePercentToDouble(volumeAsString);
    return volumeAsDouble;
  }

  double _volumePercentToDouble(String volumePercent) {
    volumePercent = volumePercent.substring(0, volumePercent.length - 1);
    volumePercent = '0.' + volumePercent;
    final volumeDouble = double.tryParse(volumePercent);
    return volumeDouble ?? 0.00;
  }

  Future<bool> getMuteState(String id) async {
    final result = await Process.run(
      'bash',
      ['-c', 'pactl  get-sink-mute $id'],
    );

    String resultString = result.stdout as String;
    resultString = resultString.split(' ').last.trim();
    return (resultString == 'yes') ? true : false;
  }

  Future<void> toggleMute(String id) async {
    await Process.run(
      'bash',
      ['-c', 'pactl  set-sink-mute $id toggle'],
    );
  }
}
