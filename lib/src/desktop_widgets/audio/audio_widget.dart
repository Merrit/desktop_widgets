import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../settings/cubit/settings_cubit.dart';
import '../desktop_widgets.dart';
import 'audio_service.dart';
import 'audio_widget_model.dart';
import 'cubit/audio_cubit.dart';

class AudioWidget extends StatelessWidget implements DesktopWidget {
  @override
  final AudioWidgetModel widgetModel;

  const AudioWidget({
    Key? key,
    required this.widgetModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioCubit(
        AudioService(),
        context.read<SettingsCubit>().settingsService,
      ),
      child: Card(
        child: BlocBuilder<AudioCubit, AudioState>(
          builder: (context, state) {
            final audioDevice = state.chosenDevice;

            if (audioDevice == null) return const SizedBox();

            final volumeDouble = audioDevice.volume;
            final volumePercent = (volumeDouble * 100).toInt();

            final dropdownFocusNode = FocusNode();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const VolumeIcon(),
                      LinearPercentIndicator(
                        width: 130,
                        progressColor: Colors.blue,
                        percent: volumeDouble,
                      ),
                      Text('$volumePercent%'),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: DropdownButton<String>(
                    value: state.chosenDevice?.name,
                    selectedItemBuilder: (context) {
                      return state.outputDevices.keys
                          .map((deviceName) => Container(
                                alignment: Alignment.center,
                                width: 180,
                                child: Text(
                                  deviceName,
                                  textAlign: TextAlign.end,
                                ),
                              ))
                          .toList();
                    },
                    items: state.outputDevices.keys.map((deviceName) {
                      return DropdownMenuItem<String>(
                        value: deviceName,
                        child: Center(child: Text(deviceName)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      context.read<AudioCubit>().chooseDevice(value!);
                      dropdownFocusNode.unfocus();
                    },
                    focusNode: dropdownFocusNode,
                    underline: const SizedBox(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class VolumeIcon extends StatelessWidget {
  const VolumeIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, state) {
        final isMuted = state.chosenDevice?.isMuted ?? false;

        final icon = (isMuted) ? Icons.volume_off : Icons.volume_up;
        final color = (isMuted) ? Colors.grey : null;

        return IconButton(
          splashRadius: 25,
          onPressed: () => state.chosenDevice?.toggleMute(),
          icon: Icon(
            icon,
            color: color,
          ),
        );
      },
    );
  }
}
