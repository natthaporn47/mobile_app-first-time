class Product {
  final String name;
  final double price;
  final String image;
  final bool inStock;

  Product({
    required this.name,
    required this.price,
    required this.image,
    required this.inStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: (json['name'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      image: (json['image'] ?? '').toString(),
      inStock: json['inStock'] == true,
    );
  }
}
