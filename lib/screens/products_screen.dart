import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../models/cart.dart';
import 'product_detail_screen.dart';


class ProductsScreen extends StatefulWidget {
  final Cart cart;

  const ProductsScreen({super.key, required this.cart});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      _fetchProducts();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchProducts({bool showLoading = false}) async {
    if (showLoading) setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://warehousemanagementsystem.shop/api.php/products'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _products = (json.decode(response.body) as List)
              .map((json) => Product.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load products. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  void _showProductManagementMenu() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Product Management'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showAddProductDialog();
            },
            child: const Text('Add Product'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showProductSelectionDialog('Edit');
            },
            child: const Text('Edit Product'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _showProductSelectionDialog('Delete');
            },
            child: const Text('Delete Product'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showProductSelectionDialog(String action) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Select Product to $action'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: ListView.builder(
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.pop(context);
                  if (action == 'Edit') {
                    _showEditProductDialog(product);
                  } else {
                    _showDeleteConfirmationDialog(product);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                      Expanded(child: Text(product.name)),
                      Text('₱${product.price.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final imageUrlController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(nameController, 'Product Name'),
              _buildTextField(priceController, 'Price', isNumber: true),
              _buildTextField(stockController, 'Stock Quantity', isNumber: true),
              _buildTextField(imageUrlController, 'Image URL (optional)'),
              const SizedBox(height: 10),
              if (imageUrlController.text.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: Image.network(
                    imageUrlController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(CupertinoIcons.photo, size: 50),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Add'),
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  stockController.text.isEmpty) {
                _showErrorDialog('Please fill all required fields');
                return;
              }

              final newProduct = {
                'name': nameController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
                'stock': int.tryParse(stockController.text) ?? 0,
                'image_url': imageUrlController.text.isNotEmpty
                    ? imageUrlController.text
                    : null, // Send null if no URL provided
              };

              await _addProduct(newProduct);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    final stockController = TextEditingController(text: product.stock.toString());
    final imageUrlController = TextEditingController(text: product.imageUrl ?? '');

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(nameController, 'Product Name'),
              _buildTextField(priceController, 'Price', isNumber: true),
              _buildTextField(stockController, 'Stock Quantity', isNumber: true),
              _buildTextField(imageUrlController, 'Image URL (optional)'),
              const SizedBox(height: 10),
              if (imageUrlController.text.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: Image.network(
                    imageUrlController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(CupertinoIcons.photo, size: 50),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoActionSheetAction(
            child: const Text('Save'),
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  stockController.text.isEmpty) {
                _showErrorDialog('Please fill all required fields');
                return;
              }

              final updatedProduct = {
                'name': nameController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
                'stock': int.tryParse(stockController.text) ?? 0,
                'image_url': imageUrlController.text.isNotEmpty
                    ? imageUrlController.text
                    : null, // Send null if no URL provided
              };

              await _updateProduct(product.id, updatedProduct);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String placeholder,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        padding: const EdgeInsets.all(12),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.systemGrey),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Product product) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Delete'),
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProduct(product.id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await http.post(
        Uri.parse('https://warehousemanagementsystem.shop/api.php/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(productData),
      );

      if (response.statusCode == 200) {
        _fetchProducts(showLoading: true);
      } else {
        throw Exception('Failed to add product. Status: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      final response = await http.put(
        Uri.parse('https://warehousemanagementsystem.shop/api.php/products/$productId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(productData),
      );

      if (response.statusCode == 200) {
        _fetchProducts(showLoading: true);
      } else {
        throw Exception('Failed to update product. Status: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _deleteProduct(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://warehousemanagementsystem.shop/api.php/products/$productId'),
      );

      if (response.statusCode == 200) {
        _fetchProducts(showLoading: true);
      } else {
        throw Exception('Failed to delete product. Status: ${response.statusCode}');
      }
    } catch (e) {
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
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Products'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showProductManagementMenu,
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20.0),
        child: CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async => _fetchProducts(showLoading: true),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 32)),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getGridItemCount(context),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildProductCard(context, _products[index]),
                childCount: _products.length,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  int _getGridItemCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 800) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    Color stockColor;
    String stockStatus;
    String stockQuantity = '';

    if (product.stock == 0) {
      stockColor = CupertinoColors.systemRed;
      stockStatus = "Out of Stock";
    } else if (product.stock <= 20) {
      stockColor = CupertinoColors.systemOrange;
      stockStatus = "Low Stock";
      stockQuantity = "(${product.stock})";
    } else if (product.stock >= 100) {
      stockColor = CupertinoColors.systemGreen;
      stockStatus = "High Stock";
      stockQuantity = "(${product.stock})";
    } else {
      stockColor = CupertinoColors.secondaryLabel;
      stockStatus = "In Stock";
      stockQuantity = "(${product.stock})";
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: product.stock > 0
          ? () async {
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
          _fetchProducts(showLoading: true);
        }
      }
          : null,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? Image.network(
                product.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderImage(),
              )
                  : _buildPlaceholderImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₱${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: CupertinoTheme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.circle_filled,
                        size: 14,
                        color: stockColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$stockStatus $stockQuantity',
                        style: TextStyle(
                          color: stockColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
        child: Icon(CupertinoIcons.photo, size: 60, color: CupertinoColors.systemGrey),
      ),
    );
  }
}