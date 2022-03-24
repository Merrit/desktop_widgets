import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../audio_output_device.dart';
import '../audio_service.dart';

part 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  final AudioService _audioService;

  AudioCubit(
    this._audioService,
  ) : super(AudioState.initial()) {
    initialize();
  }

  Future<void> initialize() async {
    final outputDevices = await _audioService.outputDevices();

    emit(state.copyWith(
      outputDevices: {
        for (var device in outputDevices) //
          device.name: device,
      },
      chosenDevice: outputDevices[0],
    ));
  }

  void chooseDevice(String id) {
    emit(state.copyWith(chosenDevice: state.outputDevices[id]));
  }
}
