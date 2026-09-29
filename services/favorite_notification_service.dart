import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteNotificationService {
  FavoriteNotificationService._();

  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static String? get currentUid => _auth.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>>? _notificationsRef() {
    final uid = currentUid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('notifications');
  }

  static Future<void> addFavoriteNotification({
    required bool added,
    required String mealId,
    required String title,
    String image = '',
  }) async {
    final ref = _notificationsRef();
    if (ref == null) return;

    await ref.add({
      'type': added ? 'favorite_added' : 'favorite_removed',
      'mealId': mealId,
      'title': title,
      'image': image,
      'message': added
          ? 'เพิ่ม "$title" ไปยังรายการโปรดแล้ว'
          : 'ลบ "$title" ออกจากรายการโปรดแล้ว',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<bool> toggleFavorite({
    required String mealId,
    required String title,
    required String image,
    String category = '',
    String area = '',
  }) async {
    final uid = currentUid;
    if (uid == null) throw StateError('User is not authenticated');

    final favoriteRef = _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(mealId);
    final notificationRef = _notificationsRef()!.doc();

    return _db.runTransaction<bool>((transaction) async {
      final favorite = await transaction.get(favoriteRef);
      final added = !favorite.exists;

      if (added) {
        transaction.set(favoriteRef, {
          'mealId': mealId,
          'title': title,
          'image': image,
          'category': category,
          'area': area,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.delete(favoriteRef);
      }

      transaction.set(notificationRef, {
        'type': added ? 'favorite_added' : 'favorite_removed',
        'mealId': mealId,
        'title': title,
        'image': image,
        'message': added
            ? 'เพิ่ม "$title" ไปยังรายการโปรดแล้ว'
            : 'ลบ "$title" ออกจากรายการโปรดแล้ว',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return added;
    });
  }

  static Stream<int> unreadCountStream() {
    final ref = _notificationsRef();
    if (ref == null) return const Stream<int>.empty();

    return ref
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> notificationsStream() {
    final ref = _notificationsRef();
    if (ref == null) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
    return ref.orderBy('createdAt', descending: true).snapshots();
  }

  static Future<void> markAllAsRead() async {
    final ref = _notificationsRef();
    if (ref == null) return;

    final snap = await ref.where('isRead', isEqualTo: false).get();
    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  static Future<void> deleteNotification(String docId) async {
    final ref = _notificationsRef();
    if (ref == null) return;
    await ref.doc(docId).delete();
  }
}
