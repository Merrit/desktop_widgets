import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../logs/logging_manager.dart';
import '../../../../storage/storage_service.dart';
import '../../../desktop_widgets.dart';

part 'notes_state.dart';
part 'notes_cubit.freezed.dart';

class NotesCubit extends Cubit<NotesState> {
  final DesktopWidgetModel _widgetModel;

  NotesCubit(DesktopWidgetModel widgetModel)
      : _widgetModel = widgetModel,
        super(const NotesState.initial());

  /// Load note text from storage.
  Future<void> loadNoteText() async {
    final String? noteText = await StorageService.instance.getValue(
      'noteText',
      storageArea: _widgetModel.id,
    );

    if (noteText == null) return;
    log.v('Loaded note text: $noteText');
    emit(state.copyWith(noteText: noteText));
  }

  /// Save note text to storage.
  Future<void> saveNoteText(String text) async {
    log.v('Saving note text: $text');
    await StorageService.instance.saveValue(
      key: 'noteText',
      value: text,
      storageArea: _widgetModel.id,
    );
  }
}
