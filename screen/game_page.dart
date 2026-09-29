
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../screens/recipe_detail_page.dart';

class GameMenuItem {
  final String id;
  final String title;
  final String image;
  final String area;

  const GameMenuItem({
    required this.id,
    required this.title,
    required this.image,
    required this.area,
  });
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Random _random = Random();

  String? _selectedMood;
  GameMenuItem? _selectedMenu;

  // เก็บรายการที่สุ่มได้
  List<GameMenuItem> _history = [];

  bool _loading = true;

  List<GameMenuItem> _thaiMeals = [];
  List<GameMenuItem> _worldMeals = [];
  List<GameMenuItem> _dessertMeals = [];
  List<GameMenuItem> _drinkMeals = [];

  @override
  void initState() {
    super.initState();
    _loadAllMenus();
  }

  Future<void> _loadAllMenus() async {
    setState(() => _loading = true);
    try {
      await Future.wait([
        _loadThaiMeals(),
        _loadWorldMeals(),
        _loadDessertMeals(),
        _loadDrinkMeals(),
      ]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('โหลดเมนูไม่สำเร็จ: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadThaiMeals() async {
    final uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?a=Thai');
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final meals = (data['meals'] as List?) ?? [];
    _thaiMeals = meals.map((e) {
      final m = e as Map<String, dynamic>;
      return GameMenuItem(
        id: (m['idMeal'] ?? '').toString(),
        title: (m['strMeal'] ?? '').toString(),
        image: (m['strMealThumb'] ?? '').toString(),
        area: 'Thai',
      );
    }).toList();
  }

  Future<void> _loadWorldMeals() async {
    final uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=chicken');
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final meals = (data['meals'] as List?) ?? [];
    _worldMeals = meals.map((e) {
      final m = e as Map<String, dynamic>;
      return GameMenuItem(
        id: (m['idMeal'] ?? '').toString(),
        title: (m['strMeal'] ?? '').toString(),
        image: (m['strMealThumb'] ?? '').toString(),
        area: (m['strArea'] ?? '').toString(),
      );
    }).toList();
  }

  Future<void> _loadDessertMeals() async {
    final uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert');
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final meals = (data['meals'] as List?) ?? [];
    _dessertMeals = meals.map((e) {
      final m = e as Map<String, dynamic>;
      return GameMenuItem(
        id: (m['idMeal'] ?? '').toString(),
        title: (m['strMeal'] ?? '').toString(),
        image: (m['strMealThumb'] ?? '').toString(),
        area: 'Dessert',
      );
    }).toList();
  }

  Future<void> _loadDrinkMeals() async {
    final urls = [
      'https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Ordinary_Drink',
      'https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Cocktail',
      'https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Shake',
      'https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Cocoa',
    ];
    final List<GameMenuItem> allDrinks = [];
    for (final url in urls) {
      final uri = Uri.parse(url);
      final res = await http.get(uri);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final rawDrinks = data['drinks'];
      final drinks = rawDrinks is List ? rawDrinks : <dynamic>[];
      for (final e in drinks) {
        final d = e as Map<String, dynamic>;
        allDrinks.add(GameMenuItem(
          id: (d['idDrink'] ?? '').toString(),
          title: (d['strDrink'] ?? '').toString(),
          image: (d['strDrinkThumb'] ?? '').toString(),
          area: 'Drink',
        ));
      }
    }
    final uniqueMap = {for (var item in allDrinks) item.id: item};
    _drinkMeals = uniqueMap.values.toList();
  }

  List<GameMenuItem> _allMenus() => [
        ..._thaiMeals,
        ..._worldMeals,
        ..._dessertMeals,
        ..._drinkMeals,
      ];

  void _randomTodayMenu() {
    final allMenus = _allMenus();
    if (allMenus.isEmpty) return;
    final menu = allMenus[_random.nextInt(allMenus.length)];
    setState(() {
      _selectedMood = null;
      _selectedMenu = menu;
      _history.insert(0, menu);
    });
    _showResultDialog(
      title: 'สุ่มเมนูวันนี้',
      subtitle: 'เมนูที่ระบบสุ่มให้คุณคือ',
      result: menu.title,
      color: const Color(0xFFF1B96A),
      icon: Icons.casino_rounded,
    );
  }

  void _openMoodPicker() {
    final moods = ['อารมณ์ดี', 'หิวมาก', 'อยากกินหวาน', 'อยากสดชื่น', 'อยากแซ่บ', 'ง่วง'];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF9F1E7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9C6B4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'เลือกอารมณ์ของคุณ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF6A4533)),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: moods.map((mood) {
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _randomByMood(mood);
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3EE),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFD2E2D7)),
                      ),
                      child: Text(
                        mood,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF5B463A)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _randomByMood(String mood) {
    List<GameMenuItem> menus = [];
    if (mood == 'อารมณ์ดี') {
      menus = [..._worldMeals, ..._dessertMeals];
    } else if (mood == 'หิวมาก') {
      menus = [..._thaiMeals, ..._worldMeals];
    } else if (mood == 'อยากกินหวาน') {
      menus = [..._dessertMeals];
    } else if (mood == 'อยากสดชื่น' || mood == 'ง่วง') {
      menus = [..._drinkMeals];
    } else if (mood == 'อยากแซ่บ') {
      menus = [..._thaiMeals];
    }
    if (menus.isEmpty) return;
    final menu = menus[_random.nextInt(menus.length)];
    setState(() {
      _selectedMood = mood;
      _selectedMenu = menu;
      _history.insert(0, menu);
    });
    _showResultDialog(
      title: 'สุ่มเมนูตามอารมณ์',
      subtitle: 'อารมณ์ตอนนี้: $mood',
      result: menu.title,
      color: const Color(0xFFBFE8A6),
      icon: Icons.emoji_emotions_rounded,
    );
  }

