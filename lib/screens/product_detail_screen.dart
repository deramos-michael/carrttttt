import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final Cart cart;

   ProductDetailScreen({
    Key? key,
    required this.product,
    required this.cart,
  }) : super(key: key);

  // Match the product images mapping from ProductsScreen
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
    final imagePath = _productImages[product.id];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(product.name),
        previousPageTitle: 'Products',
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: imagePath != null
                    ? Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(CupertinoIcons.photo, size: 100),
                )
                    : const Icon(CupertinoIcons.photo, size: 100),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        color: CupertinoTheme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Stock: ${product.stock}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: CupertinoTheme.of(context).primaryColor,
                        child: const Text('Add to Cart'),
                        onPressed: () {
                          cart.addItem(product);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}