class Product {
  final String name;
  final String description;
  final String imageUrl;
  final double price;

  Product({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
  });
}

class ProductService {
  Future<List<Product>> getRecommendedProducts(double damageScore) async {
    // Mock product recommendations
    await Future.delayed(const Duration(seconds: 1));
    return [
      Product(
        name: 'Gliss Ultimate Repair Shampoo',
        description: 'Intensive repair for damaged hair',
        imageUrl: 'assets/images/shampoo.png',
        price: 9.99,
      ),
      Product(
        name: 'Gliss Hair Repair Mask',
        description: 'Deep conditioning treatment',
        imageUrl: 'assets/images/mask.png',
        price: 12.99,
      ),
    ];
  }
}
