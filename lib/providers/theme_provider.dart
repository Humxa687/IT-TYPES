import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum GameThemeMode {
  dark,
  light,
}

class ThemeProvider extends ChangeNotifier {
  GameThemeMode _currentMode = GameThemeMode.dark;
  double _fontSize = 20.0; // Default sizing slightly larger for better readability

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
    _fontSize = size.clamp(14.0, 28.0);
    notifyListeners();
  }

  Color get backgroundColor {
    return isDark ? const Color(0xFF161C24) : const Color(0xFFF8FAFC); // Slate-gray space background
  }

  Gradient get backgroundGradient {
    return isDark
        ? const LinearGradient(
            colors: [Color(0xFF1A2130), Color(0xFF11141C)],
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
        ? const Color(0xFF1E2738).withOpacity(0.65)
        : const Color(0xFFFFFFFF).withOpacity(0.85);
  }

  Color get borderColor {
    return isDark
        ? const Color(0xFF3B82F6).withOpacity(0.15)
        : const Color(0xFFCBD5E1);
  }

  Color get accentColor {
    return const Color(0xFFE040FB); // Bright Magenta/Pink cursor
  }

  Color get correctCharColor {
    return isDark ? const Color(0xFF54A0FF) : const Color(0xFF0284C7); // Soft sky blue
  }

  Color get incorrectCharColor {
    return isDark ? const Color(0xFFFF5252) : const Color(0xFFDC2626); // Soft bright red
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
