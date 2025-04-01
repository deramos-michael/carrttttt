import 'package:flutter/cupertino.dart';

class OrderDetailScreen extends StatelessWidget {
  final int orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Order #$orderId'),
      ),
      child: Center(
        child: Text('Details for Order #$orderId'),
      ),
    );
  }
}