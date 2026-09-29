import 'package:flutter/material.dart';
import '../constant/my_constant.dart'; // ดึงค่าสีและสไตล์จากไฟล์ที่ระบุ
import 'package:firebase_auth/firebase_auth.dart';
import 'sign_in.dart';

class ProfileScreen extends StatefulWidget {
  final String? snackMessage;
  const ProfileScreen({super.key, this.snackMessage});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _snackShown = false;

  @override
  void initState() {
    super.initState();

    // ✅ เด้งแจ้งเตือนหลังหน้า Profile วาดเสร็จ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final msg = widget.snackMessage;
      if (msg == null || msg.trim().isEmpty) return;
      if (_snackShown) return;
      _snackShown = true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE8F5E9),
          content: Text(
            msg,
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
final email = user?.email ?? '-';
final name = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
    ? user.displayName!
    : (email.contains('@') ? email.split('@')[0] : email);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Profile", style: headingTextStyle),
        centerTitle: false,
actions: [
  TextButton.icon(
    onPressed: () async {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    },
    icon: Icon(Icons.logout, color: primaryColor, size: 20),
    label: Text(
      "Logout",
      style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
    ),
  ),
  const SizedBox(width: 8),
],

      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            // ตรวจสอบชื่อไฟล์ให้ตรงกับที่ตั้งไว้ใน pubspec.yaml นะครับ
            image: AssetImage('assets/images/aa.jpg'),
            fit: BoxFit.cover, 
            opacity: 0.4,// ทำให้ภาพเต็มหน้าจอ
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // จัดกึ่งกลางข้อมูลส่วนตัว
              children: [
                const SizedBox(height: 20),

                // --- ส่วนรูปโปรไฟล์พร้อมปุ่มบวกสีม่วง ---
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(255, 247, 77, 15),
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(
                          'assets/images/profile_girl.jpg',
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 66, 56, 252),
                          shape: BoxShape.circle,
                          border: Border.all(color: secondaryColor, width: 3),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- ข้อมูลส่วนตัว (จัดกึ่งกลางตามรูป) ---
                Text(
  name,
  style: headingTextStyle.copyWith(fontSize: 22),
),
const SizedBox(height: 4),
Text(
  "^_^",
  style: bodyTextStyle.copyWith(
    color: Colors.grey.shade700,
    fontSize: 16,
  ),
),
const SizedBox(height: 2),
Text(
  email,
  style: bodyTextStyle.copyWith(
    color: const Color.fromARGB(255, 101, 100, 100),
    fontSize: 16,
  ),
),


                const SizedBox(height: 30),

                // --- รายการเมนูต่างๆ ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Account"),
                    // Edit Profile: ใช้ไอคอนดินสอและลูกศรชี้ขวาตามรูปภาพที่ต้องการ
                    _buildMenuField(
                      Icons.edit_outlined,
                      "Edit Profile",
                      style: bodyTextStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    _buildSectionTitle("Settings"),
                    _buildMenuField(
                      Icons.notifications_none_outlined,
                      "Notifications",
                    ),
                    _buildMenuField(Icons.language_outlined, "Language"),
                    _buildToggleField(
                      Icons.nightlight_round,
                      "Dark mode",
                      true,
                    ),

                    _buildSectionTitle("Security & Info"),
                    _buildMenuField(
                      Icons.headset_mic_outlined,
                      "Help Center / Support",
                    ),
                    _buildMenuField(Icons.lock_outline, "Add Pin"),
                    _buildMenuField(Icons.security_outlined, "Privacy Policy"),
                    _buildMenuField(Icons.info_outline, "About Us"),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- ฟังก์ชันสร้างแถบเมนู (ใช้สีฟ้าอ่อนจาก darkBackgroundColor ในไฟล์ my_constant.dart) ---
  Widget _buildMenuField(IconData icon, String text, {TextStyle? style}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        // ใช้สีฟ้าอ่อน (213, 240, 243) จากไฟล์ที่คุณส่งมา
        color: darkBackgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor.withOpacity(0.6), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style:
                  style ?? bodyTextStyle.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade400,
            size: 16,
          ), // ลูกศรชี้ขวาตามรูป
        ],
      ),
    );
  }

  // --- ฟังก์ชันสำหรับแถบ Dark Mode (พื้นหลังเมนูสีฟ้าอ่อน + ไอคอนแดง) ---
  Widget _buildToggleField(IconData icon, String text, bool isEnabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: darkBackgroundColor, // สีฟ้าอ่อนตามไฟล์
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 207, 207, 207),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 253, 252, 252),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: bodyTextStyle.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (v) {},
            activeColor: const Color.fromARGB(255, 157, 157, 157),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
      child: Text(
        title,
        style: bodyTextStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      height: 65,
      decoration: BoxDecoration(
        color: primaryColor, // สีดำตามไฟล์
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home_outlined, color: Colors.white70),
          Icon(Icons.grid_view, color: Colors.white70),
          Icon(Icons.person, color: Colors.white),
        ],
      ),
    );
  }
}
