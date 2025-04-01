class Product {
  final int id;
  final String name;
  final int stock;
  final double price;
  final String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.stock,
    required this.price,
    this.imagePath,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    //Debug prints to check incoming data
    print('Raw product data: $json');

    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'].toString(),
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imagePath: json['image_path']?.toString(),
    );
  }
}