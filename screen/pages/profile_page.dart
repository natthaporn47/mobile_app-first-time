import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../screens/cache_actions.dart';
import '../../screens/change_password_page.dart';
import '../../screen/pages/edit_profile_page.dart';
import '../../screens/notification_page.dart';
import '../../screens/sign_in.dart';
import '../../theme/theme_controller.dart';
import '../../theme/watercolor_background.dart';

class ProfilePage extends StatelessWidget {
  final String? snackMessage;
  final VoidCallback? onGoHome;

  const ProfilePage({super.key, this.snackMessage, this.onGoHome});

  static const Color line = Color(0xFFEDE3D9);
  static const Color textSub = Color(0xFF8E8176);
  static const Color mint = Color(0xFF9FBFAF);
  static const Color mintDark = Color(0xFF5F8F7A);

  Future<void> showDeleteAccountDialog(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบบัญชี'),
          content: const Text(
            'คุณแน่ใจหรือไม่ว่าต้องการลบบัญชี?\nการลบบัญชีถาวรและไม่สามารถกู้คืนได้',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ลบถาวร'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || confirm != true) return;

    try {
      final deleted = await _deleteAccountFirebase(context);
      if (!context.mounted) return;
      if (!deleted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ลบบัญชีเรียบร้อยแล้ว')));
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'requires-recent-login'
                ? 'กรุณาเข้าสู่ระบบใหม่ก่อนลบบัญชี'
                : e.code == 'wrong-password' || e.code == 'invalid-credential'
                ? 'รหัสผ่านไม่ถูกต้อง'
                : 'ลบไม่สำเร็จ: ${e.code}',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  Future<bool> _deleteAccountFirebase(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final providers = user.providerData.map((info) => info.providerId).toSet();
    if (providers.contains('password')) {
      final password = await _requestPassword(context);
      final email = user.email;
      if (password == null) return false;
      if (email == null) {
        throw FirebaseAuthException(code: 'missing-email');
      }
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
    } else if (providers.contains('google.com')) {
      if (kIsWeb) {
        await user.reauthenticateWithPopup(GoogleAuthProvider());
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return false;
        final googleAuth = await googleUser.authentication;
        await user.reauthenticateWithCredential(
          GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          ),
        );
      }
    } else {
      throw FirebaseAuthException(code: 'unsupported-provider');
    }

    await _deleteUserSubcollection(user.uid, 'favorites');
    await _deleteUserSubcollection(user.uid, 'notifications');
    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
    await user.delete();
    return true;
  }

  Future<String?> _requestPassword(BuildContext context) async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('ยืนยันรหัสผ่าน'),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
            onSubmitted: (password) => Navigator.pop(dialogContext, password),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('ยืนยัน'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _deleteUserSubcollection(String uid, String name) async {
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(name);
    while (true) {
      final snapshot = await collection.limit(400).get();
      if (snapshot.docs.isEmpty) return;
      final batch = FirebaseFirestore.instance.batch();
      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
    }
  }

  String _fallbackName(User? user) {
    if (user == null) return 'ผู้ใช้';
    final displayName = (user.displayName ?? '').trim();
    if (displayName.isNotEmpty) return displayName;
    final email = (user.email ?? '').trim();
    if (email.contains('@')) return email.split('@').first;
    return 'ผู้ใช้';
  }

  String _fallbackSubtitle(User? user) {
    if (user == null) return '';
    final email = (user.email ?? '').trim();
    if (email.isNotEmpty) return email;
    return '@${_fallbackName(user).toLowerCase().replaceAll(' ', '.')}';
  }

  String _fallbackPhoto(User? user) {
    final photo = (user?.photoURL ?? '').trim();
    if (photo.isNotEmpty) return photo;
    return 'assets/images/profile_girl.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final tileIconColor = isDark ? scheme.secondary : mintDark;
    final sectionText = isDark ? const Color(0xFF8A7F74) : textSub;
    final dividerColor = isDark ? const Color(0xFFD8D2CB) : line;

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: WatercolorBackground(seed: 42)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: uid == null
                        ? null
                        : FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .snapshots(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data();
                      final name = (data?['name'] ?? _fallbackName(user))
                          .toString();
                      final subtitle =
                          (data?['email'] ?? _fallbackSubtitle(user))
                              .toString();
                      final photoUrl =
                          (data?['photoUrl'] ?? _fallbackPhoto(user))
                              .toString();

                      return _HeaderWithTopRightLogout(
                        name: name,
                        subtitle: subtitle,
                        imageProvider: AssetImage(photoUrl),
                        onEditProfile: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          );
                        },
                        onGoHome: onGoHome,
                        onLogout: () async {
                          await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const SignInScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _SectionLabel('บัญชี', color: sectionText),
                  const SizedBox(height: 8),
                  _CardGroup(
                    children: [
                      _MenuRow(
                        icon: Icons.edit_note_rounded,
                        iconColor: tileIconColor,
                        title: 'แก้ไขข้อมูลส่วนตัว',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          );
                        },
                      ),
                      _thinDivider(dividerColor),
                      _MenuRow(
                        icon: Icons.lock_outline_rounded,
                        iconColor: tileIconColor,
                        title: 'เปลี่ยนรหัสผ่าน',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SectionLabel('การใช้งาน', color: sectionText),
                  const SizedBox(height: 8),
                  _CardGroup(
                    children: [
                      _MenuRow(
                        icon: Icons.dark_mode_rounded,
                        iconColor: tileIconColor,
                        title: 'ธีม',
                        trailing: Transform.scale(
                          scale: 0.95,
                          child: Switch(
                            value: ThemeProvider.of(context).isNight,
                            onChanged: (_) =>
                                ThemeProvider.of(context).toggle(),
                            activeColor: const Color(0xFF2F2F2F),
                            inactiveThumbColor: const Color(0xFF2F2F2F),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white,
                            trackOutlineColor:
                                WidgetStateProperty.resolveWith<Color?>((
                                  states,
                                ) {
                                  return const Color(0xFF2F2F2F);
                                }),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        onTap: () => ThemeProvider.of(context).toggle(),
                      ),
                      _thinDivider(dividerColor),
                      _MenuRow(
                        icon: Icons.notifications_none_rounded,
                        iconColor: tileIconColor,
                        title: 'การแจ้งเตือน',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationPage(),
                            ),
                          );
                        },
                      ),
                      _thinDivider(dividerColor),
                      _MenuRow(
                        icon: Icons.delete_sweep_rounded,
                        iconColor: tileIconColor,
                        title: 'ล้างแคช',
                        onTap: () => CacheActions.showClearCacheDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SectionLabel('อื่น ๆ', color: sectionText),
                  const SizedBox(height: 8),
                  _CardGroup(
                    children: [
                      _MenuRow(
                        icon: Icons.delete_forever_rounded,
                        iconColor: scheme.error,
                        title: 'ลบบัญชี',
                        trailingColor: scheme.error,
                        onTap: () => showDeleteAccountDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  static Widget _thinDivider(Color color) =>
      Divider(height: 1, thickness: 1, color: color);
}

class _HeaderWithTopRightLogout extends StatelessWidget {
  const _HeaderWithTopRightLogout({
    required this.name,
    required this.subtitle,
    required this.imageProvider,
    required this.onEditProfile,
    required this.onLogout,
    this.onGoHome,
  });

  final String name;
  final String subtitle;
  final ImageProvider imageProvider;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;
  final VoidCallback? onGoHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final panelColor = isDark
        ? const Color(0xFFE7E5E1).withOpacity(0.78)
        : Colors.white.withOpacity(0.72);
    final softPanelColor = isDark
        ? const Color(0xFFF1EEEA).withOpacity(0.88)
        : Colors.white.withOpacity(0.75);
    final borderColor = isDark ? const Color(0xFFD8D2CB) : ProfilePage.line;
    final mainText = isDark ? const Color(0xFF3A352F) : scheme.onSurface;
    final subText = isDark
        ? const Color(0xFF8A7F74)
        : scheme.onSurface.withOpacity(0.60);
    final mint = isDark ? const Color(0xFFA9C6B6) : ProfilePage.mint;
    final mintDark = isDark ? const Color(0xFF6E9C87) : ProfilePage.mintDark;

    return Container(
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.08 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Spacer(),
                _LogoutPill(onTap: onLogout, label: 'Logout'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: mintDark, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage(
                      'assets/images/profile_girl.jpg',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: mainText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: subText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: onEditProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mint,
                            foregroundColor: isDark
                                ? const Color(0xFF3A352F)
                                : Colors.white,
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
                      color: softPanelColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(Icons.home_rounded, size: 18, color: subText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: softPanelColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  // _StatItem(icon: Icons.bookmark_rounded, iconColor: mintDark, value: '43', label: 'สูตรที่บันทึกไว้', isDarkCreamMode: isDark),
                  // _VLine(color: borderColor),
                  // _StatItem(icon: Icons.local_cafe_rounded, iconColor: mintDark, value: '56', label: 'ร้านที่รีวิว', isDarkCreamMode: isDark),
                  // _VLine(color: borderColor),
                  _FavoriteStatItem(
                    iconColor: const Color(0xFFE59B8D),
                    isDarkCreamMode: isDark,
                    label: 'รายการโปรด',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteStatItem extends StatelessWidget {
  const _FavoriteStatItem({
    required this.iconColor,
    required this.isDarkCreamMode,
    required this.label,
  });
  final Color iconColor;
  final bool isDarkCreamMode;
  final String label;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final mainText = isDarkCreamMode
        ? const Color(0xFF3A352F)
        : Theme.of(context).colorScheme.onSurface;
    final subText = isDarkCreamMode
        ? const Color(0xFF8A7F74)
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.68);

    if (user == null) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_rounded, size: 16, color: iconColor),
                  const SizedBox(width: 6),
                  Text(
                    '0',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: mainText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: subText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          final count = snapshot.data?.docs.length ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_rounded, size: 16, color: iconColor),
                    const SizedBox(width: 6),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: mainText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: subText,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LogoutPill extends StatelessWidget {
  const _LogoutPill({required this.onTap, required this.label});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFFD8D2CB) : ProfilePage.line;
    final textColor = isDark
        ? const Color(0xFF8A7F74)
        : scheme.onSurface.withOpacity(0.60);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFFF3EFEB).withOpacity(0.95)
              : scheme.surface.withOpacity(0.55),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout_rounded, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: textColor,
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
    required this.isDarkCreamMode,
  });
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDarkCreamMode;

  @override
  Widget build(BuildContext context) {
    final mainText = isDarkCreamMode
        ? const Color(0xFF3A352F)
        : Theme.of(context).colorScheme.onSurface;
    final subText = isDarkCreamMode
        ? const Color(0xFF8A7F74)
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.68);

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
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: mainText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: subText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VLine extends StatelessWidget {
  const _VLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 44, color: color);
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, {required this.color});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
  );
}

class _CardGroup extends StatelessWidget {
  const _CardGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFFF2EFEB).withOpacity(0.90)
            : scheme.surface.withOpacity(0.90),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFFD8D2CB) : ProfilePage.line,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.08 : 0.03),
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
    this.trailing,
    this.trailingColor,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFF3A352F) : scheme.onSurface;
    final arrowColor =
        trailingColor ??
        (isDark
            ? const Color(0xFF9A8F84)
            : ProfilePage.mintDark.withOpacity(0.55));

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      onTap: onTap,
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: titleColor,
        ),
      ),
      trailing:
          trailing ?? Icon(Icons.chevron_right_rounded, color: arrowColor),
    );
  }
}
