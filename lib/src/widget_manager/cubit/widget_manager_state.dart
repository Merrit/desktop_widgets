part of 'widget_manager_cubit.dart';

class WidgetManagerState extends Equatable {
  final List<DesktopWidgetModel> runningWidgets;

  const WidgetManagerState({
    required this.runningWidgets,
  });

  @override
  List<Object?> get props => [runningWidgets];

  WidgetManagerState copyWith({
    List<DesktopWidgetModel>? runningWidgets,
  }) {
    return WidgetManagerState(
      runningWidgets: runningWidgets ?? this.runningWidgets,
    );
  }
}
