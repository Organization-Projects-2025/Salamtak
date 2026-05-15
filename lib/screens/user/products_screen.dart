import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';
import 'cart_screen.dart';
import 'user_home_screen.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to home tab
                final userHomeState =
                    context.findAncestorStateOfType<UserHomeScreenState>();
                userHomeState?.navigateToTab(0);
              },
              child: Image.asset(
                'assets/logof.png',
                width: 35,
                height: 35,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Text(l10n.products),
          ],
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient, // Use website gradient
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No products available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final products =
              snapshot.data!.docs
                  .map(
                    (doc) => Product.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              // Responsive grid: adjust columns based on screen width
              int crossAxisCount;
              double childAspectRatio;
              double horizontalPadding;
              double spacing;
              
              if (constraints.maxWidth < 360) {
                // Very small screens (e.g., iPhone SE)
                crossAxisCount = 1;
                childAspectRatio = 1.3;
                horizontalPadding = 16;
                spacing = 12;
              } else if (constraints.maxWidth < 400) {
                // Small screens (iPhone 12 Pro, etc.)
                crossAxisCount = 2;
                childAspectRatio = 0.72;
                horizontalPadding = 12;
                spacing = 10;
              } else if (constraints.maxWidth < 600) {
                // Medium phones
                crossAxisCount = 2;
                childAspectRatio = 0.75;
                horizontalPadding = 16;
                spacing = 12;
              } else if (constraints.maxWidth < 900) {
                // Tablets
                crossAxisCount = 3;
                childAspectRatio = 0.8;
                horizontalPadding = 20;
                spacing = 16;
              } else {
                // Large screens (desktop)
                crossAxisCount = 4;
                childAspectRatio = 0.85;
                horizontalPadding = 24;
                spacing = 16;
              }

              return GridView.builder(
                padding: EdgeInsets.all(horizontalPadding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: products[index],
                    isCompact: constraints.maxWidth < 400,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isCompact;

  const ProductCard({
    super.key,
    required this.product,
    this.isCompact = false,
  });

  String _getImagePath(String productName) {
    final name = productName.toLowerCase();
    if (name.contains('vest')) return 'assets/products/vest.jpeg';
    if (name.contains('ear') || name.contains('muff')) {
      return 'assets/products/earmuffs.jpeg';
    }
    if (name.contains('jacket')) return 'assets/products/jacket.jpeg';
    if (name.contains('hard hat')) return 'assets/products/hardhat.jpeg';
    if (name.contains('helmet')) return 'assets/products/helmet.jpeg';
    if (name.contains('boots')) return 'assets/products/boots.jpeg';
    return 'assets/products/placeholder.png';
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);
    
    // Responsive sizing based on compact mode
    final imageHeight = isCompact ? 100.0 : 120.0;
    final cardPadding = isCompact ? 8.0 : 10.0;
    final titleFontSize = isCompact ? 12.0 : 13.0;
    final priceFontSize = isCompact ? 15.0 : 16.0;
    final buttonPadding = isCompact ? 6.0 : 8.0;
    final buttonFontSize = isCompact ? 10.0 : 11.0;
    final iconSize = isCompact ? 14.0 : 15.0;
    final borderRadius = isCompact ? 12.0 : 16.0;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(borderRadius),
              ),
              child: Container(
                height: imageHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[100]!, Colors.grey[200]!],
                  ),
                ),
                child: Image.asset(
                  _getImagePath(product.name),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      size: isCompact ? 32 : 40,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: isCompact ? 2 : 4),
                    Text(
                      'EGP ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: priceFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: isCompact ? 32 : 36,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await cartProvider.addItem(product, 1);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.addedToCart),
                                  backgroundColor: AppTheme.success,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  action: SnackBarAction(
                                    label: 'VIEW',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const CartScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AppTheme.danger,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: buttonPadding,
                            horizontal: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_shopping_cart, size: iconSize),
                            SizedBox(width: isCompact ? 2 : 4),
                            Text(
                              'Add',
                              style: TextStyle(fontSize: buttonFontSize),
                            ),
                          ],
                        ),
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
