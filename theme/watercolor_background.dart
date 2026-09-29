import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WatercolorBackground extends StatelessWidget {
  const WatercolorBackground({super.key, this.seed = 42});
  final int seed;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeColors>();

    // ถ้าเผลอลืมใส่ ThemeData.extensions ใน MaterialApp
    // จะ fallback เป็นโทน light เพื่อไม่ให้แอปพัง
    const fallback = AppThemeColors(
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

    return CustomPaint(
      painter: _WatercolorPainter(seed: seed, colors: ext ?? fallback),
      child: const SizedBox.expand(),
    );
  }
}

class _WatercolorPainter extends CustomPainter {
  final int seed;
  final AppThemeColors colors;
  _WatercolorPainter({required this.seed, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(seed);

    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors.watercolorGradient,
        stops: const [0.05, 0.55, 0.95],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, bg);

    void blob({
      required Color color,
      required double opacity,
      required double radius,
    }) {
      final paint = Paint()..color = color.withOpacity(opacity);
      final cx = r.nextDouble() * size.width;
      final cy = r.nextDouble() * size.height;

      for (int i = 0; i < 14; i++) {
        final dx = (r.nextDouble() - 0.5) * radius * 0.9;
        final dy = (r.nextDouble() - 0.5) * radius * 0.9;
        final rr = radius * (0.55 + r.nextDouble() * 0.6);
        canvas.drawCircle(Offset(cx + dx, cy + dy), rr, paint);
      }
    }

    blob(color: colors.blobMint, opacity: 0.20, radius: size.shortestSide * 0.18);
    blob(color: colors.blobOrange, opacity: 0.18, radius: size.shortestSide * 0.20);
    blob(color: colors.blobSoftGreen, opacity: 0.22, radius: size.shortestSide * 0.16);
    blob(color: colors.blobPeach, opacity: 0.16, radius: size.shortestSide * 0.22);

    final grainPaint = Paint()..color = colors.grain;
    for (int i = 0; i < 320; i++) {
      final x = r.nextDouble() * size.width;
      final y = r.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), r.nextDouble() * 0.8, grainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WatercolorPainter oldDelegate) => false;
}
