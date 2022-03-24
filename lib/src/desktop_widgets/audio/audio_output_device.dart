import 'dart:async';

import 'audio_service.dart';

class AudioOutputDevice {
  final AudioService _audioService;
  final String id;
  final String name;
  bool listening = false;

  AudioOutputDevice(
    this._audioService, {
    required this.id,
    required this.name,
  }) {
    _initialize();
  }

  void _initialize() {
    _updateVolume();
    _updateMuteState();

    _audioService.audioUpdates.listen((event) async {
      if (!listening) return;

      _updateVolume();
      _updateMuteState();
    });
  }

  final _volumeStreamController = StreamController<double>();
  Stream<double>? _volumeStream;

  Stream<double> volume() {
    _volumeStream ??= _volumeStreamController.stream.asBroadcastStream();
    return _volumeStream!;
  }

  Future<void> _updateVolume() async {
    _volumeStreamController.add(await _audioService.getVolume(id));
  }

  final _isMutedStreamController = StreamController<bool>();
  Stream<bool>? _isMutedStream;

  Stream<bool> isMuted() {
    _isMutedStream ??= _isMutedStreamController.stream.asBroadcastStream();
    return _isMutedStream!;
  }

  Future<void> _updateMuteState() async {
    _isMutedStreamController.add(await _audioService.getMuteState(id));
  }

  Future<void> toggleMute() async => await _audioService.toggleMute(id);
}
