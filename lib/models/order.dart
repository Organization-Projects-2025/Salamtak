class Order {
  final String? id;
  final String userId;
  final String nationalId;
  final String userName;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // pending, processing, completed, cancelled
  final String createdAt;
  final String? deliveryAddress;
  final String? phoneNumber;
  final String? notes;

  Order({
    this.id,
    required this.userId,
    required this.nationalId,
    required this.userName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.deliveryAddress,
    this.phoneNumber,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nationalId': nationalId,
      'userName': userName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt,
      'deliveryAddress': deliveryAddress,
      'phoneNumber': phoneNumber,
      'notes': notes,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      nationalId: map['nationalId'] ?? '',
      userName: map['userName'] ?? '',
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] ?? '',
      deliveryAddress: map['deliveryAddress'],
      phoneNumber: map['phoneNumber'],
      notes: map['notes'],
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }
}
