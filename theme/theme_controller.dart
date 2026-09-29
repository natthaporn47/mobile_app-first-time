import 'package:flutter/material.dart';

/// Controller สำหรับสลับธีม (Light / Night)
class ThemeController extends ChangeNotifier {
  ThemeMode _mode;
  ThemeController({ThemeMode initialMode = ThemeMode.light}) : _mode = initialMode;

  ThemeMode get mode => _mode;

  bool get isNight => _mode == ThemeMode.dark;

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void toggle() {
    setMode(isNight ? ThemeMode.light : ThemeMode.dark);
  }
}

/// InheritedNotifier เพื่อเรียกใช้ ThemeController ได้จากทุกหน้า
class ThemeProvider extends InheritedNotifier<ThemeController> {
  const ThemeProvider({
    super.key,
    required ThemeController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static ThemeController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(provider != null, 'ThemeProvider not found. Wrap your app with ThemeProvider.');
    return provider!.notifier!;
  }
}
