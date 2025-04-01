import 'dart:async'; // Import Timer
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;  // Control loading state
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    // Set up periodic refresh every 3 seconds (or desired interval)
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      _fetchOrders(); // Automatically fetch orders every 3 seconds
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Don't forget to cancel the timer when the screen is disposed
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('http://warehousemanagementsystem.shop/api.php/orders'));
      if (response.statusCode == 200) {
        setState(() {
          _orders = json.decode(response.body);
          _isLoading = false; // Set loading to false after fetching
        });
      } else {
        throw Exception('Failed to load orders');
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

  // Build order item widget
  Widget _buildOrderItem(BuildContext context, Map<String, dynamic> order) {
    final itemsCount = int.tryParse(order['items_count'].toString()) ?? 0;

    return Card(
      margin: const EdgeInsets.all(8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => OrderDetailScreen(orderId: int.tryParse(order['id'].toString()) ?? 0),

            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(CupertinoIcons.cart, size: 24),
                    if (itemsCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: CupertinoColors.systemRed,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            itemsCount.toString(),
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order['id']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: \$${double.tryParse(order['total'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(CupertinoIcons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Your Orders'),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator()) // Show loading indicator on initial load or fetch
          : Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0), // Adjusted padding
        child: CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                await _fetchOrders(); // Manually refresh the orders
              },
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildOrderItem(context, _orders[index]),
                childCount: _orders.length,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 48), // More space at the bottom
            ),
          ],
        ),
      ),
    );
  }
}
