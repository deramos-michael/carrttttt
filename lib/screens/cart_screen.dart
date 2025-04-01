import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/cart.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final Cart cart;

  CartScreen({Key? key, required this.cart}) : super(key: key);

  // Map product IDs to their corresponding image paths (same as in ProductsScreen)
  final Map<int, String> _productImages = {
    2: 'images/Macbookair.jpg',
    3: 'images/airpods.jpg',
    4: 'images/AppleWatch.jpg',
    5: 'images/iPadAir.jpg',
    6: 'images/keyboard.jpg',
    7: 'images/PencilApple.jpg',
    8: 'images/Homepod.jpg',
    10: 'images/iPhone16.jpg',
  };

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Your Cart'),
        trailing: cart.items.isNotEmpty
            ? CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Checkout'),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => CheckoutScreen(cart: cart),
              ),
            );
          },
        )
            : null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: cart.items.isEmpty
                  ? const Center(
                child: Text('Your cart is empty'),
              )
                  : ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return _buildCartItem(context, item, cart);
                },
              ),
            ),
            if (cart.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.extraLightBackgroundGray,
                  border: Border(
                    top: BorderSide(
                      color: CupertinoColors.lightBackgroundGray,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: CupertinoTheme.of(context).primaryColor,
                        child: const Text('Proceed to Checkout'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => CheckoutScreen(cart: cart),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, Cart cart) {
    final imagePath = _productImages[item.product.id];

    return Dismissible(
      key: Key(item.product.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: CupertinoColors.destructiveRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          CupertinoIcons.delete,
          color: CupertinoColors.white,
        ),
      ),
      onDismissed: (direction) {
        cart.removeItem(item.product.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.lightBackgroundGray,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Added product image
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imagePath != null
                    ? Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(CupertinoIcons.photo, size: 30),
                )
                    : const Icon(CupertinoIcons.photo, size: 30),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('\$${item.product.price.toStringAsFixed(2)}'),
                ],
              ),
            ),
            Row(
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.all(6),
                  minSize: 0,
                  child: const Icon(CupertinoIcons.minus_circled),
                  onPressed: () {
                    cart.updateQuantity(
                      item.product.id,
                      item.quantity - 1,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(item.quantity.toString()),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(6),
                  minSize: 0,
                  child: const Icon(CupertinoIcons.plus_circled),
                  onPressed: () {
                    if (item.quantity < item.product.stock) {
                      cart.updateQuantity(
                        item.product.id,
                        item.quantity + 1,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}