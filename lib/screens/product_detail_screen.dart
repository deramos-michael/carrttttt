import 'dart:async'; // Import Timer
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../models/cart.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Cart cart;

  ProductDetailScreen({
    Key? key,
    required this.product,
    required this.cart,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product product;
  late Timer _timer;

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
  void initState() {
    super.initState();
    product = widget.product;
    _startTimer();
  }

  void _startTimer() {
    // Refresh the product every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      _fetchProductDetails();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the screen is disposed
    super.dispose();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://warehousemanagementsystem.shop/api.php/products/${product.id}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          product = Product.fromJson(data);
        });

        // Show an alert when stock changes (optional)
        _showStockStatusAlert();
      } else {
        throw Exception('Failed to load product details.');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Function to determine and show alerts for stock status
  void _showStockStatusAlert() {
    String stockStatus = '';
    if (product.stock == 0) {
      stockStatus = "Out of Stock";
    } else if (product.stock <= 20) {
      stockStatus = "Low Stock";
    } else if (product.stock >= 100) {
      stockStatus = "High Stock";
    } else {
      stockStatus = "In Stock";
    }

    // Show an alert based on stock status
    CupertinoAlertDialog alertDialog = CupertinoAlertDialog(
      title: Text('Stock Status'),
      content: Text('The product is currently: $stockStatus'),
      actions: [
        CupertinoDialogAction(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    // Show the alert only if stock status changes
    showCupertinoDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

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
                  width: double.infinity,
                  height: double.infinity,
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
                      '\₱${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        color: CupertinoTheme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stock section without loading spinner
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.circle_filled,
                          size: 14,
                          color: _getStockColor(),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getStockStatus(),
                          style: TextStyle(
                            color: _getStockColor(),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: CupertinoTheme.of(context).primaryColor,
                        child: const Text('Add to Cart',
                          style: TextStyle(color: CupertinoColors.white),
                        ),
                        onPressed: () {
                          widget.cart.addItem(product);
                          Navigator.of(context).pop(true); // Returning true to refresh
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

  // Get the color based on stock
  Color _getStockColor() {
    if (product.stock == 0) {
      return CupertinoColors.systemRed;
    } else if (product.stock <= 20) {
      return CupertinoColors.systemOrange;
    } else if (product.stock >= 100) {
      return CupertinoColors.systemGreen;
    } else {
      return CupertinoColors.secondaryLabel;
    }
  }

  // Get the stock status text based on stock
  String _getStockStatus() {
    if (product.stock == 0) {
      return "Out of Stock";
    } else if (product.stock <= 20) {
      return "Low Stock (${product.stock})";
    } else if (product.stock >= 100) {
      return "High Stock (${product.stock})";
    } else {
      return "In Stock (${product.stock})";
    }
  }
}
