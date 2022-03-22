import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../desktop_widgets.dart';
import 'audio.dart';
import 'cubit/audio_cubit.dart';

class AudioWidget extends StatelessWidget implements DesktopWidget {
  @override
  final Audio widgetModel;

  const AudioWidget({
    Key? key,
    required this.widgetModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioCubit(),
      child: const Card(
        child: Placeholder(),
      ),
    );
  }
}
