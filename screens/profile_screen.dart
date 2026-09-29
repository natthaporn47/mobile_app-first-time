import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ ปรับ path ให้ตรงกับของคุณ
import '../screens/sign_in.dart';          // lib/screens/sign_in.dart
import '../screen/home_shell.dart';        // lib/screen/home_shell.dart

class ProfilePage extends StatelessWidget {
  final String? snackMessage;

  const ProfilePage({super.key, this.snackMessage});

  // Theme colors (match the reference)
  static const Color bg = Color(0xFFFFF6EF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFEDE3D9);

  static const Color textMain = Color(0xFF2B2B2B);
  static const Color textSub = Color(0xFF8E8176);

  static const Color mint = Color(0xFF9FBFAF);
  static const Color mintDark = Color(0xFF5F8F7A);

  @override
  Widget build(BuildContext context) {
    // ✅ เด้ง SnackBar ตอนเข้าหน้า Profile (ครั้งเดียวหลัง build)
    if (snackMessage != null && snackMessage!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackMessage!),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderWithTopRightLogout(
                name: 'สุภัทรา',
                username: '@cooking.supattra',
                imageProvider: const NetworkImage(
                  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
                ),
                onEditProfile: () => _snack(context, 'แก้ไขโปรไฟล์'),
                onLogout: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (route) => false,
                  );
                },
                onGoHome: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeShell()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 14),

              const _SectionLabel('บัญชี'),
              const SizedBox(height: 8),
              _CardGroup(
                children: [
                  _MenuRow(
                    icon: Icons.edit_note_rounded,
                    iconColor: mintDark,
                    title: 'แก้ไขข้อมูลส่วนตัว',
                    onTap: () => _snack(context, 'แก้ไขข้อมูลส่วนตัว'),
                  ),
                  _thinDivider(),
                  _MenuRow(
                    icon: Icons.lock_outline_rounded,
                    iconColor: mintDark,
                    title: 'เปลี่ยนรหัสผ่าน',
                    onTap: () => _snack(context, 'เปลี่ยนรหัสผ่าน'),
                  ),
                  _thinDivider(),
                  _MenuRow(
                    icon: Icons.email_outlined,
                    iconColor: mintDark,
                    title: 'เปลี่ยนอีเมล',
                    onTap: () => _snack(context, 'เปลี่ยนอีเมล'),
                  ),
                  _thinDivider(),
                  _MenuRow(
                    icon: Icons.link_rounded,
                    iconColor: mintDark,
                    title: 'เชื่อมต่อ Facebook / Google',
                    onTap: () => _snack(context, 'เชื่อมต่อบัญชี'),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const _SectionLabel('การใช้งาน'),
              const SizedBox(height: 8),
              _CardGroup(
                children: [
                  _MenuRow(
                    icon: Icons.language_rounded,
                    iconColor: mintDark,
                    title: 'ภาษา',
                    onTap: () => _snack(context, 'ภาษา'),
                  ),
                  _thinDivider(),
                  _MenuRow(
                    icon: Icons.nights_stay_rounded,
                    iconColor: mintDark,
                    title: 'ธีม',
                    onTap: () => _snack(context, 'ธีม'),
                  ),
                  _thinDivider(),
                  _MenuRow(
                    icon: Icons.notifications_none_rounded,
                    iconColor: mintDark,
                    title: 'การแจ้งเตือน',
                    onTap: () => _snack(context, 'การแจ้งเตือน'),
                  ),
                  _thinDivider(),
                  _MenuRow(
                    icon: Icons.delete_sweep_rounded,
                    iconColor: mintDark,
                    title: 'ล้างแคช',
                    onTap: () => _snack(context, 'ล้างแคช'),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const _SectionLabel('อื่น ๆ'),
              const SizedBox(height: 8),
              _CardGroup(
                children: [
                  _MenuRow(
                    icon: Icons.delete_forever_rounded,
                    iconColor: const Color(0xFFD94E4E),
                    title: 'ลบบัญชี',
                    trailingColor: const Color(0xFFD94E4E),
                    onTap: () => _snack(context, 'ลบบัญชี'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Widget _thinDivider() => const Divider(height: 1, thickness: 1, color: line);
}

/// ---------------- HEADER (with logout button at top-right) ----------------
class _HeaderWithTopRightLogout extends StatelessWidget {
  const _HeaderWithTopRightLogout({
    required this.name,
    required this.username,
    required this.imageProvider,
    required this.onEditProfile,
    required this.onLogout,
    required this.onGoHome,
  });

  final String name;
  final String username;
  final ImageProvider imageProvider;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEAF3EE),
            Color(0xFFF7F1EA),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ProfilePage.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    _LogoutPill(onTap: onLogout),
                  ],
                ),
                const SizedBox(height: 6),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 28, backgroundImage: imageProvider),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: ProfilePage.textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: ProfilePage.textSub,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 36,
                            child: ElevatedButton.icon(
                              onPressed: onEditProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ProfilePage.mint,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                              ),
                              icon: const Icon(Icons.edit_rounded, size: 18),
                              label: const Text(
                                'แก้ไขโปรไฟล์',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    InkWell(
                      onTap: onGoHome,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ProfilePage.line),
                        ),
                        child: const Icon(Icons.home_rounded,
                            size: 18, color: ProfilePage.textSub),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: ProfilePage.card.withOpacity(0.70),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: ProfilePage.line),
                  ),
                  child: Row(
                    children: const [
                      _StatItem(
                        icon: Icons.bookmark_rounded,
                        iconColor: ProfilePage.mintDark,
                        value: '43',
                        label: 'สูตรที่บันทึกไว้',
                      ),
                      _VLine(),
                      _StatItem(
                        icon: Icons.local_cafe_rounded,
                        iconColor: ProfilePage.mintDark,
                        value: '56',
                        label: 'ร้านที่รีวิว',
                      ),
                      _VLine(),
                      _StatItem(
                        icon: Icons.favorite_rounded,
                        iconColor: Color(0xFFE59B8D),
                        value: '189',
                        label: 'รายการโปรด',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutPill extends StatelessWidget {
  const _LogoutPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: ProfilePage.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.logout_rounded, size: 16, color: ProfilePage.textSub),
            SizedBox(width: 6),
            Text(
              'ออกจากระบบ',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: ProfilePage.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: ProfilePage.textMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ProfilePage.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VLine extends StatelessWidget {
  const _VLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      color: ProfilePage.line,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: ProfilePage.textSub,
      ),
    );
  }
}

class _CardGroup extends StatelessWidget {
  const _CardGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ProfilePage.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ProfilePage.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailingColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      onTap: onTap,
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: ProfilePage.textMain,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: trailingColor ?? ProfilePage.mintDark.withOpacity(0.55),
      ),
    );
  }
}