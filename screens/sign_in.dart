import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'sing_up.dart';
import 'Widget.dart';
import '../screen/home_shell.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _submitted = false;
  bool _loading = false;

  static const Color _iconColor = Color(0xFF111827);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    IconData? icon,
    Widget? iconWidget,
    Widget? suffix,
  }) {
    final Widget? prefix =
        iconWidget ??
        (icon != null ? Icon(icon, color: _iconColor, size: 22) : null);

    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.4),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFEF4444),
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
    );
  }

  void _showSnack({
    required String text,
    required Color bg,
    required Color fg,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bg,
        content: Text(
          text,
          style: TextStyle(color: fg, fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String text) => _showSnack(
    text: text,
    bg: const Color(0xFFE8F5E9),
    fg: const Color(0xFF2E7D32),
  );

  void _showError(String text) => _showSnack(
    text: text,
    bg: const Color(0xFFFDECEA),
    fg: const Color(0xFFC62828),
  );

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  Future<void> _ensureUserDoc(User user, {String? fallbackName}) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await ref.get();

    final email = user.email ?? _emailController.text.trim();
    final displayName = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : (fallbackName?.trim().isNotEmpty ?? false)
        ? fallbackName!.trim()
        : email.split('@').first;

    final username = '@${displayName.toLowerCase().replaceAll(' ', '.')}';

    if (!snap.exists) {
      await ref.set({
        'name': displayName,
        'username': username,
        'email': email,
        'phone': '',
        'birthDate': '',
        'gender': 'female',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      final old = snap.data() ?? {};
      await ref.set({
        'name': (old['name'] ?? '').toString().isEmpty
            ? displayName
            : old['name'],
        'username': (old['username'] ?? '').toString().isEmpty
            ? username
            : old['username'],
        'email': email,
        'photoUrl': (old['photoUrl'] ?? '').toString().isEmpty
            ? (user.photoURL ?? '')
            : old['photoUrl'],
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> signIn() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _loading = true);

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = cred.user;
      var profileSaveFailed = false;
      if (user != null) {
        try {
          await _ensureUserDoc(user);
        } catch (_) {
          profileSaveFailed = true;
        }
      }

      if (!mounted) return;

      _showSuccess(
        profileSaveFailed
            ? 'เข้าสู่ระบบสำเร็จ แต่บันทึกข้อมูลโปรไฟล์ไม่สำเร็จ'
            : 'เข้าสู่ระบบสำเร็จ 🎉',
      );
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;

      _goToHome();
    } on FirebaseAuthException catch (e) {
      String msg = 'เข้าสู่ระบบไม่สำเร็จ';
      if (e.code == 'user-not-found') msg = 'ไม่พบบัญชีผู้ใช้นี้';
      if (e.code == 'wrong-password') msg = 'รหัสผ่านไม่ถูกต้อง';
      if (e.code == 'invalid-email') msg = 'รูปแบบอีเมลไม่ถูกต้อง';
      if (e.code == 'user-disabled') msg = 'บัญชีถูกระงับการใช้งาน';
      if (e.code == 'too-many-requests')
        msg = 'ลองใหม่ภายหลัง (พยายามหลายครั้งเกินไป)';

      _showError(msg);
    } catch (_) {
      _showError('เกิดข้อผิดพลาด กรุณาลองใหม่');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> googleSignIn() async {
    try {
      late final UserCredential cred;
      String? fallbackName;
      if (kIsWeb) {
        cred = await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;
        final googleAuth = await googleUser.authentication;
        fallbackName = googleUser.displayName;
        cred = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          ),
        );
      }

      final user = cred.user;
      var profileSaveFailed = false;
      if (user != null) {
        try {
          await _ensureUserDoc(user, fallbackName: fallbackName);
        } catch (_) {
          profileSaveFailed = true;
        }
      }

      if (!mounted) return;

      _showSuccess(
        profileSaveFailed
            ? 'เข้าสู่ระบบแล้ว แต่บันทึกข้อมูลโปรไฟล์ไม่สำเร็จ'
            : 'เข้าสู่ระบบด้วย Google สำเร็จ 🎉',
      );
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;

      _goToHome();
    } on FirebaseAuthException catch (e) {
      String msg = 'Google Sign-In ไม่สำเร็จ';
      if (e.code == 'account-exists-with-different-credential') {
        msg = 'อีเมลนี้เคยสมัครด้วยวิธีอื่น กรุณาใช้วิธีเดิมเข้าสู่ระบบก่อน';
      }
      _showError(msg);
    } catch (e) {
      _showError('Google Sign-In ไม่สำเร็จ: $e');
    }
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 26,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 130;
    final double half = avatarSize / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FancyGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const SizedBox(height: 80),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _glassCard(
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _submitted
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          children: [
                            SizedBox(height: half - 12),
                            const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0B0B0B),
                              ),
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _inputDecoration(
                                label: ' Email',
                                hint: 'Enter your email',
                                icon: Icons.email,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter email';
                                }
                                final email = value.trim();
                                final emailRegex = RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+$',
                                );
                                if (!emailRegex.hasMatch(email)) {
                                  return 'Invalid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _hidePassword,
                              decoration: _inputDecoration(
                                label: 'Password',
                                hint: 'Enter your password',
                                iconWidget: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Image.network(
                                    'https://img.icons8.com/material/24/lock-2--v1.png',
                                    color: _iconColor,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                ),
                                suffix: IconButton(
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: _iconColor,
                                    size: 22,
                                  ),
                                  onPressed: () => setState(() {
                                    _hidePassword = !_hidePassword;
                                  }),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _loading ? null : signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Sign in',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -half,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF22C55E), Color(0xFF38BDF8)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 18,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/HungryHu.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Or',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialCircleButton(
                      iconUrl:
                          'https://img.icons8.com/color/48/google-logo.png',
                      onTap: googleSignIn,
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocialCircleButton extends StatelessWidget {
  final String iconUrl;
  final VoidCallback onTap;

  const SocialCircleButton({
    super.key,
    required this.iconUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Center(child: Image.network(iconUrl, width: 32, height: 32)),
      ),
    );
  }
}
