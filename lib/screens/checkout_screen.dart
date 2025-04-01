import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/cart.dart';


class CheckoutScreen extends StatefulWidget {
  final Cart cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessing = false;

  Future<void> _confirmOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://warehousemanagementsystem.shop/api.php/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'total': widget.cart.totalAmount,
          'amount_paid': widget.cart.totalAmount,
          'sukli': 0,
          'items': widget.cart.items.map((item) => {
            'product_id': item.product.id,
            'quantity': item.quantity,
            'price': item.product.price,
          }).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          widget.cart.clear();
          _showOrderConfirmationPopup(responseData['purchase_id']);
        } else {
          throw Exception(responseData['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to process order');
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showOrderConfirmationPopup(int orderId) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Order Placed'),
        content: Text('Your order #$orderId has been successfully placed.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).popUntil((route) => route.isFirst); // Go back to home
            },
          ),
        ],
      ),
    );
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

  Widget _buildCartItem(CartItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
                  ? Image.network(
                item.product.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderImage(),
              )
                  : _buildPlaceholderImage(),
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
                Text('${item.quantity} × ₱${item.product.price.toStringAsFixed(2)}'),
                if (item.quantity > item.product.stock)
                  Text(
                    'Only ${item.product.stock} available',
                    style: TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '₱${(item.quantity * item.product.price).toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: CupertinoColors.systemGrey6,
      child: const Center(
        child: Icon(CupertinoIcons.photo, size: 30, color: CupertinoColors.systemGrey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.cart.totalAmount;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Confirm Order'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Replacing Material Card with a styled Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    ...widget.cart.items.map(_buildCartItem),
                    const SizedBox(height: 12),
                    Container( // Replacing Divider
                      height: 1,
                      color: CupertinoColors.systemGrey4,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₱${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                color: CupertinoTheme.of(context).primaryColor,
                onPressed: _isProcessing || _hasInsufficientStock() ? null : _confirmOrder,
                child: _isProcessing
                    ? const CupertinoActivityIndicator()
                    : Text(
                  _hasInsufficientStock() ? 'Insufficient Stock' : 'Confirm Order',
                  style: const TextStyle(color: CupertinoColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasInsufficientStock() {
    return widget.cart.items.any((item) => item.quantity > item.product.stock);
  }
}
