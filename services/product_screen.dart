import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_client.dart';
import '../services/product_service.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final ProductService service;

  bool isLoading = true;
  String? error;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();

    // ✅ เปลี่ยน baseUrl ให้ถูกตามเครื่องคุณ (ดูข้อ 5)
    service = ProductService(ApiClient('http://10.0.2.2:3000'));

    fetch();
  }

  Future<void> fetch() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await service.fetchProducts();
      setState(() {
        products = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ListTile(
                      leading: Image.network(
                        p.image,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image),
                      ),
                      title: Text(p.name),
                      subtitle: Text("\$${p.price.toStringAsFixed(2)}"),
                      trailing: p.inStock
                          ? const Text("In Stock",
                              style: TextStyle(color: Colors.green))
                          : const Text("Out of Stock",
                              style: TextStyle(color: Colors.red)),
                    );
                  },
                ),
    );
  }
}
