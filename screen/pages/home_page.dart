import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../theme/watercolor_background.dart';
import '../../screens/notification_page.dart';
import '../../screens/recipe_detail_page.dart';
import '../../services/favorite_notification_service.dart';
import 'all_meals_page.dart';
import '../../screen/game_page.dart';

class MealItem {
  final String id;
  final String title;
  final String image;
  final String area;

  const MealItem({
    required this.id,
    required this.title,
    required this.image,
    required this.area,
  });
}

class HomePage extends StatefulWidget {
  final List<MealItem> favoriteMeals;
  final ValueChanged<MealItem> onToggleFavorite;

  const HomePage({
    super.key,
    required this.favoriteMeals,
    required this.onToggleFavorite,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color green = Color(0xFFD8F11B);

  bool _loadingThai = true;
  bool _loadingWorld = true;
  bool _loadingDessert = true;
  bool _loadingDrinks = true;

  List<MealItem> _thaiMeals = [];
  List<MealItem> _worldMeals = [];
  List<MealItem> _dessertMeals = [];
  List<MealItem> _drinkMeals = [];

  String currentAddress =
    "1518 ถนนประชาราษฎร์ 1 แขวงวงศ์สว่าง เขตบางซื่อ \nกรุงเทพมหานคร 10800";

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadThaiMeals(),
      _loadWorldMeals(),
      _loadDessertMeals(),
      _loadDrinkMeals(),
    ]);
  }

  Future<void> _loadThaiMeals() async {
    final uri =
        Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?a=Thai');
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final meals = (data['meals'] as List?) ?? [];

    if (!mounted) return;
    setState(() {
      _thaiMeals = meals.map((e) {
        final m = e as Map<String, dynamic>;
        return MealItem(
          id: (m['idMeal'] ?? '').toString(),
          title: (m['strMeal'] ?? '').toString(),
          image: (m['strMealThumb'] ?? '').toString(),
          area: 'Thai',
        );
      }).toList();
      _loadingThai = false;
    });
  }

  Future<void> _loadWorldMeals() async {
    final uri =
        Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=chicken');
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final meals = (data['meals'] as List?) ?? [];

    if (!mounted) return;
    setState(() {
      _worldMeals = meals.map((e) {
        final m = e as Map<String, dynamic>;
        return MealItem(
          id: (m['idMeal'] ?? '').toString(),
          title: (m['strMeal'] ?? '').toString(),
          image: (m['strMealThumb'] ?? '').toString(),
          area: (m['strArea'] ?? '').toString(),
        );
      }).toList();
      _loadingWorld = false;
    });
  }

  Future<void> _loadDessertMeals() async {
    final uri = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert',
    );
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final meals = (data['meals'] as List?) ?? [];

    if (!mounted) return;
    setState(() {
      _dessertMeals = meals.map((e) {
        final m = e as Map<String, dynamic>;
        return MealItem(
          id: (m['idMeal'] ?? '').toString(),
          title: (m['strMeal'] ?? '').toString(),
          image: (m['strMealThumb'] ?? '').toString(),
          area: 'Dessert',
        );
      }).toList();
      _loadingDessert = false;
    });
  }

  Future<void> _loadDrinkMeals() async {
    final urls = [
      'https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Ordinary_Drink',
      'https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Cocktail',
      'https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Shake',
      'https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Cocoa',
    ];

    final List<MealItem> allDrinks = [];

    for (final url in urls) {
      final uri = Uri.parse(url);
      final res = await http.get(uri);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final drinks = (data['drinks'] as List?) ?? [];

      for (final e in drinks) {
        final d = e as Map<String, dynamic>;

        allDrinks.add(
          MealItem(
            id: (d['idDrink'] ?? '').toString(),
            title: (d['strDrink'] ?? '').toString(),
            image: (d['strDrinkThumb'] ?? '').toString(),
            area: 'Drink',
          ),
        );
      }
    }

    final uniqueMap = {for (var item in allDrinks) item.id: item};

    if (!mounted) return;
    setState(() {
      _drinkMeals = uniqueMap.values.toList();
      _loadingDrinks = false;
    });
  }

  Future<void> openMap(String mealName) async {
    final query = Uri.encodeComponent('$mealName restaurant Thailand');
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: WatercolorBackground(seed: 42)),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadAll,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildBanner()),
                        const SizedBox(width: 10),
                        _HomeNotificationButton(isDark: isDark),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _sectionHeader(
                      context,
                      'อาหารไทย',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllMealsPage(
                              title: 'อาหารไทย',
                              meals: _thaiMeals,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    if (_loadingThai)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      _buildMealList(_thaiMeals),
                    const SizedBox(height: 24),
                    _sectionHeader(
                      context,
                      'อาหารนานาชาติ',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllMealsPage(
                              title: 'อาหารนานาชาติ',
                              meals: _worldMeals,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    if (_loadingWorld)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      _buildMealList(_worldMeals),
                    const SizedBox(height: 24),
                    _sectionHeader(
                      context,
                      'ของหวาน',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllMealsPage(
                              title: 'ของหวาน',
                              meals: _dessertMeals,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    if (_loadingDessert)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      _buildMealList(_dessertMeals),
                    const SizedBox(height: 24),
                    _sectionHeader(
                      context,
                      'เครื่องดื่ม',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllMealsPage(
                              title: 'เครื่องดื่ม',
                              meals: _drinkMeals,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    if (_loadingDrinks)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      _buildMealList(_drinkMeals, hideAddButton: true),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildBanner() {
  return Container(
    height: 70,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(40),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('assets/images/profile_girl.jpg'),
        ),
        const SizedBox(width: 12),
        Expanded(
  child: Row(
    children: [
      const Icon(
        Icons.location_on,
        size: 18,
        color: Colors.black87,
      ),
      const SizedBox(width: 4),
      Expanded(
        child: Text(
          currentAddress,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    ],
  ),
)
      ],
    ),
  );
}

  Widget _sectionHeader(
    BuildContext context,
    String title, {
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final subColor =
        isDark ? const Color(0xFFD0D7DE) : const Color(0xFF8E8176);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            'See More',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: subColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealList(List<MealItem> meals, {bool hideAddButton = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E2328) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF38414A) : const Color(0xFFEAE1D8);
    final titleColor = isDark ? Colors.white : const Color(0xFF2B2B2B);

    return SizedBox(
      height: 221,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: meals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = meals[i];
          return Container(
            width: 170,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  child: Image.network(
                    item.image,
                    height: 105,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Row(
                    children: [
                      if (!hideAddButton)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecipeDetailPage(mealId: item.id),
                              ),
                            );
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 179, 218, 174),
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color.fromARGB(255, 241, 240, 240),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => openMap(item.title),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Color.fromARGB(255, 250, 129, 1),
                          ),
                        ),
                      ),
                    ],
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

class _HomeNotificationButton extends StatelessWidget {
  const _HomeNotificationButton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final button = InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationPage()),
        );
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFF7F50),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.notifications_none_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );

    if (uid == null) return button;

    return StreamBuilder<int>(
      stream: FavoriteNotificationService.unreadCountStream(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            button,
            if (count > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