  void _pickPopular(String menuName) {
    final allMenus = _allMenus();
    final found = allMenus.where((e) => e.title == menuName).toList();
    final resultMenu = found.isNotEmpty ? found.first.title : menuName;
    if (found.isNotEmpty) {
      setState(() {
        _selectedMood = 'เมนูยอดนิยม';
        _selectedMenu = found.first;
      });
    }
    _showResultDialog(
      title: 'เมนูยอดนิยมวันนี้',
      subtitle: 'เมนูที่คุณเลือกคือ',
      result: resultMenu,
      color: const Color(0xFFE4F2DD),
      icon: Icons.local_fire_department_rounded,
    );
  }

  void _showResultDialog({
    required String title,
    required String subtitle,
    required String result,
    required Color color,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8F1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
          contentPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          title: Row(
            children: [
              CircleAvatar(radius: 18, backgroundColor: color, child: Icon(icon, color: const Color(0xFF6A4533))),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6A4533))),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subtitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF7B5B46))),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE1CCB8)),
                ),
                child: Text(
                  result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF5F3F2C)),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9FBFAF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: const Text('ตกลง', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F1EA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE7D8C9)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF7A5A45)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9EEDF),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE3C8B0), width: 1.2),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports_esports_rounded, color: Color(0xFF9B6B4E), size: 22),
                          SizedBox(width: 5),
                          Text('เกมสุ่มเมนู', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF5F3F2C))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                'ไม่รู้จะกินอะไรดี?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, height: 1.1, fontWeight: FontWeight.w900, color: Color(0xFF6B4533)),
              ),
              const SizedBox(height: 6),
              const Text(
                'ลองสุ่มเมนูดูสิ!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF7B5B46)),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.40),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFEAD6C5), width: 1.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 260,
                    child: Image.asset(
                      'assets/images/food.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color.fromARGB(255, 117, 69, 7),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(20),
                          child: const Text(
                            'ยังไม่พบรูปภาพ\nกรุณาเพิ่มไฟล์\nassets/images/food.png',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w700, color: Color(0xFF8B6A56)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _gameButton(
                      icon: Icons.casino_rounded,
                      title: 'สุ่มเมนูวันนี้',
                      subtitle: 'ให้ระบบสุ่มอาหารให้คุณ',
                      bg1: const Color(0xFFF6D58E),
                      bg2: const Color(0xFFF1B96A),
                      border: const Color(0xFFD79A52),
                      onTap: _randomTodayMenu,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _gameButton(
                      icon: Icons.emoji_emotions_rounded,
                      title: 'สุ่มเมนูตามอารมณ์',
                      subtitle: 'เลือกอารมณ์ แล้วให้แอปแนะนำ',
                      bg1: const Color(0xFFDDF6C7),
                      bg2: const Color(0xFFBFE8A6),
                      border: const Color(0xFF8CC67B),
                      onTap: _openMoodPicker,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (_selectedMenu != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE2D2C3)),
                  ),
                  child: Column(
                    children: [
                      const Text('ผลลัพธ์ล่าสุด', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF8A674E))),
                      const SizedBox(height: 6),
                      Text(
                        _selectedMenu!.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 2, fontWeight: FontWeight.w900, color: Color(0xFF5F3F2C)),
                      ),
                      if (_selectedMood != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'จากอารมณ์: $_selectedMood',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF7B5B46)),
                        ),
                      ],
                    ],
                  ),
                ),
              
              const SizedBox(height:20),

              // รายการเมนูที่สุ่มได้
              if (_history.isNotEmpty) ...[
                const Text(
                  'รายการที่สุ่มได้',
                  style: TextStyle(fontSize:20,fontWeight:FontWeight.bold),
                ),
                const SizedBox(height:10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _history.length,
                  itemBuilder: (context,index){
                    final item = _history[index];
                    return Card(
                      child: ListTile(
                        leading: Image.network(item.image,width:50,fit:BoxFit.cover),
                        title: Text(item.title),
                        trailing: ElevatedButton(
                          child: const Text('ดูสูตร'),
                          onPressed: (){
                            if(item.area!='Drink'){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecipeDetailPage(mealId: item.id),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 28),
              const Text('🔥 เมนูยอดนิยมวันนี้', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF6A4533))),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFF7E6C5), Color(0xFFE4F2DD)]),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE2D2C3)),
                ),
                child: Row(
                  children: [
                    Expanded(child: _PopularItem(emoji: '🍔', text: 'เบอร์เกอร์', )),
                    const _PopularDivider(),
                    Expanded(child: _PopularItem(emoji: '🍜', text: 'ราเมง',)),
                    const _PopularDivider(),
                    Expanded(child: _PopularItem(emoji: '🥗', text: 'สลัด',)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bg1,
    required Color bg2,
    required Color border,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bg1, bg2]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withOpacity(0.65),
              child: Icon(icon, color: const Color(0xFF8B5D42), size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, height: 1.1, fontWeight: FontWeight.w900, color: Color(0xFF5F3F2C)),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, height: 1.25, fontWeight: FontWeight.w600, color: Color(0xFF6F5647)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _PopularItem extends StatelessWidget {
  const _PopularItem({
    required this.emoji,
    required this.text,
  });

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF5E4536)),
              ),
            ),
          ],
        ),
    );
  }
}

class _PopularDivider extends StatelessWidget {
  const _PopularDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: const Color(0xFFD9C6B4),
    );
  }
}
