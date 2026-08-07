import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum GameThemeMode {
  dark,
  light,
}

class ThemeProvider extends ChangeNotifier {
  GameThemeMode _currentMode = GameThemeMode.dark;
  double _fontSize = 20.0;
  String _fontFamily = 'monospace'; // 'monospace', 'sans-serif', 'serif'

  GameThemeMode get currentMode => _currentMode;
  bool get isDark => _currentMode == GameThemeMode.dark;
  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;

  void setThemeMode(GameThemeMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _currentMode = (_currentMode == GameThemeMode.dark) ? GameThemeMode.light : GameThemeMode.dark;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size.clamp(14.0, 28.0);
    notifyListeners();
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    notifyListeners();
  }

  Color get backgroundColor {
    return isDark ? const Color(0xFF0F1319) : const Color(0xFFF8FAFC); // Custom space deep-black background
  }

  Gradient get backgroundGradient {
    return isDark
        ? const LinearGradient(
            colors: [Color(0xFF141923), Color(0xFF0A0D14)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
  }

  Color get cardColor {
    return isDark
        ? const Color(0xFF171F2C).withOpacity(0.8)
        : const Color(0xFFFFFFFF).withOpacity(0.9);
  }

  Color get borderColor {
    return isDark
        ? const Color(0xFF3B82F6).withOpacity(0.2)
        : const Color(0xFFCBD5E1);
  }

  Color get accentColor {
    return const Color(0xFFE040FB); // Premium Pink/Magenta
  }

  Color get correctCharColor {
    return isDark ? const Color(0xFF54A0FF) : const Color(0xFF0284C7); // Sky blue
  }

  Color get incorrectCharColor {
    return isDark ? const Color(0xFFFF5252) : const Color(0xFFDC2626); // Bright red
  }

  Color get untypedCharColor {
    return isDark ? const Color(0xFF637381) : const Color(0xFF94A3B8); // Muted slate gray
  }

  Color get textColor {
    return isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  }

  Color get subtextColor {
    return isDark ? const Color(0xFF919EAB) : const Color(0xFF64748B);
  }

  TextStyle getMonospaceTextStyle({double? fontSize, FontWeight fontWeight = FontWeight.normal}) {
    final useSize = fontSize ?? _fontSize;
    if (_fontFamily == 'sans-serif') {
      return GoogleFonts.plusJakartaSans(
        fontSize: useSize,
        fontWeight: fontWeight,
        color: textColor,
        letterSpacing: 0.5,
      );
    } else if (_fontFamily == 'serif') {
      return GoogleFonts.merriweather(
        fontSize: useSize,
        fontWeight: fontWeight,
        color: textColor,
        letterSpacing: 0.5,
      );
    } else {
      return GoogleFonts.jetBrainsMono(
        fontSize: useSize,
        fontWeight: fontWeight,
        color: textColor,
        letterSpacing: 0.8,
      );
    }
  }

  TextStyle getHeadingStyle({double fontSize = 24.0, FontWeight fontWeight = FontWeight.bold}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: textColor,
      letterSpacing: 0.5,
    );
  }
}
