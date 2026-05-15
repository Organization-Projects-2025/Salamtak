import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final int stock;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.stock,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    // Handle both Timestamp and String formats for createdAt
    DateTime createdAt;
    final createdAtField = map['createdAt'];
    if (createdAtField is Timestamp) {
      createdAt = createdAtField.toDate();
    } else if (createdAtField is String) {
      createdAt = DateTime.parse(createdAtField);
    } else {
      createdAt = DateTime.now();
    }

    // Handle both Timestamp and String formats for updatedAt
    DateTime updatedAt;
    final updatedAtField = map['updatedAt'];
    if (updatedAtField is Timestamp) {
      updatedAt = updatedAtField.toDate();
    } else if (updatedAtField is String) {
      updatedAt = DateTime.parse(updatedAtField);
    } else {
      updatedAt = DateTime.now();
    }

    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      image: map['image'] ?? '',
      stock: map['stock'] ?? 0,
      category: map['category'] ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'stock': stock,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
