import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient client;
  ProductService(this.client);

  Future<List<Product>> fetchProducts() async {
    final data = await client.getJson('/api/products');

    // สมมติ API ส่งมาเป็น List
    if (data is List) {
      return data.map((e) => Product.fromJson(e)).toList();
    }

    // หรือถ้าส่งมาเป็น { products: [...] }
    if (data is Map && data['products'] is List) {
      final list = data['products'] as List;
      return list.map((e) => Product.fromJson(e)).toList();
    }

    return [];
  }
}
