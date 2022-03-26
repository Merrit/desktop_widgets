import 'dart:async';

import 'package:equatable/equatable.dart';

import 'audio_service.dart';

class AudioOutputDevice extends Equatable {
  final AudioService _audioService;
  final String id;
  final String name;
  final double volume;
  final bool isMuted;

  const AudioOutputDevice(
    this._audioService, {
    required this.id,
    required this.name,
    required this.volume,
    required this.isMuted,
  });

  Future<AudioOutputDevice> update() async {
    return copyWith(
      volume: await _audioService.getVolume(id),
      isMuted: await _audioService.getMuteState(id),
    );
  }

  Future<void> toggleMute() async => await _audioService.toggleMute(id);

  AudioOutputDevice copyWith({
    String? id,
    String? name,
    double? volume,
    bool? isMuted,
  }) {
    return AudioOutputDevice(
      _audioService,
      id: id ?? this.id,
      name: name ?? this.name,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  List<Object> get props {
    return [
      id,
      name,
      volume,
      isMuted,
    ];
  }
}
