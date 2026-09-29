// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../models/product.dart';
// class ProductService {
//   final _db = FirebaseFirestore.instance;

//   Stream<List<Product>> firestoreProducts() {
//     return _db
//     .collection('products')
//     .orderBy('title')
//     .snapshots()
//     .map((snapshot) => snapshot.docs.map(()toList());
//   }
