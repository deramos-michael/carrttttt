import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'models/cart.dart';
import 'screens/products_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';

void main() {
  runApp(const MyApp());
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
      home: ConnectionChecker(),
    );
  }
}

class ConnectionChecker extends StatefulWidget {
  const ConnectionChecker({super.key});

  @override
  ConnectionCheckerState createState() => ConnectionCheckerState();
}

class ConnectionCheckerState extends State<ConnectionChecker> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    var result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });

      if (!_isConnected) {
        _showNoInternetDialog();
      }
    });
  }

  void _showNoInternetDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("No Internet"),
        content: const Text("Please check your connection."),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isConnected ? const MainScreen() : _buildNoInternetScreen();
  }

  Widget _buildNoInternetScreen() {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("No Connection"),
      ),
      child: const Center(
        child: Text("You are offline. Please connect to the internet."),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
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
