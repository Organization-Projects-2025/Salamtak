import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {'productId': product.id, 'quantity': quantity};
  }
}

class Cart {
  final String userId;
  final Map<String, int> items; // productId -> quantity
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromMap(Map<String, dynamic> map, String userId) {
    Map<String, int> items = {};
    if (map['items'] != null) {
      (map['items'] as Map<String, dynamic>).forEach((key, value) {
        items[key] = value is int ? value : int.parse(value.toString());
      });
    }

    return Cart(
      userId: userId,
      items: items,
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get totalItems {
    return items.values.fold(0, (sum, quantity) => sum + quantity);
  }
}
