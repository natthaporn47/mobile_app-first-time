import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../theme/watercolor_background.dart';
import '../../screens/recipe_detail_page.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final _searchCtrl = TextEditingController(text: '');

  bool _loading = false;
  String? _error;

  // all / savory / sweet / veg
  String _mode = 'all';

  List<_RecipeItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final q = _searchCtrl.text.trim();
      final items = await _fetchRecipes(mode: _mode, query: q);
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<List<_RecipeItem>> _fetchRecipes({
    required String mode,
    required String query,
  }) async {
    Uri uri;

    if (mode == 'sweet') {
      uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert');
    } else if (mode == 'veg') {
      uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=Vegetarian');
    } else if (mode == 'savory') {
      uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=Chicken');
    } else {
      final q = query.isEmpty ? 'a' : query;
      uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$q');
    }

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final meals = (data['meals'] as List?) ?? [];

    return meals.map((m) {
      final mm = m as Map<String, dynamic>;
      return _RecipeItem(
        id: (mm['idMeal'] ?? '').toString(),
        title: (mm['strMeal'] ?? '').toString(),
        image: (mm['strMealThumb'] ?? '').toString(),
      );
    }).toList();
  }

  void _setMode(String mode) {
    setState(() => _mode = mode);

    if (mode == 'sweet') _searchCtrl.text = 'cake';
    if (mode == 'savory') _searchCtrl.text = 'chicken';
    if (mode == 'veg') _searchCtrl.text = 'vegetable';

    _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2B2B2B);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: WatercolorBackground(seed: 42)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _TopSearch(
                    controller: _searchCtrl,
                    loading: _loading,
                    onSearch: _load,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _chip('ทั้งหมด', selected: _mode == 'all', onTap: () => _setMode('all')),
                      const SizedBox(width: 8),
                      _chip('อาหารคาว', selected: _mode == 'savory', onTap: () => _setMode('savory')),
                      const SizedBox(width: 8),
                      _chip('ขนม', selected: _mode == 'sweet', onTap: () => _setMode('sweet')),
                      const SizedBox(width: 8),
                      _chip('มังฯ', selected: _mode == 'veg', onTap: () => _setMode('veg')),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (_loading) const LinearProgressIndicator(minHeight: 2),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                    ),
                  ),
                Expanded(
                  child: _items.isEmpty && !_loading
                      ? Center(
                          child: Text(
                            'ไม่พบรายการ',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final it = _items[i];
                            return _RecipeTile(
                              item: it,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecipeDetailPage(mealId: it.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, {required bool selected, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? const Color(0xFF3A5146) : const Color(0xFFF1D6C6))
              : (isDark ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.75)),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark ? const Color(0xFF3D4642) : const Color(0xFFEFE3D8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: selected
                ? (isDark ? Colors.white : const Color(0xFF2B2B2B))
                : (isDark ? Colors.white70 : const Color(0xFF8E8176)),
          ),
        ),
      ),
    );
  }
}

class _TopSearch extends StatelessWidget {
  const _TopSearch({
    required this.controller,
    required this.loading,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isDark ? const Color(0xFF3D4642) : const Color(0xFFEFE3D8),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: isDark ? Colors.white70 : const Color(0xFF8E8176),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                    ),
                    decoration: InputDecoration(
                      hintText: 'ค้นหาเมนู… เช่น chicken, pasta',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : const Color(0xFF8E8176),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 44,
          child: FilledButton(
            onPressed: loading ? null : onSearch,
            child: const Text('ค้นหา'),
          ),
        ),
      ],
    );
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({required this.item, required this.onTap});
  final _RecipeItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.86),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF3D4642) : const Color(0xFFEFE3D8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.10 : 0.03),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                item.image,
                width: 74,
                height: 74,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 74,
                  height: 74,
                  color: Colors.black.withOpacity(0.06),
                  child: const Icon(Icons.image_not_supported_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF8E8176),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeItem {
  final String id;
  final String title;
  final String image;
  _RecipeItem({required this.id, required this.title, required this.image});
}
