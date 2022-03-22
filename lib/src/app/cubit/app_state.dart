part of 'app_cubit.dart';

class AppState extends Equatable {
  final List<Screen> screens;
  final Screen? currentAppScreen;
  final bool addingWidgets;
  final bool editing;
  final bool shouldShowSettings;
  final List<DesktopWidget> availableWidgets;
  final List<DesktopWidget> widgets;

  const AppState({
    required this.screens,
    required this.currentAppScreen,
    required this.addingWidgets,
    required this.editing,
    required this.shouldShowSettings,
    required this.availableWidgets,
    required this.widgets,
  });

  const AppState.initial()
      : screens = const [],
        currentAppScreen = null,
        addingWidgets = false,
        editing = false,
        shouldShowSettings = false,
        availableWidgets = const [],
        widgets = const [];

  @override
  List<Object> get props {
    return [
      screens,
      addingWidgets,
      editing,
      shouldShowSettings,
      availableWidgets,
      widgets,
    ];
  }

  AppState copyWith({
    List<Screen>? screens,
    Screen? currentAppScreen,
    bool? addingWidgets,
    bool? editing,
    bool? shouldShowSettings,
    List<DesktopWidget>? availableWidgets,
    List<DesktopWidget>? widgets,
  }) {
    return AppState(
      screens: screens ?? this.screens,
      currentAppScreen: currentAppScreen ?? this.currentAppScreen,
      addingWidgets: addingWidgets ?? this.addingWidgets,
      editing: editing ?? this.editing,
      shouldShowSettings: shouldShowSettings ?? this.shouldShowSettings,
      availableWidgets: availableWidgets ?? this.availableWidgets,
      widgets: widgets ?? this.widgets,
    );
  }
}
