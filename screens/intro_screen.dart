import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'intro_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int _pageIndex = 0;

  // ✅ ใช้ควบคุมให้หน้า 3 กด Skip แล้วย้อนกลับหน้า 2
  final GlobalKey<IntroductionScreenState> _introKey =
      GlobalKey<IntroductionScreenState>();

  // -----------------------------
  // Onboarding Pages
  // -----------------------------
  List<PageViewModel> get pages => [
        PageViewModel(
          title: "Welcome to Kakkak",
          body: "Enjoy series, novels, and relaxing activities in one place.",
          image: Center(
            child: Image.asset(
              'lib/images/h.jpg',
              width: 250,
            ),
          ),
        ),
        PageViewModel(
          title: "Watch & Read Anywhere",
          body: "Watch your favorite series and read novels anytime, anywhere.",
          image: Center(
            child: Image.asset(
              'lib/images/2.jpg',
              width: 250,
            ),
          ),
        ),
        PageViewModel(
          title: "Relax Your Mind",
          body: "Take a break with relaxing activities and calm moments.",
          image: Center(
            child: Image.asset(
              'lib/images/b.jpg',
              width: 250,
            ),
          ),
        ),
      ];

  // -----------------------------
  // Done -> Save seen & go to Home
  // -----------------------------
  Future<void> _goToHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  // -----------------------------
  // Skip behavior:
  // - Page 2 (index=1): go IntoScreen (exit intro)
  // - Page 3 (index=2): go back to page 2
  // -----------------------------
  void _onSkipPressed() {
    // หน้า 3 -> ย้อนกลับไปหน้า 2
    if (_pageIndex == 2) {
      _introKey.currentState?.previous();
      return;
    }

    // หน้า 2 -> กลับหน้าเดิม/IntoScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const IntroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        key: _introKey,
        pages: pages,

        // ✅ Skip โชว์ตั้งแต่หน้า 2 เป็นต้นไป
        showSkipButton: _pageIndex >= 1,
        showBackButton: false,

        showNextButton: true,
        showDoneButton: true,

        skip: const Text("Skip"),
        next: const Icon(Icons.arrow_forward),
        done: const Text(
          "Done",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        // ✅ track page index
        onChange: (index) => setState(() => _pageIndex = index),

        // ✅ Skip behavior ตามที่คุณต้องการ
        onSkip: _onSkipPressed,

        // ✅ Done -> Home
        onDone: _goToHome,

        dotsDecorator: const DotsDecorator(
          color: Colors.blue,
          activeColor: Colors.red,
          size: Size(10.0, 10.0),
          activeSize: Size(15.0, 15.0),
          spacing: EdgeInsets.all(4.0),
        ),
      ),
    );
  }
}
