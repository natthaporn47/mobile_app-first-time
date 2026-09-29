import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'Widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screen/home_shell.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _submitted = false;
  bool _loading = false;

  static const Color _iconColor = Color(0xFF111827);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  Future<void> _ensureUserDoc(User user, {required String typedName}) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final email = user.email ?? _emailController.text.trim();
    final displayName = typedName.trim().isEmpty
        ? email.split('@').first
        : typedName.trim();
    final username = '@${displayName.toLowerCase().replaceAll(' ', '.')}';

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
    }, SetOptions(merge: true));
  }

  Future<void> _googleLoginDemo() async {
    try {
      late final UserCredential cred;
      String? googleDisplayName;
      if (kIsWeb) {
        cred = await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ยกเลิกการเข้าสู่ระบบด้วย Google')),
          );
          return;
        }
        final googleAuth = await googleUser.authentication;
        googleDisplayName = googleUser.displayName;
        cred = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          ),
        );
      }

      final user = cred.user;
      if (user != null) {
        await _ensureUserDoc(
          user,
          typedName: googleDisplayName ?? user.displayName ?? '',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEAF7EE),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text(
            'เข้าสู่ระบบด้วย Google สำเร็จ 🎉',
            style: TextStyle(
              color: Color(0xFF1E7F43),
              fontWeight: FontWeight.w600,
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      _goToHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In ไม่สำเร็จ: ${e.code}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Sign-In ไม่สำเร็จ: $e')));
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

  Future<void> signUp() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFFFF3E0),
          content: const Text(
            'รหัสผ่านไม่ตรงกัน',
            style: TextStyle(
              color: Color(0xFFEF6C00),
              fontWeight: FontWeight.bold,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = cred.user;
      var profileSaveFailed = false;
      if (user != null) {
        try {
          await _ensureUserDoc(user, typedName: _nameController.text.trim());
        } catch (_) {
          profileSaveFailed = true;
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE8F5E9),
          content: Text(
            profileSaveFailed
                ? 'สมัครสมาชิกสำเร็จ แต่บันทึกข้อมูลโปรไฟล์ไม่สำเร็จ'
                : 'สมัครสมาชิกสำเร็จ 🎉',
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      _goToHome();
    } on FirebaseAuthException catch (e) {
      String msg = 'สมัครสมาชิกไม่สำเร็จ';
      if (e.code == 'email-already-in-use') msg = 'อีเมลนี้ถูกใช้แล้ว';
      if (e.code == 'invalid-email') msg = 'รูปแบบอีเมลไม่ถูกต้อง';
      if (e.code == 'weak-password')
        msg = 'รหัสผ่านอ่อนเกินไป (ควร 6 ตัวขึ้นไป)';
      if (e.code == 'operation-not-allowed')
        msg = 'ยังไม่ได้เปิด Email/Password ใน Firebase';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFFDECEA),
          content: Text(
            msg,
            style: const TextStyle(
              color: Color(0xFFC62828),
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color.fromARGB(255, 14, 14, 15),
                              ),
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _nameController,
                              decoration: _inputDecoration(
                                label: ' Username',
                                hint: 'Enter your username',
                                icon: Icons.person,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
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
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _hideConfirmPassword,
                              decoration: _inputDecoration(
                                label: 'Confirm password',
                                hint: 'Confirm your password',
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
                                    _hideConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: _iconColor,
                                    size: 22,
                                  ),
                                  onPressed: () => setState(() {
                                    _hideConfirmPassword =
                                        !_hideConfirmPassword;
                                  }),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                if (value != _passwordController.text) {
                                  return 'Password does not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _loading ? null : signUp,
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
                                        'Sign up',
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
                      onTap: _googleLoginDemo,
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignInScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Log in',
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
