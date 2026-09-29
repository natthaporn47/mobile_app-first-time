import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CacheActions {
  static Future<void> showClearCacheDialog(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ยืนยันการล้างแคช',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const Text(
                  'การทำรายการนี้จะลบรายการโปรดและการแจ้งเตือนทั้งหมด\n'
                  'รวมถึงแคชรูปภาพ และไม่สามารถกู้คืนได้',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('ยกเลิก'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('ล้างแคช'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok == true && context.mounted) {
      await _clearCache(context);
    }
  }

  static Future<void> _clearCache(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนล้างข้อมูล')),
      );
      return;
    }

    try {
      await _deleteSubcollection(user.uid, 'favorites');
      await _deleteSubcollection(user.uid, 'notifications');
      PaintingBinding.instance.imageCache
        ..clear()
        ..clearLiveImages();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ล้างรายการโปรด การแจ้งเตือน และแคชเรียบร้อยแล้ว'),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ล้างข้อมูลไม่สำเร็จ: $error')),
      );
    }
  }

  static Future<void> _deleteSubcollection(String uid, String name) async {
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(name);

    while (true) {
      final snapshot = await collection.limit(400).get();
      if (snapshot.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
    }
  }
}
