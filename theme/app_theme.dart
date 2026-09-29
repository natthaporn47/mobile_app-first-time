import 'package:flutter/material.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.watercolorGradient,
    required this.blobMint,
    required this.blobOrange,
    required this.blobSoftGreen,
    required this.blobPeach,
    required this.grain,
  });

  final List<Color> watercolorGradient;
  final Color blobMint;
  final Color blobOrange;
  final Color blobSoftGreen;
  final Color blobPeach;
  final Color grain;

  @override
  AppThemeColors copyWith({
    List<Color>? watercolorGradient,
    Color? blobMint,
    Color? blobOrange,
    Color? blobSoftGreen,
    Color? blobPeach,
    Color? grain,
  }) {
    return AppThemeColors(
      watercolorGradient: watercolorGradient ?? this.watercolorGradient,
      blobMint: blobMint ?? this.blobMint,
      blobOrange: blobOrange ?? this.blobOrange,
      blobSoftGreen: blobSoftGreen ?? this.blobSoftGreen,
      blobPeach: blobPeach ?? this.blobPeach,
      grain: grain ?? this.grain,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;

    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t) ?? a;

    final int len = watercolorGradient.length;
    final List<Color> grad = List.generate(len, (i) {
      final Color a = watercolorGradient[i];
      final Color b = i < other.watercolorGradient.length
          ? other.watercolorGradient[i]
          : other.watercolorGradient.last;
      return lerpColor(a, b);
    });

    return AppThemeColors(
      watercolorGradient: grad,
      blobMint: lerpColor(blobMint, other.blobMint),
      blobOrange: lerpColor(blobOrange, other.blobOrange),
      blobSoftGreen: lerpColor(blobSoftGreen, other.blobSoftGreen),
      blobPeach: lerpColor(blobPeach, other.blobPeach),
      grain: lerpColor(grain, other.grain),
    );
  }
}

class AppTheme {
  /// ✅ ธีม “สีปัจจุบันที่ใช้อยู่” (Light)
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF9FBFAF),
      onPrimary: Colors.white,
      secondary: Color(0xFF5F8F7A),
      onSecondary: Colors.white,
      error: Color(0xFFD94E4E),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF2B2B2B),
      background: Color(0xFFF7F3EE),
      onBackground: Color(0xFF2B2B2B),
    );

    const ext = AppThemeColors(
      watercolorGradient: [
        Color(0xFFF5E7D9),
        Color(0xFFE5F0E6),
        Color(0xFFF7EFE8),
      ],
      blobMint: Color(0xFFA7C9B2),
      blobOrange: Color(0xFFE6B98F),
      blobSoftGreen: Color(0xFFD8E7D8),
      blobPeach: Color(0xFFF2D2B7),
      grain: Color(0x11000000),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      dividerColor: const Color(0xFFEDE3D9),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFF2B2B2B)),
      ),
      extensions: const [ext],
    );
  }

  /// ✅ ธีม “สีที่ 2” (Night)
  /// ถ้าอยากให้เข้ม/อ่อนกว่านี้ บอกได้ เดี๋ยวปรับให้เข้ากับแบรนด์
  static ThemeData night() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF7FB7A0),
      onPrimary: Color(0xFF0E1512),
      secondary: Color(0xFF9AD0BA),
      onSecondary: Color(0xFF0E1512),
      error: Color(0xFFFF6B6B),
      onError: Color(0xFF1B0B0B),
      surface: Color(0xFF151A19),
      onSurface: Color(0xFFECE8E2),
      background: Color(0xFF0F1211),
      onBackground: Color(0xFFECE8E2),
    );

    const ext = AppThemeColors(
      watercolorGradient: [
        Color(0xFF141918),
        Color(0xFF0F1A15),
        Color(0xFF1A1411),
      ],
      blobMint: Color(0xFF3F6E5C),
      blobOrange: Color(0xFF6E4E2E),
      blobSoftGreen: Color(0xFF2C3D33),
      blobPeach: Color(0xFF5A3C2D),
      grain: Color(0x22FFFFFF),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      dividerColor: const Color(0xFF2A2F2E),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFFECE8E2)),
      ),
      extensions: const [ext],
    );
  }
}
