import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/recipes_page.dart';
import 'pages/favorite_page.dart';
import 'pages/profile_page.dart';
import 'game_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final List<MealItem> _favoriteMeals = [];

  void _goHome() => setState(() => _index = 0);

  void _toggleFavorite(MealItem item) {
    setState(() {
      final exists = _favoriteMeals.any((e) => e.id == item.id);

      if (exists) {
        _favoriteMeals.removeWhere((e) => e.id == item.id);
      } else {
        _favoriteMeals.add(item);
      }
    });
  }

  void _openGamePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomePage(
        favoriteMeals: _favoriteMeals,
        onToggleFavorite: _toggleFavorite,
      ),
      const RecipesPage(),
      const FavoritePage(),
      ProfilePage(onGoHome: _goHome),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: tabs),
      ),

      floatingActionButton: (_index == 0 || _index == 1) 
      ? InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: _openGamePage,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD08A2E), Color(0xFF9A5B17)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF7CDB2A), Color(0xFF2FA80F)],
              ),
              border: Border.all(color: const Color(0xFF2E7D12), width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 6,
                  left: 18,
                  right: 18,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.white.withOpacity(0.22),
                    ),
                  ),
                ),
                const Text(
                  'Play',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ):null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: _HungryHubBottomMenu(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _HungryHubBottomMenu extends StatelessWidget {
  const _HungryHubBottomMenu({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem(icon: Icons.home_rounded, label: 'หน้าหลัก'),
      _MenuItem(icon: Icons.menu_book_rounded, label: 'สูตรอาหาร'),
      _MenuItem(icon: Icons.favorite_rounded, label: 'รายการโปรด'),
      _MenuItem(icon: Icons.person_rounded, label: 'โปรไฟล์ของฉัน'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E8),
        border: Border(top: BorderSide(color: Colors.brown.shade100)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (i) {
            final selected = i == currentIndex;
            final color = selected
                ? Colors.brown.shade700
                : Colors.brown.shade300;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? const Color(0xFFF1D6C6)
                            : Colors.transparent,
                      ),
                      child: Icon(items[i].icon, size: 20, color: color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;

  _MenuItem({required this.icon, required this.label});
}
