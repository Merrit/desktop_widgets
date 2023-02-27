import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../desktop_widgets.dart';

/// Widget that displays a text field for taking notes.
class NotesWidget extends StatelessWidget {
  final DesktopWidgetModel widgetModel;

  const NotesWidget(
    this.widgetModel, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;

    return BlocProvider(
      create: (context) => NotesCubit(widgetModel),
      lazy: false,
      child: SizedBox(
        width: width,
        height: height,
        child: const _NotesWidgetView(),
      ),
    );
  }
}

class _NotesWidgetView extends StatefulWidget {
  const _NotesWidgetView();

  @override
  State<_NotesWidgetView> createState() => _NotesWidgetViewState();
}

class _NotesWidgetViewState extends State<_NotesWidgetView> {
  final focusNode = FocusNode();
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadNoteText();

    focusNode.addListener(() {
      print('focusNode.hasFocus: ${focusNode.hasFocus}');
      if (!focusNode.hasFocus) {
        context.read<NotesCubit>().saveNoteText(textController.text);
      }
    });
  }

  /// Load note text from storage if it exists.
  Future<void> loadNoteText() async {
    final notesCubit = context.read<NotesCubit>();
    await context.read<NotesCubit>().loadNoteText();
    textController.text = notesCubit.state.noteText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      focusNode: focusNode,
      maxLines: null,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'New note...',
        hintStyle: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
