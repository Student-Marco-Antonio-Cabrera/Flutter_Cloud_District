class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.imagePath,
    this.availableFlavors = const [],
  });

  final String id;
  final String name;
  final double price;
  final String? imagePath;
  final List<String> availableFlavors;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'imagePath': imagePath,
        'availableFlavors': availableFlavors,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        imagePath: json['imagePath'] as String?,
        availableFlavors:
            List<String>.from(json['availableFlavors'] as List? ?? []),
      );
}
