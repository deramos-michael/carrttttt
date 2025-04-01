import 'package:flutter/cupertino.dart';
import '../../models/cart.dart';

import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final Cart cart;

  const CartScreen({super.key, required this.cart});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Your Cart'),
        trailing: widget.cart.items.isNotEmpty
            ? CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Checkout'),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => CheckoutScreen(cart: widget.cart),
              ),
            );
          },
        )
            : null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: widget.cart.items.isEmpty
                  ? const Center(child: Text('Your cart is empty'))
                  : ListView.builder(
                itemCount: widget.cart.items.length,
                itemBuilder: (context, index) {
                  final item = widget.cart.items[index];
                  return _buildCartItem(item);
                },
              ),
            ),
            if (widget.cart.items.isNotEmpty) _buildTotalSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Dismissible(
      key: Key(item.product.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: CupertinoColors.destructiveRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          widget.cart.removeItem(item.product.id);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('₱${item.product.price.toStringAsFixed(2)}'),
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
            Row(
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.all(6),
                  minSize: 0,
                  child: const Icon(CupertinoIcons.minus_circled),
                  onPressed: () {
                    if (item.quantity > 1) {
                      setState(() {
                        widget.cart.updateQuantity(
                            item.product.id, item.quantity - 1);
                      });
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(item.quantity.toString()),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(6),
                  minSize: 0,
                  child: const Icon(CupertinoIcons.plus_circled),
                  onPressed: () {
                    if (item.quantity < item.product.stock) {
                      setState(() {
                        widget.cart.updateQuantity(
                            item.product.id, item.quantity + 1);
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
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

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.extraLightBackgroundGray,
        border: Border(
          top: BorderSide(
              color: CupertinoColors.lightBackgroundGray, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                '₱${widget.cart.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: CupertinoTheme.of(context).primaryColor,
              child: const Text('Proceed to Checkout',
                  style: TextStyle(color: CupertinoColors.white)),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => CheckoutScreen(cart: widget.cart),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}