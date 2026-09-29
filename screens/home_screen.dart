import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tabIndex = 0;

  String _todayText = "";
  int _streakDays = 1;

  bool _hasNotification = true;

  @override
  void initState() {
    super.initState();
    _initDateAndStreak();
  }

  Future<void> _initDateAndStreak() async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final formatted = DateFormat('EEEE, d MMMM').format(today);

    final lastOpenMillis = prefs.getInt('last_open_date');
    int streak = prefs.getInt('streak_days') ?? 0;

    if (lastOpenMillis == null) {
      streak = 1;
      await prefs.setInt('streak_days', streak);
      await prefs.setInt('last_open_date', today.millisecondsSinceEpoch);
    } else {
      final lastOpen = DateTime.fromMillisecondsSinceEpoch(lastOpenMillis);
      final lastOpenDate = DateTime(lastOpen.year, lastOpen.month, lastOpen.day);
      final diffDays = today.difference(lastOpenDate).inDays;

      if (diffDays == 0) {
        // same day
      } else if (diffDays == 1) {
        streak = (streak <= 0) ? 1 : (streak + 1);
        await prefs.setInt('streak_days', streak);
        await prefs.setInt('last_open_date', today.millisecondsSinceEpoch);
      } else {
        streak = 1;
        await prefs.setInt('streak_days', streak);
        await prefs.setInt('last_open_date', today.millisecondsSinceEpoch);
      }
    }

    if (!mounted) return;
    setState(() {
      _todayText = formatted;
      _streakDays = streak;
    });
  }

  void _go(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      // ✅ เปลี่ยนจาก Column เป็น Stack เพื่อใส่พื้นหลังรูป
      body: Stack(
        children: [
          // ✅ พื้นหลังโดเรม่อน (ทั้งหน้า)
          Positioned.fill(
            child: Image.asset(
              'assets/images/aa.jpg', // << ใส่รูปโดเรม่อนของคุณตรงนี้
              fit: BoxFit.cover,
            ),
          ),

          // ✅ overlay โปร่งๆ ทำให้อ่านง่าย (ปรับได้)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.55),
            ),
          ),

          // ✅ เนื้อหาจริงของหน้า
          Column(
            children: [
              // ---------------- HEADER ----------------
              SizedBox(
                height: 210,
                child: Stack(
                  children: [
                    Container(
                      height: 170,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8EC5FC), // ✅ สีหัวใหม่ (เปลี่ยนได้)
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(26),
                          bottomRight: Radius.circular(26),
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ซ้าย: ชื่อ + วันที่ + streak
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Natthaporn Wangsuk",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _todayText.isEmpty ? "Loading..." : _todayText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _StreakChip(days: _streakDays),
                                ],
                              ),
                            ),

                            // ขวา: กระดิ่ง (บน) + โปรไฟล์ (ล่าง)
                            Column(
                              children: [
                                Stack(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() => _hasNotification = false);
                                        _go(context, const NotificationScreen());
                                      },
                                      borderRadius: BorderRadius.circular(999),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Icon(
                                          Icons.notifications_none_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (_hasNotification)
                                      Positioned(
                                        right: 3,
                                        top: 3,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // ✅ รูปโปรไฟล์ใหญ่ขึ้น
                                Container(
                                  width: 78,
                                  height: 78,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white, width: 2.5),
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 10,
                                        offset: Offset(0, 6),
                                        color: Color(0x22000000),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.asset(
                                    'assets/images/profile_girl.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ✅ Search card ลอย
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 0,
                      child: _SearchPointCard(
                        onTap: () => _go(context, const SearchScreen()),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ----------------- MENU GRID -----------------
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    padding: EdgeInsets.only(bottom: topPadding > 0 ? 8 : 8),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                    children: [
                      _FeatureCard(
                        title: "Series",
                        subtitle: "Recommended\nContinue watching",
                        icon: Icons.movie_filter_outlined,
                        tint: const Color(0xFFE0F2FE),
                        onTap: () => _go(context, const SeriesScreen()),
                      ),
                      _FeatureCard(
                        title: "Novel",
                        subtitle: "Top picks\nContinue reading",
                        icon: Icons.menu_book_outlined,
                        tint: const Color(0xFFFFF7ED),
                        onTap: () => _go(context, const NovelScreen()),
                      ),
                      _FeatureCard(
                        title: "Relax",
                        subtitle: "Breathing / Music\n3–5 min",
                        icon: Icons.self_improvement_outlined,
                        tint: const Color(0xFFECFCCB),
                        onTap: () => _go(context, const RelaxScreen()),
                      ),
                      _FeatureCard(
                        title: "My List",
                        subtitle: "Saved series\n& novels",
                        icon: Icons.bookmark_added_outlined,
                        tint: const Color(0xFFFFE4E6),
                        onTap: () => _go(context, const MyListScreen()),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ----------------- BOTTOM NAV -----------------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _BottomBar(
                  currentIndex: tabIndex,
                  onChanged: (i) => setState(() => tabIndex = i),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ---------------- Components ---------------- */

class _SearchPointCard extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchPointCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(blurRadius: 18, offset: Offset(0, 10), color: Color(0x22000000)),
            ],
          ),
          child: Row(
            children: const [
              Icon(Icons.search, color: Colors.black54),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Search",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  final int days;
  const _StreakChip({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, size: 16, color: Color(0xFFFFD37A)),
          const SizedBox(width: 6),
          Text(
            "$days days streak",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(blurRadius: 16, offset: Offset(0, 10), color: Color(0x16000000)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                height: 1.15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(221, 61, 61, 61),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _BottomBar({required this.currentIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(blurRadius: 18, offset: Offset(0, 10), color: Color(0x22000000)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIcon(icon: Icons.home_rounded, selected: currentIndex == 0, onTap: () => onChanged(0)),
          _NavIcon(icon: Icons.grid_view_rounded, selected: currentIndex == 1, onTap: () => onChanged(1)),
          _NavIcon(icon: Icons.person_rounded, selected: currentIndex == 2, onTap: () => onChanged(2)),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF111827) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: selected ? Colors.white : const Color(0xFF94A3B8)),
      ),
    );
  }
}

/* ---------------- Placeholder Screens ---------------- */
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Notification Screen")));
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Search Screen")));
}

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Series Screen")));
}

class NovelScreen extends StatelessWidget {
  const NovelScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Novel Screen")));
}

class RelaxScreen extends StatelessWidget {
  const RelaxScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Relax Screen")));
}

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("My List Screen")));
}
