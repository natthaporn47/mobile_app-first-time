import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../services/mealdb_api.dart';
import 'recipe_detail_page.dart';

/// ✅ เพิ่ม enum ให้ HomePage เรียกได้
enum RecipesApiMode { search, category }

class RecipesApiPage extends StatefulWidget {
  const RecipesApiPage({
    super.key,
    this.mode = RecipesApiMode.search,
    this.title = 'Recipes (API)',
    this.initialQuery,
    this.category,
  });

  /// ✅ โหมด: search (ค้นหา) / category (หมวด)
  final RecipesApiMode mode;

  /// ✅ ชื่อบน AppBar
  final String title;

  /// ✅ คำค้นเริ่มต้น (ใช้กับ search)
  final String? initialQuery;

  /// ✅ หมวดเริ่มต้น (ใช้กับ category)
  /// หมวดของ TheMealDB เช่น: Breakfast, Dessert, Chicken, Seafood, Vegetarian
  final String? category;

  @override
  State<RecipesApiPage> createState() => _RecipesApiPageState();
}

class _RecipesApiPageState extends State<RecipesApiPage> {
  final MealDbApi _api = MealDbApi();
  late final TextEditingController _controller;

  bool _loading = false;
  String? _error;
  List<RecipeSummary> _items = [];

  String _mode = 'all'; // all / savory / sweet

  @override
  void initState() {
    super.initState();

    // ✅ ตั้งค่าเริ่มต้นให้ตรงกับพารามิเตอร์ที่ส่งมา
    String start = widget.initialQuery ?? 'chicken';

    // ถ้ามาแบบ category ให้ map เป็นคำค้นง่าย ๆ (เพราะ MealDbApi ของคุณเป็น searchRecipes)
    if (widget.mode == RecipesApiMode.category) {
      final c = (widget.category ?? '').trim();
      if (c.isNotEmpty) {
        start = _categoryToQuery(c);
      }
    }

    _controller = TextEditingController(text: start);
    _search();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// ✅ map หมวด -> keyword สำหรับ search
  String _categoryToQuery(String c) {
    final cc = c.toLowerCase();
    // หมวดที่หน้า Home ใช้: Breakfast/Lunch/Sweet/Vegan
    if (cc == 'breakfast') return 'egg';
    if (cc == 'lunch') return 'chicken';
    if (cc == 'sweet') return 'cake';
    if (cc == 'vegan') return 'vegetarian';

    // เผื่อคุณส่งหมวดจริงของ TheMealDB
    if (cc == 'dessert') return 'cake';
    if (cc == 'chicken') return 'chicken';
    if (cc == 'beef') return 'beef';
    if (cc == 'seafood') return 'fish';
    if (cc == 'vegetarian') return 'vegetarian';

    // default
    return 'chicken';
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _api.searchRecipes(q);
      if (mounted) {
        setState(() => _items = res);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _setModeAll() {
    setState(() => _mode = 'all');
    _controller.text = 'a'; // ดึงผลลัพธ์กว้าง ๆ
    _search();
  }

  void _setModeSavory() {
    setState(() => _mode = 'savory');
    _controller.text = 'chicken';
    _search();
  }

  void _setModeSweet() {
    setState(() => _mode = 'sweet');
    _controller.text = 'cake';
    _search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      hintText: 'Search recipes… (e.g. chicken, pasta, soup)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _loading ? null : _search,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),

          // ✅ เลือกโหมด อาหารคาว/ขนม/ทั้งหมด
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('ทั้งหมด'),
                  selected: _mode == 'all',
                  onSelected: (_) => _setModeAll(),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('อาหารคาว'),
                  selected: _mode == 'savory',
                  onSelected: (_) => _setModeSavory(),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('ขนม'),
                  selected: _mode == 'sweet',
                  onSelected: (_) => _setModeSweet(),
                ),
              ],
            ),
          ),

          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),

          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('No results'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final it = _items[i];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailPage(mealId: it.id),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEAEAEA)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  it.image,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox(
                                    width: 72,
                                    height: 72,
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  it.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
