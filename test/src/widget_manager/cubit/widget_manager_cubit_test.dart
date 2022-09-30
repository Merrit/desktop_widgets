import 'dart:math';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:desktop_widgets/src/storage/storage_service.dart';
import 'package:desktop_widgets/src/widget_manager/widget_manager.dart';
import 'package:desktop_widgets/src/window/multi_window_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMultiWindowService extends Mock implements MultiWindowService {}

class MockWindowController extends Mock implements WindowController {}

class MockStorageService extends Mock implements StorageService {}

final multiWindowService = MockMultiWindowService();
final storageService = MockStorageService();

late WidgetManagerCubit cubit;

WidgetManagerState get state => cubit.state;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
/* --------------------------- MultiWindowService --------------------------- */
    when(() => multiWindowService.createWindow(
          arguments: any(named: 'arguments'),
        )).thenAnswer((_) async {
      final windowController = MockWindowController();
      final windowId = Random().nextInt(100);
      when(() => windowController.windowId).thenReturn(windowId);
      when(() => windowController.close()).thenAnswer((_) async {});
      return windowController;
    });
    when(() => multiWindowService.getSubWindowIds())
        .thenAnswer((_) async => []);
    when(() => multiWindowService.getWindowController(any()))
        .thenAnswer((invokation) {
      final windowController = MockWindowController();
      when(() => windowController.windowId)
          .thenReturn(invokation.positionalArguments.first as int);
      when(() => windowController.close()).thenAnswer((_) async {});
      return windowController;
    });

/* ----------------------------- StorageService ----------------------------- */
    when(() => storageService.deleteValue(
          any(),
          storageArea: any(named: 'storageArea'),
        )).thenAnswer((_) async {});
    when(() => storageService.saveValue(
          key: any(named: 'key'),
          value: any(named: 'value'),
          storageArea: any(named: 'storageArea'),
        )).thenAnswer((_) async {});
    when(() => storageService.getStorageAreaValues(any()))
        .thenAnswer((_) async => []);

    cubit = WidgetManagerCubit(multiWindowService, storageService);
  });

  test('removing widget works', () async {
    expect(state.runningWidgets.length, 0);
    await cubit.createDesktopWidget('ClockWidget');
    await cubit.createDesktopWidget('ClockWidget');
    expect(state.runningWidgets.length, 2);
    await cubit.deleteDesktopWidget(state.runningWidgets.first);
    expect(state.runningWidgets.length, 1);
  });
}
