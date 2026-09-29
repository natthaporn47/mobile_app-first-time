import 'package:flutter/material.dart';

class AppColors {
  // ✅ สีพื้นหลังนอกการ์ด (จาก IntroScreen)
  static const Color scaffoldBg = Color(0xFFF7F3EE);

  // ✅ สีพื้นหลัง profile เดิมของคุณ (ถ้ายังอยากเก็บไว้)
  static const Color profileBg = Color(0xFFFFF6EF);

  // ✅ สีใน watercolor gradient (จาก _WatercolorPainter)
  static const List<Color> watercolorGradient = [
    Color(0xFFF5E7D9),
    Color(0xFFE5F0E6),
    Color(0xFFF7EFE8),
  ];

  // ✅ สีปื้น blob (จาก _WatercolorPainter)
  static const Color blobMint = Color(0xFFA7C9B2);
  static const Color blobOrange = Color(0xFFE6B98F);
  static const Color blobSoftGreen = Color(0xFFD8E7D8);
  static const Color blobPeach = Color(0xFFF2D2B7);

  static const Color grain = Color(0x11000000);

  static const Color card = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFEDE3D9);

  static const Color textMain = Color(0xFF2B2B2B);
  static const Color textSub = Color(0xFF8E8176);

  static const Color mint = Color(0xFF9FBFAF);
  static const Color mintDark = Color(0xFF5F8F7A);
  static const danger = Color(0xFFD94E4E);
}