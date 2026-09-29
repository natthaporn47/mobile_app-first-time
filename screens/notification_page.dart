import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/favorite_notification_service.dart';
import '../theme/watercolor_background.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FavoriteNotificationService.markAllAsRead();
    });
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return 'เมื่อสักครู่';
    final dt = ts.toDate();
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E2328) : Colors.white.withOpacity(0.92);
    final borderColor = isDark ? const Color(0xFF38414A) : const Color(0xFFE8DFD7);
    final titleColor = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final subColor = isDark ? Colors.white70 : const Color(0xFF7E756E);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: WatercolorBackground(seed: 42)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cardBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor),
                          ),
                          child: Icon(Icons.chevron_left_rounded, color: titleColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'การแจ้งเตือน',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (user == null)
                    Expanded(
                      child: Center(
                        child: Text(
                          'กรุณาเข้าสู่ระบบเพื่อดูการแจ้งเตือน',
                          style: TextStyle(color: titleColor, fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FavoriteNotificationService.notificationsStream(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snap.hasError) {
                            return Center(
                              child: Text(
                                'เกิดข้อผิดพลาด: ${snap.error}',
                                style: TextStyle(color: titleColor),
                              ),
                            );
                          }

                          final docs = snap.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return Center(
                              child: Text(
                                'ยังไม่มีการแจ้งเตือน',
                                style: TextStyle(color: titleColor, fontWeight: FontWeight.w700),
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final d = docs[i].data();
                              final image = (d['image'] ?? '').toString();
                              final message = (d['message'] ?? '').toString();
                              final isRead = d['isRead'] == true;
                              final createdAt = d['createdAt'] as Timestamp?;

                              return Container(
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
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: image.isEmpty
                                        ? Container(
                                            width: 52,
                                            height: 52,
                                            color: Colors.black12,
                                            child: const Icon(Icons.notifications_none_rounded),
                                          )
                                        : Image.network(
                                            image,
                                            width: 52,
                                            height: 52,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 52,
                                              height: 52,
                                              color: Colors.black12,
                                              child: const Icon(Icons.notifications_none_rounded),
                                            ),
                                          ),
                                  ),
                                  title: Text(
                                    message,
                                    style: TextStyle(
                                      color: titleColor,
                                      fontWeight: isRead ? FontWeight.w700 : FontWeight.w900,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _formatTime(createdAt),
                                      style: TextStyle(color: subColor),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () => FavoriteNotificationService.deleteNotification(docs[i].id),
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
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
