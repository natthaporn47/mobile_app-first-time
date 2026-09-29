class ProductDoc {
  final String docId;        // id ของเอกสารใน firestore
  final int id;
  final String title;
  final double price;
  final String description;
  final String image;

  ProductDoc({
    required this.docId,
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
  });

  factory ProductDoc.fromMap(String docId, Map<String, dynamic> map) {
    return ProductDoc(
      docId: docId,
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: (map['title'] ?? '').toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0,
      description: (map['description'] ?? '').toString(),
      image: (map['image'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'price': price,
    'description': description,
    'image': image,
  };
}