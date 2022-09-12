part of 'wrapper_cubit.dart';

class WrapperState extends Equatable {
  final bool isHovered;
  final bool isLocked;
  final DesktopWidgetModel widgetModel;

  const WrapperState({
    required this.isHovered,
    required this.isLocked,
    required this.widgetModel,
  });

  @override
  List<Object> get props => [
        isHovered,
        isLocked,
        widgetModel,
      ];

  WrapperState copyWith({
    bool? isHovered,
    bool? isLocked,
    DesktopWidgetModel? widgetModel,
  }) {
    return WrapperState(
      isHovered: isHovered ?? this.isHovered,
      isLocked: isLocked ?? this.isLocked,
      widgetModel: widgetModel ?? this.widgetModel,
    );
  }
}
