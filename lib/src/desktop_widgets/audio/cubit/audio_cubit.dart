import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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

    await _updateChosenDeviceInfo();
    _audioService.audioUpdates.listen((_) => _updateChosenDeviceInfo());
  }

  Future<void> _updateChosenDeviceInfo() async {
    final updatedDevice = await state.chosenDevice?.update();

    if (updatedDevice == null) {
      debugPrint('No device to perform volume update');
      return;
    }

    emit(state.copyWith(chosenDevice: updatedDevice));
  }

  void chooseDevice(String id) {
    emit(state.copyWith(chosenDevice: state.outputDevices[id]));
    _updateChosenDeviceInfo();
  }
}
