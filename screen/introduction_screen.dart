import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ ใช้หน้า SignIn “ตัวเก่า” ของคุณ
import '../screens/sign_in.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardData> _pages = [
    const _OnboardData(
      title: 'Welcome to\nHungryHub',
      body: '',
      imagePath: 'assets/images/HungryHu.png',
      imageHeight: 300,
      showPrimaryButton: true,
    ),
    const _OnboardData(
      title: 'Discover\nDelicious Recipes',
      body: 'Find easy-to-follow recipes\nfor any taste, cuisine, or occasion.',
      imagePath: 'assets/images/11.png',
      imageHeight: 600,
    ),
    const _OnboardData(
      title: 'Find Great\nRestaurants',
      body: 'Explore and review top-rated\nrestaurants near you.',
      imagePath: 'assets/images/22.png',
      imageHeight: 200,
    ),
    const _OnboardData(
      title: 'Enjoy\nExclusive Offers',
      body: 'Save on your favorite meals\nwith special discounts and rewards.',
      imagePath: 'assets/images/33.png',
      imageHeight: 270,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ON_BOARDING', false);
    if (!mounted) return;

    // ✅ ไป SignIn เก่า (จาก ../screens/sign_in.dart)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  void _next() {
    if (_index >= _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  /// ✅ Skip = ย้อนกลับ
  void _back() {
    // ถ้าอยู่หน้า 2-4 ให้ย้อนใน onboarding
    if (_index > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
      return;
    }

    // ถ้าอยู่หน้าแรก: ถ้ามีหน้าก่อนหน้าใน Navigator ให้ pop กลับไป
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    // ถ้าเป็นหน้าแรกของแอพจริง ๆ และไม่มีอะไรให้ pop -> ไม่ต้องทำอะไร
  }

  void _goTo(int i) {
    _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 26,
                      offset: Offset(0, 12),
                      color: Color(0x22000000),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    const Positioned.fill(child: _WatercolorBackground()),
                    Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _controller,
                            itemCount: _pages.length,
                            onPageChanged: (i) => setState(() => _index = i),
                            itemBuilder: (context, i) => _OnboardPage(
                              data: _pages[i],
                              onPrimaryTap: _next,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                          child: Row(
                            children: [
                              // Skip (ย้อนกลับ)
                              GestureDetector(
                                onTap: _back,
                                behavior: HitTestBehavior.translucent,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                  child: Text(
                                    'Skip',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF8C837B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),

                              // Dots กดได้
                              _Dots(
                                count: _pages.length,
                                index: _index,
                                onTapDot: _goTo,
                              ),

                              const Spacer(),
                              // Next
                              GestureDetector(
                                onTap: _next,
                                behavior: HitTestBehavior.translucent,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Next',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF8C837B),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 20,
                                        color: Color(0xFFCC7A2A),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardData {
  final String title;
  final String body;
  final String imagePath;
  final double? imageHeight;
  final bool showPrimaryButton;

  const _OnboardData({
    required this.title,
    required this.body,
    required this.imagePath,
    this.imageHeight,
    this.showPrimaryButton = false,
  });
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({
    required this.data,
    required this.onPrimaryTap,
  });

  final _OnboardData data;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    const textMain = Color(0xFF5B4F46);
    const textSub = Color(0xFF8C837B);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: Image.asset(
                data.imagePath,
                height: data.imageHeight ?? 280,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              height: 1.15,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: textMain,
              letterSpacing: -0.2,
            ),
          ),
          if (data.body.isNotEmpty) ...[
            const SizedBox(height: 10),
            const SizedBox(height: 2),
            Text(
              data.body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                height: 1.35,
                fontSize: 13.5,
                color: textSub,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (data.showPrimaryButton)
            _PrimaryPillButton(label: 'Get Started', onTap: onPrimaryTap),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _PrimaryPillButton extends StatelessWidget {
  const _PrimaryPillButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFA7C9B2),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(0, 6),
              color: Color(0x22000000),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.index,
    required this.onTapDot,
  });

  final int count;
  final int index;
  final ValueChanged<int> onTapDot;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;

        return GestureDetector(
          onTap: () => onTapDot(i),
          behavior: HitTestBehavior.translucent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: active ? const Color(0xFFA7C9B2) : const Color(0xFFDECFC3),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _WatercolorBackground extends StatelessWidget {
  const _WatercolorBackground();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WatercolorPainter(seed: 42),
      child: const SizedBox.expand(),
    );
  }
}

class _WatercolorPainter extends CustomPainter {
  final int seed;
  _WatercolorPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(seed);

    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF5E7D9),
          Color(0xFFE5F0E6),
          Color(0xFFF7EFE8),
        ],
        stops: [0.05, 0.55, 0.95],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    void blob({required Color color, required double opacity, required double radius}) {
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

    blob(color: const Color(0xFFA7C9B2), opacity: 0.20, radius: size.shortestSide * 0.18);
    blob(color: const Color(0xFFE6B98F), opacity: 0.18, radius: size.shortestSide * 0.20);
    blob(color: const Color(0xFFD8E7D8), opacity: 0.22, radius: size.shortestSide * 0.16);
    blob(color: const Color(0xFFF2D2B7), opacity: 0.16, radius: size.shortestSide * 0.22);

    final grain = Paint()..color = const Color(0x11000000);
    for (int i = 0; i < 320; i++) {
      final x = r.nextDouble() * size.width;
      final y = r.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), r.nextDouble() * 0.8, grain);
    }
  }

  @override
  bool shouldRepaint(covariant _WatercolorPainter oldDelegate) => false;
}
