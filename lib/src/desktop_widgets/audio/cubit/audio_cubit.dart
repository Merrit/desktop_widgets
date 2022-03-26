import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../settings/settings_service.dart';
import '../audio_output_device.dart';
import '../audio_service.dart';

part 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  final AudioService _audioService;
  final SettingsService _settingsService;

  AudioCubit(
    this._audioService,
    this._settingsService,
  ) : super(AudioState.initial()) {
    initialize();
  }

  Future<void> initialize() async {
    final outputDevicesList = await _audioService.outputDevices();
    final outputDevices = {
      for (var device in outputDevicesList) //
        device.name: device,
    };

    final savedAudioDeviceId = _settingsService.getString('chosenAudioDevice');
    final chosenDevice = (savedAudioDeviceId != null)
        ? outputDevices[savedAudioDeviceId]
        : outputDevices.values.first;

    emit(state.copyWith(
      outputDevices: outputDevices,
      chosenDevice: chosenDevice,
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

    _settingsService.saveString('chosenAudioDevice', id);
  }
}
