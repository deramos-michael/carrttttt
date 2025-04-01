import 'package:flutter/cupertino.dart';

import 'models/cart.dart';
import 'screens/products_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';

void main() {
  runApp(const MyApp(

  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Ordering System',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Cart _cart = Cart();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cube_box),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_text),
            label: 'Orders',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return ProductsScreen(cart: _cart);
          case 1:
            return CartScreen(cart: _cart);
          case 2:
            return const OrdersScreen();
          default:
            return ProductsScreen(cart: _cart);
        }
      },
    );
  }
}