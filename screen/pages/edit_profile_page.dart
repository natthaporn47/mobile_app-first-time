import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/watercolor_background.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtl = TextEditingController();
  final TextEditingController _emailCtl = TextEditingController();
  final TextEditingController _phoneCtl = TextEditingController();
  final TextEditingController _birthCtl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String _gender = 'female';

  String _photoUrl = 'assets/images/profile_girl.jpg';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    _birthCtl.dispose();
    super.dispose();
  }

  String _fallbackName(User? user) {
    if (user == null) return 'ผู้ใช้';
    final displayName = (user.displayName ?? '').trim();
    if (displayName.isNotEmpty) return displayName;
    final email = (user.email ?? '').trim();
    if (email.contains('@')) return email.split('@').first;
    return 'ผู้ใช้';
  }

  String _fallbackPhoto(User? user) {
    final photo = (user?.photoURL ?? '').trim();
    if (photo.isNotEmpty) return photo;
    return _photoUrl;
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();

      if (data != null) {
        _nameCtl.text = (data['name'] ?? _fallbackName(user)).toString();
        _emailCtl.text = (data['email'] ?? user.email ?? '').toString();
        _phoneCtl.text = (data['phone'] ?? '').toString();
        _birthCtl.text = (data['birthDate'] ?? '').toString();
        _gender = (data['gender'] ?? 'female').toString();

        final photo = (data['photoUrl'] ?? '').toString();
        _photoUrl = photo.isNotEmpty ? photo : _fallbackPhoto(user);
      } else {
        _nameCtl.text = _fallbackName(user);
        _emailCtl.text = user.email ?? '';
        _photoUrl = _fallbackPhoto(user);
      }
    } catch (_) {
      _nameCtl.text = _fallbackName(user);
      _emailCtl.text = user.email ?? '';
      _photoUrl = _fallbackPhoto(user);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('โหลดข้อมูลโปรไฟล์ไม่สำเร็จ กำลังใช้ข้อมูลบัญชีแทน'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อน')));
      return;
    }

    setState(() => _saving = true);

    try {
      final cleanName = _nameCtl.text.trim();
      final username = cleanName.isEmpty
          ? '@${(user.email ?? 'user').split('@').first}'
          : '@${cleanName.toLowerCase().replaceAll(' ', '.')}';

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': cleanName,
        'username': username,
        'email': _emailCtl.text.trim(),
        'phone': _phoneCtl.text.trim(),
        'birthDate': _birthCtl.text.trim(),
        'gender': _gender,
        'photoUrl': _photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2002, 8, 12),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year, now.month, now.day),
    );

    if (picked != null) {
      setState(() {
        _birthCtl.text =
            '${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(child: WatercolorBackground(seed: 42)),
            Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final subtitleColor = isDark ? Colors.white70 : Colors.white70;
    final labelColor = isDark ? Colors.white : const Color(0xFF7E756E);
    final inputTextColor = isDark
        ? const Color(0xFFF5F7FA)
        : const Color(0xFF2B2B2B);
    final hintColor = isDark
        ? const Color(0xFFB8C2CC)
        : const Color(0xFF9C958E);
    final cardColor = isDark
        ? const Color(0xFF1E2328).withOpacity(0.96)
        : Colors.white.withOpacity(0.92);
    final softColor = isDark
        ? const Color(0xFF2D343C).withOpacity(1.0)
        : Colors.white.withOpacity(0.90);
    final borderColor = isDark
        ? const Color(0xFF55606D)
        : const Color(0xFFE7DDD3);

    const accent = Color(0xFF9FBFAF);
    const accentDark = Color(0xFF6E9C87);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: WatercolorBackground(seed: 42)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                children: [
                  _TopBar(titleColor: titleColor),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
                          decoration: const BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                          ),
                          child: Column(
                            children: [
                              // แก้ตรงนี้: ไม่มีไอคอนกล้อง ไม่มีวงกลมเล็ก และมีกรอบรอบรูป
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: AssetImage(
                                    'assets/images/profile_girl.jpg',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'แก้ไขโปรไฟล์',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'ปรับข้อมูลส่วนตัวของคุณ',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _fieldLabel('ชื่อผู้ใช้', labelColor),
                                const SizedBox(height: 8),
                                _profileField(
                                  controller: _nameCtl,
                                  hint: 'กรอกชื่อผู้ใช้',
                                  icon: Icons.person_outline_rounded,
                                  accent: accentDark,
                                  fillColor: softColor,
                                  borderColor: borderColor,
                                  validator: (v) => (v ?? '').trim().isEmpty
                                      ? 'กรุณากรอกชื่อผู้ใช้'
                                      : null,
                                ),
                                const SizedBox(height: 14),
                                _fieldLabel('อีเมล', labelColor),
                                const SizedBox(height: 8),
                                _profileField(
                                  controller: _emailCtl,
                                  hint: 'กรอกอีเมล',
                                  icon: Icons.mail_outline_rounded,
                                  accent: accentDark,
                                  fillColor: softColor,
                                  borderColor: borderColor,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if ((v ?? '').trim().isEmpty) {
                                      return 'กรุณากรอกอีเมล';
                                    }
                                    if (!v!.contains('@')) {
                                      return 'รูปแบบอีเมลไม่ถูกต้อง';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                _fieldLabel('เบอร์โทรศัพท์', labelColor),
                                const SizedBox(height: 8),
                                _profileField(
                                  controller: _phoneCtl,
                                  hint: 'กรอกเบอร์โทรศัพท์',
                                  icon: Icons.phone_android_rounded,
                                  accent: accentDark,
                                  fillColor: softColor,
                                  borderColor: borderColor,
                                  keyboardType: TextInputType.phone,
                                  validator: (v) {
                                    if ((v ?? '').trim().isEmpty) {
                                      return 'กรุณากรอกเบอร์โทรศัพท์';
                                    }
                                    if ((v ?? '').length < 9) {
                                      return 'กรุณากรอกเบอร์ให้ครบ';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                _fieldLabel('วันเดือนปีเกิด', labelColor),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pickBirthDate,
                                  borderRadius: BorderRadius.circular(999),
                                  child: IgnorePointer(
                                    child: _profileField(
                                      controller: _birthCtl,
                                      hint: 'DD / MM / YYYY',
                                      icon: Icons.calendar_month_rounded,
                                      accent: accentDark,
                                      fillColor: softColor,
                                      borderColor: borderColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'เพศ',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: labelColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      186,
                                      192,
                                      198,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<String>(
                                          value: 'male',
                                          groupValue: _gender,
                                          activeColor: accentDark,
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            'ชาย',
                                            style: TextStyle(
                                              color: titleColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          onChanged: (v) =>
                                              setState(() => _gender = v!),
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<String>(
                                          value: 'female',
                                          groupValue: _gender,
                                          activeColor: accentDark,
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            'หญิง',
                                            style: TextStyle(
                                              color: titleColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          onChanged: (v) =>
                                              setState(() => _gender = v!),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _saving ? null : _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                    child: _saving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'บันทึกข้อมูล',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _profileField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color accent,
    required Color fillColor,
    required Color borderColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color.fromARGB(255, 186, 192, 198),
        prefixIcon: Container(
          margin: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: accent, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.titleColor});
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE7DDD3)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
      ],
    );
  }
}
