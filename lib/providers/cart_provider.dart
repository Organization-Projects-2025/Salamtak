import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, CartItem> _items = {};
  String? _userId;
  bool _isLoading = false;

  Map<String, CartItem> get items => {..._items};
  bool get isLoading => _isLoading;

  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void setUserId(String userId) {
    _userId = userId;
    loadCart();
  }

  Future<void> loadCart() async {
    if (_userId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final cartDoc = await _firestore.collection('carts').doc(_userId).get();

      if (cartDoc.exists) {
        final cartData = cartDoc.data()!;
        final items = cartData['items'] as Map<String, dynamic>? ?? {};

        _items.clear();

        for (var entry in items.entries) {
          final productId = entry.key;
          final quantity =
              entry.value is int
                  ? entry.value
                  : int.parse(entry.value.toString());

          // Load product details
          final productDoc =
              await _firestore.collection('products').doc(productId).get();
          if (productDoc.exists) {
            final product = Product.fromMap(productDoc.data()!, productDoc.id);
            _items[productId] = CartItem(product: product, quantity: quantity);
          }
        }
      }
    } catch (e) {
      print('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(Product product, int quantity) async {
    if (_userId == null) return;

    try {
      if (_items.containsKey(product.id)) {
        _items[product.id]!.quantity += quantity;
      } else {
        _items[product.id] = CartItem(product: product, quantity: quantity);
      }

      await _saveCart();
      notifyListeners();
    } catch (e) {
      print('Error adding item: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (_userId == null) return;

    try {
      if (quantity <= 0) {
        await removeItem(productId);
        return;
      }

      if (_items.containsKey(productId)) {
        _items[productId]!.quantity = quantity;
        await _saveCart();
        notifyListeners();
      }
    } catch (e) {
      print('Error updating quantity: $e');
      rethrow;
    }
  }

  Future<void> removeItem(String productId) async {
    if (_userId == null) return;

    try {
      _items.remove(productId);
      await _saveCart();
      notifyListeners();
    } catch (e) {
      print('Error removing item: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    if (_userId == null) return;

    try {
      _items.clear();
      await _firestore.collection('carts').doc(_userId).delete();
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }

  Future<void> _saveCart() async {
    if (_userId == null) return;

    try {
      final items = <String, int>{};
      _items.forEach((key, value) {
        items[key] = value.quantity;
      });

      await _firestore.collection('carts').doc(_userId).set({
        'userId': _userId,
        'items': items,
        'updatedAt': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving cart: $e');
      rethrow;
    }
  }
}
