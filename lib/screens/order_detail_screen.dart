import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/product.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  List<Map<String, dynamic>> _orderItems = [];
  bool _isLoading = true;
  double _orderTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://warehousemanagementsystem.shop/api.php/order_details?id=${widget.orderId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _orderItems = (data['items'] as List?)?.map((item) {
            return {
              'product': Product.fromJson(item['product']),
              'quantity': item['quantity'],
              'price': double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0,
            };
          }).toList() ?? [];

          _orderTotal = double.tryParse(data['total']?.toString() ?? '0.0') ?? 0.0;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load order details. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
    final product = item['product'] as Product;
    final quantity = item['quantity'] as int;
    final price = item['price'] as double;

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
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: CupertinoColors.systemGrey6,
            ),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
              ),
            )
                : _buildPlaceholderImage(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('$quantity × ₱${price.toStringAsFixed(2)}'),
              ],
            ),
          ),
          Text(
            '₱${(quantity * price).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        CupertinoIcons.photo,
        size: 30,
        color: CupertinoColors.systemGrey,
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
            if (_orderItems.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No items in this order',
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildOrderItem(_orderItems[index]),
                  childCount: _orderItems.length,
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
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
                      '₱${_orderTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}