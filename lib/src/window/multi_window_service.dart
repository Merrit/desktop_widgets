import 'package:desktop_multi_window/desktop_multi_window.dart';

class MultiWindowService {
  Future<WindowController> createWindow({String? arguments}) async {
    return await DesktopMultiWindow.createWindow(arguments);
  }

  Future<List<int>> getSubWindowIds() async {
    return await DesktopMultiWindow.getAllSubWindowIds();
  }

  WindowController getWindowController(int windowId) {
    return WindowController.fromWindowId(windowId);
  }

  Future<dynamic> invokeMethod({
    required int targetWindowId,
    required String method,
    dynamic arguments,
  }) async {
    return await DesktopMultiWindow.invokeMethod(
      targetWindowId,
      method,
      arguments,
    );
  }
}
