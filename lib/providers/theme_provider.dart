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
    _fontSize = size.clamp(14.0, 50.0);
    notifyListeners();
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    notifyListeners();
  }

  Color get backgroundColor {
    return isDark ? const Color(0xFF111317) : const Color(0xFFFAFAFA);
  }

  Gradient get backgroundGradient {
    return isDark
        ? const LinearGradient(
            colors: [Color(0xFF14161C), Color(0xFF0F1014)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFFAFAFA), Color(0xFFF0F2F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
  }

  Color get cardColor {
    return isDark
        ? const Color(0xFF1A1D24)
        : const Color(0xFFFFFFFF);
  }

  Color get borderColor {
    return isDark
        ? const Color(0xFF2E333F)
        : const Color(0xFFE2E8F0);
  }

  Color get accentColor {
    return isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111317); // Original monochrome highlights (White for dark, Black for light)
  }

  Color get correctCharColor {
    return isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B); // Solid monochrome typed text
  }

  Color get incorrectCharColor {
    return isDark ? const Color(0xFFEF5350) : const Color(0xFFD32F2F); // Standard red indicators
  }

  Color get untypedCharColor {
    return isDark ? const Color(0xFF4E5766) : const Color(0xFF94A3B8); // Muted layout text
  }

  Color get textColor {
    return isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  }

  Color get subtextColor {
    return isDark ? const Color(0xFF718096) : const Color(0xFF64748B);
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
