import 'package:flutter/material.dart';

import '../../desktop_widgets.dart';

/// Allows the user to view and edit a block of text.
class NotesWidget extends StatefulWidget {
  final DesktopWidgetModel desktopWidgetModel;

  const NotesWidget(
    this.desktopWidgetModel, {
    Key? key,
  }) : super(key: key);

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  final focusNode = FocusNode();
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        // save the text
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;

    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: textController,
        maxLines: null,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'New note...',
          hintStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
