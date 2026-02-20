import '../models/product.dart';

final List<Product> mockProducts = [
  const Product(
    id: '1',
    name: 'Classic Vape Pen',
    price: 899,
    imagePath: 'assets/images/products/classic_vape_pen.png',
    availableFlavors: ['Mint', 'Berry', 'Tobacco', 'Mango', 'Vanilla'],
  ),
  const Product(
    id: '2',
    name: 'Premium Pod Kit',
    price: 1499,
    imagePath: 'assets/images/products/premium_pod_kit.png',
    availableFlavors: [
      'Ice Mint',
      'Strawberry',
      'Blueberry',
      'Coffee',
      'Melon',
    ],
  ),
  const Product(
    id: '3',
    name: 'Disposable Vape',
    price: 549,
    imagePath: 'assets/images/products/disposable_vape_peach.png',
    availableFlavors: ['Peach', 'Grape', 'Pineapple', 'Watermelon', 'Cherry'],
  ),
  const Product(
    id: '4',
    name: 'Starter Kit Pro',
    price: 1899,
    imagePath: 'assets/images/products/starter_kit_pro.png',
    availableFlavors: ['Menthol', 'Apple', 'Banana', 'Citrus', 'Caramel'],
  ),
  const Product(
    id: '5',
    name: 'Cloud Chaser Mod',
    price: 2599,
    imagePath: 'assets/images/products/cloud_chaser_mod_tobacco.png',
    availableFlavors: [
      'Tobacco',
      'Mint',
      'Mixed Berry',
      'Cola',
      'Cotton Candy',
    ],
  ),
  const Product(
    id: '6',
    name: 'Slim Pod Device',
    price: 999,
    imagePath: 'assets/images/products/slim_pod_device_lemon.png',
    availableFlavors: ['Lemon', 'Orange', 'Pomegranate', 'Lychee', 'Honey'],
  ),
];

Product? getProductById(String id) {
  try {
    return mockProducts.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
