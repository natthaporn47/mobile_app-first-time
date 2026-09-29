import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../screens/recipe_detail_page.dart';
import 'home_page.dart';

class AllMealsPage extends StatelessWidget {
  final String title;
  final List<MealItem> meals;

  const AllMealsPage({
    super.key,
    required this.title,
    required this.meals,
  });

  static const Color bg = Color(0xFFF7F3EE);
  static const Color card = Colors.white;
  static const Color line = Color(0xFFEAE1D8);
  static const Color textMain = Color(0xFF2B2B2B);
  static const Color textSub = Color(0xFF8E8176);
  static const Color green = Color(0xFFD8F11B);

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
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: bg,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
        itemCount: meals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = meals[i];

          return Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: line),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                  child: Image.network(
                    item.image,
                    width: 120,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 110,
                      color: Colors.black.withOpacity(0.05),
                      child: const Icon(Icons.image_not_supported_rounded),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.area,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: textSub,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecipeDetailPage(mealId: item.id),
                                  ),
                                );
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_rounded, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                openMap(item.title);
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: card,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: line),
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: textSub,
                                  size: 20,
                                ),
                              ),
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
        },
      ),
    );
  }
}