import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'screen/introduction_screen.dart';
import 'screens/sing_up.dart';
import 'screens/sign_in.dart';
import 'screen/home_shell.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

const bool _forceOnboarding = bool.fromEnvironment('SHOW_ONBOARDING');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final showOnboarding =
      _forceOnboarding || (prefs.getBool('ON_BOARDING') ?? true);

  final themeController = ThemeController();

  runApp(
    MyApp(themeController: themeController, showOnboarding: showOnboarding),
  );
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;
  final bool showOnboarding;

  const MyApp({
    super.key,
    required this.themeController,
    required this.showOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      controller: themeController,
      child: AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'HungryHub',

            theme: AppTheme.light(),
            darkTheme: AppTheme.night(),
            themeMode: themeController.mode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('th'), Locale('en')],

            home: showOnboarding ? const IntroScreen() : const SignInScreen(),

            routes: {
              '/signin': (_) => const SignInScreen(),
              '/signup': (_) => const SignUpScreen(),
              '/home': (_) => const HomeShell(),
            },
          );
        },
      ),
    );
  }
}
