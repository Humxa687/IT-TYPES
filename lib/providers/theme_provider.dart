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

  AppThemePreset get currentTheme => _currentTheme;
  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;

  bool get isDark {
    return _currentTheme == AppThemePreset.serikaDark ||
        _currentTheme == AppThemePreset.carbon ||
        _currentTheme == AppThemePreset.dracula ||
        _currentTheme == AppThemePreset.nord;
  }

  void setTheme(AppThemePreset preset) {
    _currentTheme = preset;
    notifyListeners();
  }

  void toggleTheme() {
    if (isDark) {
      _currentTheme = AppThemePreset.serikaLight;
    } else {
      _currentTheme = AppThemePreset.serikaDark;
    }
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

  // Retrieve Theme Colors
  Color get backgroundColor {
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFF111317);
      case AppThemePreset.carbon:
        return const Color(0xFF151515);
      case AppThemePreset.dracula:
        return const Color(0xFF282A36);
      case AppThemePreset.nord:
        return const Color(0xFF2E3440);
      case AppThemePreset.serikaLight:
        return const Color(0xFFFAFAFA);
      case AppThemePreset.paper:
        return const Color(0xFFF0EFEA);
      case AppThemePreset.solarizedLight:
        return const Color(0xFFFDF6E3);
      case AppThemePreset.cream:
        return const Color(0xFFFFFDD0);
    }
  }

  Gradient get backgroundGradient {
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const LinearGradient(colors: [Color(0xFF14161C), Color(0xFF0F1014)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case AppThemePreset.carbon:
        return const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF0E0E0E)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case AppThemePreset.dracula:
        return const LinearGradient(colors: [Color(0xFF2C2F3F), Color(0xFF1E2029)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case AppThemePreset.nord:
        return const LinearGradient(colors: [Color(0xFF343B49), Color(0xFF272C35)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case AppThemePreset.serikaLight:
        return const LinearGradient(colors: [Color(0xFFFAFAFA), Color(0xFFF0F2F5)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case AppThemePreset.paper:
        return const LinearGradient(colors: [Color(0xFFFAF9F6), Color(0xFFE9E8E2)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case AppThemePreset.solarizedLight:
        return const LinearGradient(colors: [Color(0xFFFFFDF5), Color(0xFFF0EAD6)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case AppThemePreset.cream:
        return const LinearGradient(colors: [Color(0xFFFFFFE0), Color(0xFFFDF5E6)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
  }

  Color get cardColor {
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFF1A1D24);
      case AppThemePreset.carbon:
        return const Color(0xFF212121);
      case AppThemePreset.dracula:
        return const Color(0xFF1E1F29);
      case AppThemePreset.nord:
        return const Color(0xFF3B4252);
      case AppThemePreset.serikaLight:
        return const Color(0xFFFFFFFF);
      case AppThemePreset.paper:
        return const Color(0xFFFAF9F5);
      case AppThemePreset.solarizedLight:
        return const Color(0xFFEEE8D5);
      case AppThemePreset.cream:
        return const Color(0xFFFFF8C4);
    }
  }

  Color get borderColor {
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFF2E333F);
      case AppThemePreset.carbon:
        return const Color(0xFF333333);
      case AppThemePreset.dracula:
        return const Color(0xFF44475A);
      case AppThemePreset.nord:
        return const Color(0xFF4C566A);
      case AppThemePreset.serikaLight:
        return const Color(0xFFE2E8F0);
      case AppThemePreset.paper:
        return const Color(0xFFD3D0C9);
      case AppThemePreset.solarizedLight:
        return const Color(0xFF93A1A1);
      case AppThemePreset.cream:
        return const Color(0xFFEEDC82);
    }
  }

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
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFFECEFF1);
      case AppThemePreset.carbon:
        return const Color(0xFFE5E5E5);
      case AppThemePreset.dracula:
        return const Color(0xFFF8F8F2);
      case AppThemePreset.nord:
        return const Color(0xFFECEFF4);
      case AppThemePreset.serikaLight:
        return const Color(0xFF1E293B);
      case AppThemePreset.paper:
        return const Color(0xFF4A463F);
      case AppThemePreset.solarizedLight:
        return const Color(0xFF586E75);
      case AppThemePreset.cream:
        return const Color(0xFF3E2723);
    }
  }

  Color get incorrectCharColor {
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFFEF5350);
      case AppThemePreset.carbon:
        return const Color(0xFFE53935);
      case AppThemePreset.dracula:
        return const Color(0xFFFF5555);
      case AppThemePreset.nord:
        return const Color(0xFFBF616A);
      case AppThemePreset.serikaLight:
        return const Color(0xFFD32F2F);
      case AppThemePreset.paper:
        return const Color(0xFFB84444);
      case AppThemePreset.solarizedLight:
        return const Color(0xFFDC322F);
      case AppThemePreset.cream:
        return const Color(0xFFC62828);
    }
  }

  Color get untypedCharColor {
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFF4E5766);
      case AppThemePreset.carbon:
        return const Color(0xFF5F5F5F);
      case AppThemePreset.dracula:
        return const Color(0xFF6272A4);
      case AppThemePreset.nord:
        return const Color(0xFF4C566A);
      case AppThemePreset.serikaLight:
        return const Color(0xFF94A3B8);
      case AppThemePreset.paper:
        return const Color(0xFF8F8B83);
      case AppThemePreset.solarizedLight:
        return const Color(0xFF93A1A1);
      case AppThemePreset.cream:
        return const Color(0xFFB0A26B);
    }
  }

  Color get textColor {
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFFF1F5F9);
      case AppThemePreset.carbon:
        return const Color(0xFFEEEEEE);
      case AppThemePreset.dracula:
        return const Color(0xFFF8F8F2);
      case AppThemePreset.nord:
        return const Color(0xFFECEFF4);
      case AppThemePreset.serikaLight:
        return const Color(0xFF0F172A);
      case AppThemePreset.paper:
        return const Color(0xFF2C2A26);
      case AppThemePreset.solarizedLight:
        return const Color(0xFF073642);
      case AppThemePreset.cream:
        return const Color(0xFF4E342E);
    }
  }

  Color get subtextColor {
    switch (_currentTheme) {
      case AppThemePreset.serikaDark:
        return const Color(0xFF718096);
      case AppThemePreset.carbon:
        return const Color(0xFF757575);
      case AppThemePreset.dracula:
        return const Color(0xFF6272A4);
      case AppThemePreset.nord:
        return const Color(0xFF6D8096);
      case AppThemePreset.serikaLight:
        return const Color(0xFF64748B);
      case AppThemePreset.paper:
        return const Color(0xFF7D7872);
      case AppThemePreset.solarizedLight:
        return const Color(0xFF657B83);
      case AppThemePreset.cream:
        return const Color(0xFF8D6E63);
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
