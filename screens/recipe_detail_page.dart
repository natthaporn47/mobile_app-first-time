import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/recipe_model.dart';
import '../services/favorite_notification_service.dart';
import '../services/mealdb_api.dart';
import '../theme/watercolor_background.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({super.key, required this.mealId});
  final String mealId;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final MealDbApi _api = MealDbApi();
  late Future<RecipeDetail?> _future;
  bool _fav = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _api.getDetail(widget.mealId);
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.mealId)
        .get();
    if (!mounted) return;
    setState(() => _fav = doc.exists);
  }

  Future<void> _toggleFavorite(RecipeDetail data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อน')));
      return;
    }
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final meta = _metaParts(data);
      final added = await FavoriteNotificationService.toggleFavorite(
        mealId: widget.mealId,
        title: data.title,
        image: data.image,
        category: meta.$1,
        area: meta.$2,
      );
      if (!mounted) return;
      setState(() => _fav = added);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added ? 'เพิ่มในรายการโปรดแล้ว' : 'นำออกจากรายการโปรดแล้ว',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกรายการโปรดไม่สำเร็จ กรุณาลองใหม่')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  (String, String) _metaParts(RecipeDetail d) {
    String category = '';
    String area = '';
    try {
      final dynamic any = d;
      category = (any.category ?? '').toString().trim();
      area = (any.area ?? '').toString().trim();
    } catch (_) {}
    return (category, area);
  }

  Future<void> openMap(String mealName) async {
    final query = Uri.encodeComponent('$mealName restaurant near me');
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (!await launchUrl(url)) {
      throw Exception('Could not open map');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black;
    final metaColor = isDark ? Colors.white70 : Colors.black54;
    final pillBg = isDark
        ? const Color(0xFF1E2328)
        : Colors.white.withOpacity(0.85);
    final pillBorder = isDark
        ? const Color(0xFF38414A)
        : Colors.black.withOpacity(0.06);
    final pillText = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: WatercolorBackground(seed: 42)),
          SafeArea(
            child: FutureBuilder<RecipeDetail?>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snap.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                final data = snap.data;
                if (data == null) {
                  return const Center(child: Text('Not found'));
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: SizedBox(
                          height: 240,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                data.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.black.withOpacity(0.05),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.image_not_supported_rounded,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 12,
                                top: 12,
                                child: _RoundOverlayButton(
                                  icon: Icons.chevron_left_rounded,
                                  onTap: () => Navigator.of(context).pop(),
                                ),
                              ),
                              Positioned(
                                right: 12,
                                top: 12,
                                child: _RoundOverlayButton(
                                  icon: _fav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  iconColor: _fav ? Colors.redAccent : null,
                                  onTap: _busy
                                      ? null
                                      : () => _toggleFavorite(data),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _metaText(data),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: metaColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => openMap(data.title),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: pillBg,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: pillBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 18,
                                          color: pillText,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Find Restaurant',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: pillText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _CardSection(
                              title: 'Ingredients',
                              child: Column(
                                children: data.ingredients.map((it) {
                                  final line = it.trim();
                                  if (line.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '•  ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1.2,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            line,
                                            style: TextStyle(
                                              fontSize: 15,
                                              height: 1.35,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _CardSection(
                              title: 'Instructions',
                              child: Text(
                                data.instructions.trim().isEmpty
                                    ? 'No instructions'
                                    : data.instructions.trim(),
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.55,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _metaText(RecipeDetail d) {
    final meta = _metaParts(d);
    final parts = <String>[];
    if (meta.$1.isNotEmpty) parts.add(meta.$1);
    if (meta.$2.isNotEmpty) parts.add(meta.$2);
    return parts.join(' • ');
  }
}

class _RoundOverlayButton extends StatelessWidget {
  const _RoundOverlayButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E2328).withOpacity(0.92)
              : Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark
                ? const Color(0xFF38414A)
                : Colors.white.withOpacity(0.7),
          ),
        ),
        child: Icon(
          icon,
          size: 22,
          color:
              iconColor ??
              (isDark ? Colors.white : Colors.black.withOpacity(0.65)),
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? const Color(0xFF1E2328)
        : Colors.white.withOpacity(0.78);
    final borderColor = isDark
        ? const Color(0xFF38414A)
        : Colors.black.withOpacity(0.06);
    final titleColor = isDark ? Colors.white : Colors.black;
    final lineColor = isDark ? Colors.white24 : Colors.black.withOpacity(0.10);
    final bodyColor = isDark ? Colors.white : Colors.black87;

    return DefaultTextStyle(
      style: TextStyle(color: bodyColor, fontSize: 15, height: 1.5),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.18 : 0.03),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              width: 500,
              decoration: BoxDecoration(
                color: lineColor,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
