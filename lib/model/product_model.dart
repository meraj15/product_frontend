class Product {
  final int id;
  final String title;
  final String? description; // Make description nullable
  final double price;
  final String image;
  final String category;

  Product({
    required this.id,
    required this.title,
    this.description, // Nullable field
    required this.price,
    required this.image,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'] ?? "", // If null, assign empty string
      description: json['description'], // Nullable field can be null
      price: json['price'] is String ? double.tryParse(json['price']) ?? 0.0 : json['price'].toDouble(),
      image: json['image'] ?? "", // Default to empty string if null
      category: json['category'] ?? "", // Default to empty string if null
    );
  }
}
