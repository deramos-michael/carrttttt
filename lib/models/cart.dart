import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

class Cart {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(Product product) {
    for (var item in _items) {
      if (item.product.id == product.id) {
        item.quantity++;
        return;
      }
    }
    _items.add(CartItem(product: product));
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    for (var item in _items) {
      if (item.product.id == productId) {
        item.quantity = newQuantity;
        return;
      }
    }
  }

  void clear() {
    _items.clear();
  }
}