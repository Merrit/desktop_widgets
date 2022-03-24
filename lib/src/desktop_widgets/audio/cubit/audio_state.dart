part of 'audio_cubit.dart';

class AudioState extends Equatable {
  final bool muted;
  final Map<String, AudioOutputDevice> outputDevices;
  final AudioOutputDevice? chosenDevice;

  /// Volume percent. Example: 0.35 = 35%
  final double volume;

  const AudioState({
    required this.muted,
    required this.outputDevices,
    this.chosenDevice,
    required this.volume,
  });

  factory AudioState.initial() {
    return const AudioState(
      muted: false,
      outputDevices: {},
      volume: 0.50,
    );
  }

  @override
  List<Object?> get props => [muted, outputDevices, chosenDevice, volume];

  AudioState copyWith({
    bool? muted,
    Map<String, AudioOutputDevice>? outputDevices,
    AudioOutputDevice? chosenDevice,
    double? volume,
  }) {
    return AudioState(
      muted: muted ?? this.muted,
      outputDevices: outputDevices ?? this.outputDevices,
      chosenDevice: chosenDevice ?? this.chosenDevice,
      volume: volume ?? this.volume,
    );
  }
}
