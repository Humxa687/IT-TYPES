import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum GameThemeMode {
  dark,
  light,
}

class ThemeProvider extends ChangeNotifier {
  GameThemeMode _currentMode = GameThemeMode.dark;
  double _fontSize = 18.0; // Dynamic typing font size

  GameThemeMode get currentMode => _currentMode;
  bool get isDark => _currentMode == GameThemeMode.dark;
  double get fontSize => _fontSize;

  void setThemeMode(GameThemeMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _currentMode = (_currentMode == GameThemeMode.dark) ? GameThemeMode.light : GameThemeMode.dark;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  Color get backgroundColor {
    return isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  }

  Gradient get backgroundGradient {
    return isDark
        ? const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
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
        ? const Color(0xFF1E293B).withOpacity(0.55)
        : const Color(0xFFFFFFFF).withOpacity(0.75);
  }

  Color get borderColor {
    return isDark
        ? const Color(0xFF38BDF8).withOpacity(0.2)
        : const Color(0xFFCBD5E1);
  }

  Color get accentColor {
    return isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7); // Sky accents
  }

  Color get correctCharColor {
    return isDark ? const Color(0xFF34D399) : const Color(0xFF059669); // Emerald
  }

  Color get incorrectCharColor {
    return isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626); // Crimson
  }

  Color get untypedCharColor {
    return isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8); // Slate comments
  }

  Color get textColor {
    return isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  }

  Color get subtextColor {
    return isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  }

  TextStyle getMonospaceTextStyle({double? fontSize, FontWeight fontWeight = FontWeight.normal}) {
    final useSize = fontSize ?? _fontSize;
    return isDark
        ? GoogleFonts.shareTechMono(
            fontSize: useSize,
            fontWeight: fontWeight,
            color: textColor,
            letterSpacing: 1.2,
          )
        : GoogleFonts.firaCode(
            fontSize: useSize,
            fontWeight: fontWeight,
            color: textColor,
            letterSpacing: 0.8,
          );
  }

  TextStyle getHeadingStyle({double fontSize = 24.0, FontWeight fontWeight = FontWeight.bold}) {
    return isDark
        ? GoogleFonts.outfit(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
          )
        : GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
          );
  }
}
