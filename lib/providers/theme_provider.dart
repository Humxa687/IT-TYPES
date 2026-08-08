import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemePreset {
  serikaDark,
  carbon,
  dracula,
  nord,
  serikaLight,
  paper,
  solarizedLight,
  cream,
}

class ThemeProvider extends ChangeNotifier {
  AppThemePreset _currentTheme = AppThemePreset.serikaDark;
  double _fontSize = 20.0;
  String _fontFamily = 'monospace'; // 'monospace', 'sans-serif', 'serif'
  bool _isLightMode = false;

  AppThemePreset get currentTheme => _currentTheme;
  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  bool get isLightMode => _isLightMode;

  bool get isDark => !_isLightMode;

  void setTheme(AppThemePreset preset) {
    _currentTheme = preset;
    // Set default light/dark mode alignment matching preset defaults
    _isLightMode = preset == AppThemePreset.serikaLight ||
        preset == AppThemePreset.paper ||
        preset == AppThemePreset.solarizedLight ||
        preset == AppThemePreset.cream;
    notifyListeners();
  }

  void toggleTheme() {
    _isLightMode = !_isLightMode;
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

  // Retrieve Theme Colors (Respect decoupled Light Mode appearance overrides)
  Color get backgroundColor {
    if (_isLightMode) {
      return const Color(0xFFFAFAFA);
    }
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFF111317);
      case AppThemePreset.carbon:
        return const Color(0xFF151515);
      case AppThemePreset.dracula:
        return const Color(0xFF282A36);
      case AppThemePreset.nord:
        return const Color(0xFF2E3440);
      default:
        return const Color(0xFF111317);
    }
  }

  Gradient get backgroundGradient {
    if (_isLightMode) {
      return const LinearGradient(
        colors: [Color(0xFFFAFAFA), Color(0xFFF0F2F5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const LinearGradient(colors: [Color(0xFF14161C), Color(0xFF0F1014)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case AppThemePreset.carbon:
        return const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF0E0E0E)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case AppThemePreset.dracula:
        return const LinearGradient(colors: [Color(0xFF2C2F3F), Color(0xFF1E2029)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case AppThemePreset.nord:
        return const LinearGradient(colors: [Color(0xFF343B49), Color(0xFF272C35)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      default:
        return const LinearGradient(colors: [Color(0xFF14161C), Color(0xFF0F1014)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
  }

  Color get cardColor {
    if (_isLightMode) {
      return const Color(0xFFFFFFFF);
    }
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFF1A1D24);
      case AppThemePreset.carbon:
        return const Color(0xFF212121);
      case AppThemePreset.dracula:
        return const Color(0xFF1E1F29);
      case AppThemePreset.nord:
        return const Color(0xFF3B4252);
      default:
        return const Color(0xFF1A1D24);
    }
  }

  Color get borderColor {
    if (_isLightMode) {
      return const Color(0xFFE2E8F0);
    }
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFF2E333F);
      case AppThemePreset.carbon:
        return const Color(0xFF333333);
      case AppThemePreset.dracula:
        return const Color(0xFF44475A);
      case AppThemePreset.nord:
        return const Color(0xFF4C566A);
      default:
        return const Color(0xFF2E333F);
    }
  }

  // AccentColor (Secondary Color Highlight) always remains locked as per selection!
  Color get accentColor {
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFFE5B539); // Warm golden Serika yellow
      case AppThemePreset.carbon:
        return const Color(0xFFF57C00); // Carbon orange
      case AppThemePreset.dracula:
        return const Color(0xFFBD93F9); // Dracula Purple
      case AppThemePreset.nord:
        return const Color(0xFF88C0D0); // Nord Ice blue
      case AppThemePreset.serikaLight:
        return const Color(0xFF1A202C); // Deep Charcoal
      case AppThemePreset.paper:
        return const Color(0xFF44413C); // Slate Ink
      case AppThemePreset.solarizedLight:
        return const Color(0xFF2AA198); // Solar Teal
      case AppThemePreset.cream:
        return const Color(0xFF5D3A00); // Coffee Brown
    }
  }

  Color get correctCharColor {
    if (_isLightMode) {
      return const Color(0xFF1E293B);
    }
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFFECEFF1);
      case AppThemePreset.carbon:
        return const Color(0xFFE5E5E5);
      case AppThemePreset.dracula:
        return const Color(0xFFF8F8F2);
      case AppThemePreset.nord:
        return const Color(0xFFECEFF4);
      default:
        return const Color(0xFFECEFF1);
    }
  }

  Color get incorrectCharColor {
    if (_isLightMode) {
      return const Color(0xFFD32F2F);
    }
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFFEF5350);
      case AppThemePreset.carbon:
        return const Color(0xFFE53935);
      case AppThemePreset.dracula:
        return const Color(0xFFFF5555);
      case AppThemePreset.nord:
        return const Color(0xFFBF616A);
      default:
        return const Color(0xFFEF5350);
    }
  }

  Color get untypedCharColor {
    if (_isLightMode) {
      return const Color(0xFF94A3B8);
    }
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFF4E5766);
      case AppThemePreset.carbon:
        return const Color(0xFF5F5F5F);
      case AppThemePreset.dracula:
        return const Color(0xFF6272A4);
      case AppThemePreset.nord:
        return const Color(0xFF4C566A);
      default:
        return const Color(0xFF4E5766);
    }
  }

  Color get textColor {
    if (_isLightMode) {
      return const Color(0xFF0F172A);
    }
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFFF1F5F9);
      case AppThemePreset.carbon:
        return const Color(0xFFEEEEEE);
      case AppThemePreset.dracula:
        return const Color(0xFFF8F8F2);
      case AppThemePreset.nord:
        return const Color(0xFFECEFF4);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color get subtextColor {
    if (_isLightMode) {
      return const Color(0xFF64748B);
    }
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFF718096);
      case AppThemePreset.carbon:
        return const Color(0xFF757575);
      case AppThemePreset.dracula:
        return const Color(0xFF6272A4);
      case AppThemePreset.nord:
        return const Color(0xFF6D8096);
      default:
        return const Color(0xFF718096);
    }
  }

  // Color lists for theme swatch preview displays in settings drawer
  List<Color> getThemeColors(AppThemePreset preset) {
    switch (preset) {
      case AppThemePreset.serikaDark:
        return [const Color(0xFF111317), const Color(0xFFE5B539), const Color(0xFFEF5350), const Color(0xFFECEFF1)];
      case AppThemePreset.carbon:
        return [const Color(0xFF151515), const Color(0xFFF57C00), const Color(0xFFE53935), const Color(0xFFE5E5E5)];
      case AppThemePreset.dracula:
        return [const Color(0xFF282A36), const Color(0xFFBD93F9), const Color(0xFFFF5555), const Color(0xFFF8F8F2)];
      case AppThemePreset.nord:
        return [const Color(0xFF2E3440), const Color(0xFF88C0D0), const Color(0xFFBF616A), const Color(0xFFECEFF4)];
      case AppThemePreset.serikaLight:
        return [const Color(0xFFFAFAFA), const Color(0xFF1A202C), const Color(0xFFD32F2F), const Color(0xFF1E293B)];
      case AppThemePreset.paper:
        return [const Color(0xFFF0EFEA), const Color(0xFF44413C), const Color(0xFFB84444), const Color(0xFF4A463F)];
      case AppThemePreset.solarizedLight:
        return [const Color(0xFFFDF6E3), const Color(0xFF2AA198), const Color(0xFFDC322F), const Color(0xFF586E75)];
      case AppThemePreset.cream:
        return [const Color(0xFFFFFDD0), const Color(0xFF5D3A00), const Color(0xFFC62828), const Color(0xFF3E2723)];
    }
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
