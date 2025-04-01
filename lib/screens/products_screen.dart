import 'dart:async'; // Import Timer
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../models/cart.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final Cart cart;

  const ProductsScreen({Key? key, required this.cart}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;  // Control loading state
  late Timer _timer;

  // Map product IDs to their corresponding image paths
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
    _fetchProducts();
    // Set up periodic refresh every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      _fetchProducts(); // Automatically fetch products every 3 seconds
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Don't forget to cancel the timer when the screen is disposed
    super.dispose();
  }

  // Fetch products without showing loading spinner for auto-fetch
  Future<void> _fetchProducts({bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('https://warehousemanagementsystem.shop/api.php/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data.map((json) => Product.fromJson(json)).toList();
          _isLoading = false; // Set loading to false after fetching
        });
      } else {
        throw Exception('Failed to load products. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false; // Set loading to false if there's an error
      });
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Products'),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator()) // Show loading indicator on initial load or fetch
          : Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20.0), // Increased vertical padding for more space
        child: CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                _fetchProducts(showLoading: true); // Show loading on manual refresh
              },
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 32), // Increased space before the grid
            ),
            SliverGrid(
              // Adjust the number of items per row based on the screen width
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getGridItemCount(context), // Responsive grid
                crossAxisSpacing: 16,  // Adjusted spacing between items
                mainAxisSpacing: 16,    // Increased vertical spacing between rows
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildProductCard(context, _products[index]),
                childCount: _products.length,
              ),
            ),
            // Add extra space below the grid
            SliverToBoxAdapter(
              child: SizedBox(height: 32), // Increased bottom space
            ),
          ],
        ),
      ),
    );
  }

  // Function to return grid item count based on screen size
  int _getGridItemCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 800) {
      // For larger screens (tablets, desktops), show 4 items per row
      return 4;
    } else if (screenWidth > 600) {
      // For medium screens (larger phones), show 3 items per row
      return 3;
    } else {
      // For smaller screens (phones), show 2 items per row
      return 2;
    }
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final imagePath = _productImages[product.id];

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () async {
        final result = await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
              cart: widget.cart,
            ),
          ),
        );

        if (result == true) {
          _fetchProducts(showLoading: true); // Refresh products after purchase
        }
      },
      child: Card(
        elevation: 5, // Add shadow to the card for better contrast
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Round corners for a smoother look
        ),
        clipBehavior: Clip.antiAlias, // Smooth the edges of images and content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: imagePath != null
                    ? Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity, // Make image fill the space
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(CupertinoIcons.photo, size: 100),
                )
                    : const Icon(CupertinoIcons.photo, size: 100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0), // Increased padding inside the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Increased font size for better readability
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\₱${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: CupertinoTheme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Increased font size for better readability
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stock: ${product.stock}',
                    style: const TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 16, // Slightly larger text
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24), // Increased space below the card
          ],
        ),
      ),
    );
  }
}
