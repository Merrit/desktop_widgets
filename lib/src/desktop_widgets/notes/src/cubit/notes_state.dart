part of 'notes_cubit.dart';

@freezed
class NotesState with _$NotesState {
  const factory NotesState({
    required String noteText,
  }) = _NotesState;

  const factory NotesState.initial({
    @Default('') String noteText,
  }) = _Initial;
}
