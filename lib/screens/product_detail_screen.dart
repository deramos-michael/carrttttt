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
  bool _isLoading = false;
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
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://warehousemanagementsystem.shop/api.php/products/${product.id}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          product = Product.fromJson(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load product details.');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
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
                    // Stock section with loading spinner
                    Row(
                      children: [
                        const Text(
                          'Stock: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        _isLoading
                            ? CupertinoActivityIndicator(radius: 10)
                            : Text(
                          '${product.stock}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.secondaryLabel,
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
}
