import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../desktop_widgets/desktop_widgets.dart';
import '../settings_service.dart';

part 'settings_state.dart';

late final SettingsCubit settingsCubit;

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService _settingsService;

  SettingsCubit(this._settingsService) : super(const SettingsState()) {
    settingsCubit = this;
  }

  Future<void> saveWidget(WidgetModel widget) async {
    final widgetMap = widget.toJson();

    await _settingsService.saveWidget(
      key: widget.uuid,
      value: json.encode(widgetMap),
    );
  }

  List<WidgetModel> loadWidgets() => _settingsService.loadWidgets();
}
