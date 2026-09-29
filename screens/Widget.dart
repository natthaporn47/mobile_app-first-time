import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class FancyGradientBackground extends StatefulWidget {
  final Widget child;
  final Widget? overlay;

  const FancyGradientBackground({
    super.key,
    required this.child,
    this.overlay,
  });

  @override
  State<FancyGradientBackground> createState() => _FancyGradientBackgroundState();
}

class _FancyGradientBackgroundState extends State<FancyGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true); // ลอยขึ้นลงช้า ๆ
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value; // 0..1
          final wave = math.sin(t * math.pi * 2); // -1..1

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1) Base gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 255, 255, 255), // pink mist
                    ],
                  ),
                ),
              ),

              // 2) Floating blobs (layer)
              Positioned(
                top: -140 + (wave * 14),
                left: -110 + (wave * 10),
                child: const _Blob(
                  size: 320,
                  colors: [Color.fromARGB(255, 237, 84, 160), Color.fromARGB(255, 146, 103, 247)],
                  opacity: 0.45,
                  blurSigma: 0, // blur จะมาจาก BackdropFilter layer ด้านล่าง
                ),
              ),
              Positioned(
                top: 30 + (wave * -10),
                right: -140 + (wave * 8),
                child: const _Blob(
                  size: 300,
                  colors: [Color.fromARGB(255, 79, 198, 249), Color.fromARGB(255, 153, 112, 249)],
                  opacity: 0.40,
                  blurSigma: 0,
                ),
              ),
              Positioned(
                bottom: -170 + (wave * -12),
                left: -140 + (wave * 6),
                child: const _Blob(
                  size: 360,
                  colors: [Color(0xFF60A5FA), Color(0xFFEC4899)],
                  opacity: 0.38,
                  blurSigma: 0,
                ),
              ),

              // 3) Bokeh / sparkle (CustomPainter)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _BokehPainter(progress: t),
                  ),
                ),
              ),

              // 4) Soft glass blur on top of everything (ให้ละลาย)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(color: Colors.white.withOpacity(0.06)),
              ),

              if (widget.overlay != null) widget.overlay!,

              // 5) Your screen content
              Positioned.fill(child: widget.child),
            ],
          );
        },
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final double opacity;
  final double blurSigma;

  const _Blob({
    required this.size,
    required this.colors,
    this.opacity = 0.4,
    this.blurSigma = 0,
  });

  @override
  Widget build(BuildContext context) {
    final blob = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );

    final withOpacity = Opacity(opacity: opacity, child: blob);

    if (blurSigma <= 0) return withOpacity;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: withOpacity,
    );
  }
}

class _BokehPainter extends CustomPainter {
  final double progress; // 0..1
  _BokehPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // จุดโบเก้แบบสุ่มคงที่ (ใช้ตำแหน่งตายตัว) แต่ขยับ/กระพริบด้วย progress
    final points = <_BokehDot>[
      _BokehDot(0.15, 0.22, 10, 0.22),
      _BokehDot(0.72, 0.18, 12, 0.18),
      _BokehDot(0.85, 0.35, 8, 0.16),
      _BokehDot(0.20, 0.60, 14, 0.14),
      _BokehDot(0.48, 0.48, 9, 0.16),
      _BokehDot(0.62, 0.72, 16, 0.12),
      _BokehDot(0.88, 0.80, 10, 0.10),
      _BokehDot(0.10, 0.86, 8, 0.12),
      _BokehDot(0.35, 0.80, 12, 0.10),
      _BokehDot(0.55, 0.28, 7, 0.14),
    ];

    final p = progress;
    final floatY = math.sin(p * math.pi * 2); // -1..1
    final floatX = math.cos(p * math.pi * 2); // -1..1

    for (int i = 0; i < points.length; i++) {
      final d = points[i];

      // ขยับเบา ๆ ให้แต่ละจุดไม่เหมือนกัน
      final wobble = math.sin((p * math.pi * 2) + i * 0.7);
      final dx = (floatX * 6) + wobble * 3;
      final dy = (floatY * 8) + wobble * 4;

      // กระพริบ opacity เบา ๆ
      final twinkle = 0.65 + 0.35 * math.sin((p * math.pi * 2) + i * 1.3);

      final center = Offset(
        d.nx * size.width + dx,
        d.ny * size.height + dy,
      );

      final paint = Paint()
        ..color = Colors.white.withOpacity(d.baseOpacity * twinkle)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, d.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BokehPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _BokehDot {
  final double nx; // normalized 0..1
  final double ny; // normalized 0..1
  final double radius;
  final double baseOpacity;

  _BokehDot(this.nx, this.ny, this.radius, this.baseOpacity);
}
