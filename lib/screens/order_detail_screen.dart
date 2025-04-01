import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/product.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<Map<String, dynamic>> _orderItems = [];
  bool _isLoading = true;
  double _orderTotal = 0.0;

  // Match the product images mapping from ProductsScreen
  final Map<int, String> _productImages = {
    2: 'images/macbook.jpg',
    3: 'images/airpods.jpg',
    4: 'images/apple_watch.jpg',
    5: 'images/ipad.jpg',
    6: 'images/keyboard.jpg',
    7: 'images/apple_pencil.jpg',
    8: 'images/homepod.jpg',
    10: 'images/sobnang.jpg',
  };

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.107/api.php/order_details?id=${widget.orderId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _orderItems = List<Map<String, dynamic>>.from(data['items']);
          _orderTotal = double.tryParse(data['total'].toString()) ?? 0.0;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
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

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final product = Product.fromJson(item['product']);
    final imagePath = _productImages[product.id];
    final quantity = item['quantity'] as int;
    final price = double.tryParse(item['price'].toString()) ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
          // Product image
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
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('$quantity × \$${price.toStringAsFixed(2)}'),
              ],
            ),
          ),
          Text(
            '\$${(quantity * price).toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Order #${widget.orderId}'),
        previousPageTitle: 'Orders',
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: _fetchOrderDetails,
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                ..._orderItems.map(_buildOrderItem).toList(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Total:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '\$${_orderTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}