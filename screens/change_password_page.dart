import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/pass_background.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassCtl = TextEditingController();
  final _newPassCtl = TextEditingController();
  final _confirmCtl = TextEditingController();

  bool _busy = false;
  bool _obOld = true;
  bool _obNew = true;
  bool _obConfirm = true;

  @override
  void dispose() {
    _oldPassCtl.dispose();
    _newPassCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  bool _isPasswordProvider(User user) {
    return user.providerData.any((p) => p.providerId == 'password');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (_busy) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _toast('กรุณาเข้าสู่ระบบก่อน');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (!_isPasswordProvider(user)) {
      _toast(
        'บัญชีนี้ไม่ได้เข้าสู่ระบบด้วยอีเมล/รหัสผ่าน\n'
        'กรุณาเข้าสู่ระบบใหม่ด้วยวิธีเดิมก่อน แล้วค่อยเปลี่ยนรหัสผ่าน',
      );
      return;
    }

    final email = (user.email ?? '').trim();
    if (email.isEmpty) {
      _toast('ไม่พบอีเมลของบัญชีนี้ กรุณาเข้าสู่ระบบใหม่');
      return;
    }

    setState(() => _busy = true);

    try {
      final oldPass = _oldPassCtl.text;
      final newPass = _newPassCtl.text;

      final cred = EmailAuthProvider.credential(email: email, password: oldPass);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPass);

      if (!mounted) return;
      _toast('เปลี่ยนรหัสผ่านสำเร็จ');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'requires-recent-login') {
        _toast('กรุณาเข้าสู่ระบบใหม่ก่อน แล้วลองอีกครั้ง');
      } else if (e.code == 'wrong-password') {
        _toast('รหัสผ่านเดิมไม่ถูกต้อง');
      } else if (e.code == 'weak-password') {
        _toast('รหัสผ่านใหม่อ่อนเกินไป (ควรยาวอย่างน้อย 6 ตัวอักษร)');
      } else {
        _toast('เปลี่ยนรหัสผ่านไม่สำเร็จ: ${e.code}');
      }
    } catch (e) {
      if (!mounted) return;
      _toast('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  InputDecoration _fieldDecoration({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outlineColor = isDark ? const Color(0xFF56615C) : const Color(0xFFD8D2CB);
    final textColor = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final subColor = isDark ? Colors.white70 : const Color(0xFF8E8176);

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: subColor),
      prefixIcon: Icon(icon, color: subColor),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.82),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: outlineColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF9AD0BA) : const Color(0xFF5F8F7A),
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD94E4E)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD94E4E), width: 1.4),
      ),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: subColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111715).withOpacity(0.88) : Colors.white.withOpacity(0.86);
    final titleColor = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF5E5A56);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: isDark ? Colors.white : const Color(0xFF2B2B2B),
        title: Text(
          'เปลี่ยนรหัสผ่าน',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF2B2B2B),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: PassBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.10) : Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                          color: Colors.black.withOpacity(isDark ? 0.24 : 0.12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ตั้งรหัสผ่านใหม่',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'กรอกรหัสผ่านเดิมเพื่อยืนยันตัวตน แล้วตั้งค่ารหัสผ่านใหม่ของคุณ',
                          style: TextStyle(
                            height: 1.35,
                            color: bodyColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _oldPassCtl,
                          obscureText: _obOld,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: titleColor),
                          decoration: _fieldDecoration(
                            context: context,
                            label: 'รหัสผ่านเดิม',
                            icon: Icons.lock_rounded,
                            obscure: _obOld,
                            onToggle: () => setState(() => _obOld = !_obOld),
                          ),
                          validator: (v) {
                            if ((v ?? '').isEmpty) return 'กรุณากรอกรหัสผ่านเดิม';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _newPassCtl,
                          obscureText: _obNew,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: titleColor),
                          decoration: _fieldDecoration(
                            context: context,
                            label: 'รหัสผ่านใหม่',
                            icon: Icons.lock_reset,
                            obscure: _obNew,
                            onToggle: () => setState(() => _obNew = !_obNew),
                          ),
                          validator: (v) {
                            final s = (v ?? '');
                            if (s.isEmpty) return 'กรุณากรอกรหัสผ่านใหม่';
                            if (s.length < 6) {
                              return 'รหัสผ่านใหม่ต้องยาวอย่างน้อย 6 ตัวอักษร';
                            }
                            if (s == _oldPassCtl.text) {
                              return 'รหัสผ่านใหม่ต้องไม่ซ้ำกับรหัสผ่านเดิม';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmCtl,
                          obscureText: _obConfirm,
                          textInputAction: TextInputAction.done,
                          style: TextStyle(color: titleColor),
                          onFieldSubmitted: (_) => _busy ? null : _submit(),
                          decoration: _fieldDecoration(
                            context: context,
                            label: 'ยืนยันรหัสผ่านใหม่',
                            icon: Icons.lock_reset,
                            obscure: _obConfirm,
                            onToggle: () => setState(() => _obConfirm = !_obConfirm),
                          ),
                          validator: (v) {
                            if ((v ?? '').isEmpty) return 'กรุณายืนยันรหัสผ่านใหม่';
                            if (v != _newPassCtl.text) return 'รหัสผ่านใหม่ไม่ตรงกัน';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _busy ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    'บันทึกรหัสผ่านใหม่',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
