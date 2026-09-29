import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../screens/recipe_detail_page.dart';
import '../../services/favorite_notification_service.dart';
import '../../theme/watercolor_background.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final cardBg = isDark
        ? const Color(0xFF1E2328)
        : Colors.white.withOpacity(0.92);
    final borderColor = isDark
        ? const Color(0xFF38414A)
        : const Color(0xFFE8DFD7);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: WatercolorBackground(seed: 42)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รายการโปรด',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (user == null)
                    Expanded(
                      child: Center(
                        child: Text(
                          'กรุณาเข้าสู่ระบบเพื่อดูรายการโปรด',
                          style: TextStyle(color: titleColor),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('favorites')
                            .snapshots(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snap.error}',
                                style: TextStyle(color: titleColor),
                              ),
                            );
                          }

                          final docs = List.of(snap.data?.docs ?? []);
                          docs.sort((a, b) {
                            final aCreatedAt = a.data()['createdAt'];
                            final bCreatedAt = b.data()['createdAt'];
                            if (aCreatedAt is Timestamp &&
                                bCreatedAt is Timestamp) {
                              return bCreatedAt.compareTo(aCreatedAt);
                            }
                            if (aCreatedAt is Timestamp) return -1;
                            if (bCreatedAt is Timestamp) return 1;
                            return 0;
                          });
                          if (docs.isEmpty) {
                            return Center(
                              child: Text(
                                'ยังไม่มีรายการโปรด',
                                style: TextStyle(color: titleColor),
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.only(top: 6, bottom: 24),
                            itemCount: docs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final d = docs[i].data();
                              final mealId = (d['mealId'] ?? docs[i].id)
                                  .toString();
                              final title = (d['title'] ?? '').toString();
                              final image = (d['image'] ?? '').toString();
                              final subtitleParts = <String>[];
                              final category = (d['category'] ?? '').toString();
                              final area = (d['area'] ?? '').toString();
                              if (category.isNotEmpty) {
                                subtitleParts.add(category);
                              }
                              if (area.isNotEmpty) {
                                subtitleParts.add(area);
                              }

                              return InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          RecipeDetailPage(mealId: mealId),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: borderColor),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                          isDark ? 0.16 : 0.06,
                                        ),
                                        blurRadius: 14,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                              left: Radius.circular(18),
                                            ),
                                        child: SizedBox(
                                          width: 96,
                                          height: 86,
                                          child: image.isEmpty
                                              ? Container(color: Colors.black12)
                                              : Image.network(
                                                  image,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                title.isEmpty
                                                    ? 'ไม่ทราบชื่อเมนู'
                                                    : title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: titleColor,
                                                ),
                                              ),
                                              if (subtitleParts.isNotEmpty) ...[
                                                const SizedBox(height: 6),
                                                Text(
                                                  subtitleParts.join(' • '),
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white70
                                                        : const Color(
                                                            0xFF7E756E,
                                                          ),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'ลบออกจากรายการโปรด',
                                        onPressed: () async {
                                          try {
                                            await docs[i].reference.delete();
                                            await FavoriteNotificationService.addFavoriteNotification(
                                              added: false,
                                              mealId: mealId,
                                              title: title,
                                              image: image,
                                            );
                                          } catch (_) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'ลบรายการโปรดไม่สำเร็จ',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Color.fromARGB(
                                            255,
                                            123,
                                            121,
                                            121,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
          ),
        ],
      ),
    );
  }
}
