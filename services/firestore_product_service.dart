// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/product_doc.dart';

// class FirestoreProductService {
//   final _col = FirebaseFirestore.instance.collection('products');

//   Stream<List<ProductDoc>> watchProducts() {
//     return _col.snapshots().map((snap) {
//       return snap.docs.map((d) => ProductDoc.fromMap(d.id, d.data())).toList();
//     });
//   }

//   Future<void> addProduct(ProductDoc p) async {
//     await _col.add({
//       ...p.toMap(),
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> updateProduct(ProductDoc p) async {
//     await _col.doc(p.docId).update(p.toMap());
//   }

//   Future<void> deleteProduct(String docId) async {
//     await _col.doc(docId).delete();
//   }
// }