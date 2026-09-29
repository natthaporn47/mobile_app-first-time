
// import 'package:flutter/material.dart';
// import '../services/firestore_product_service.dart';
// import '../models/product_doc.dart';

// class ProductScreen extends StatelessWidget {
//   ProductScreen({super.key});

//   final service = FirestoreProductService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Products (Firestore)")),
//       body: StreamBuilder<List<ProductDoc>>(
//         stream: service.watchProducts(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           final products = snapshot.data ?? [];
//           if (products.isEmpty) {
//             return const Center(child: Text("No products"));
//           }

//           return ListView.builder(
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               final p = products[index];
//               return ListTile(
//                 leading: Image.network(
//                   p.image,
//                   width: 48,
//                   height: 48,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => const Icon(Icons.image),
//                 ),
//                 title: Text(p.title),
//                 subtitle: Text("\$${p.price.toStringAsFixed(2)}"),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }