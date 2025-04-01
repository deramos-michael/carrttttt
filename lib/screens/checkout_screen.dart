import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/cart.dart';

class CheckoutScreen extends StatefulWidget {
  final Cart cart;

  const CheckoutScreen({Key? key, required this.cart}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;

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
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processOrder() async {
    final amountPaid = double.tryParse(_amountController.text) ?? 0.0;

    if (amountPaid < widget.cart.totalAmount) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Insufficient Payment'),
          content: const Text('The amount paid is less than the total amount.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://warehousemanagementsystem.shop/api.php/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'total': widget.cart.totalAmount,
          'amount_paid': amountPaid,
          'sukli': amountPaid - widget.cart.totalAmount,
          'items': widget.cart.items.map((item) => {
            'product_id': item.product.id,
            'quantity': item.quantity,
            'price': item.product.price,
          }).toList(),
        }),
      );
      print('Response: ${response.body}'); // Debug response

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          widget.cart.clear();
          Navigator.of(context).popUntil((route) => route.isFirst);
          _showSuccessDialog(responseData['purchase_id']);
        } else {
          throw Exception(responseData['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to process order');
      }
    } catch (e) {
      print("Error: $e"); // Log error
      _showErrorDialog(e.toString());
    }
    finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog(int orderId) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Order Successful'),
        content: Text('Your order #$orderId has been placed.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
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
    final imagePath = _productImages[item.product.id];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('${item.quantity} × \$${item.product.price.toStringAsFixed(2)}'),
              ],
            ),
          ),
          Text(
            '\$${(item.quantity * item.product.price).toStringAsFixed(2)}',
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
    final totalAmount = widget.cart.totalAmount;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Checkout'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cart items list
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ...widget.cart.items.map(_buildCartItem).toList(),
                      const Divider(),
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
                            '\$${totalAmount.toStringAsFixed(2)}',
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
              ),
              const SizedBox(height: 16),

              // Payment input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CupertinoTextField(
                        controller: _amountController,
                        placeholder: 'Enter amount paid',
                        keyboardType: TextInputType.number,
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text('\$'),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CupertinoColors.lightBackgroundGray,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                      if (_amountController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Change:'),
                            Text(
                              '\$${((double.tryParse(_amountController.text) ?? 0.0) - totalAmount).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Complete order button
              CupertinoButton(
                color: CupertinoTheme.of(context).primaryColor,
                child: _isProcessing
                    ? const CupertinoActivityIndicator()
                    : const Text('Complete Order',
                    style: TextStyle(color: CupertinoColors.white),),

                onPressed: _isProcessing ? null : _processOrder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}