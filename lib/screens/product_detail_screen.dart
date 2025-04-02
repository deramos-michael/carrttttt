import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../models/cart.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Cart cart;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.cart,
  });

  @override
  ProductDetailScreenState createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product product;
  late Timer _timer;


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
      } else {
        throw Exception('Failed to load product details.');
      }
    } catch (e) {
      // You might want to show an error dialog here
      // _showErrorDialog(e.toString());
    }
  }
  //
  // void _showErrorDialog(String message) {
  //   showCupertinoDialog(
  //     context: context,
  //     builder: (context) => CupertinoAlertDialog(
  //       title: const Text('Error'),
  //       content: Text(message),
  //       actions: [
  //         CupertinoDialogAction(
  //           child: const Text('OK'),
  //           onPressed: () => Navigator.pop(context),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
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
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderImage(),
                )
                    : _buildPlaceholderImage(),
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
                      '₱${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        color: CupertinoTheme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stock status indicator
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
                        color: product.stock > 0
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemGrey,
                        onPressed: product.stock > 0
                            ? () {
                          widget.cart.addItem(product);
                          Navigator.of(context).pop(true); // Returning true to refresh
                        }
                            : null,
                        child: Text(
                          product.stock > 0 ? 'Add to Cart' : 'Out of Stock',
                          style: const TextStyle(color: CupertinoColors.white),
                        ),
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

  Widget _buildPlaceholderImage() {
    return Container(
      color: CupertinoColors.systemGrey6,
      child: const Center(
        child: Icon(CupertinoIcons.photo, size: 60, color: CupertinoColors.systemGrey),
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