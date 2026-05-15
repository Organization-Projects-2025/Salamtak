import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String? id; // Firestore document ID
  final String productId;
  final String userId;
  final String userName;
  final int rating; // 1-5 stars
  final String comment;
  final String createdAt;

  Review({
    this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'productId': productId,
    'userId': userId,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt,
  };

  factory Review.fromMap(Map<String, dynamic> map) => Review(
    id: map['id']?.toString(),
    productId: map['productId'] ?? '',
    userId: map['userId'] ?? '',
    userName: map['userName'] ?? 'Anonymous',
    rating: map['rating'] ?? 0,
    comment: map['comment'] ?? '',
    createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
  );

  /// Build from a Firestore DocumentSnapshot
  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle both Timestamp and String formats for createdAt
    final createdAtField = data['createdAt'];
    String createdAt;

    if (createdAtField is Timestamp) {
      createdAt = createdAtField.toDate().toIso8601String();
    } else if (createdAtField is String) {
      createdAt = createdAtField;
    } else {
      createdAt = DateTime.now().toIso8601String();
    }

    return Review(
      id: doc.id,
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      createdAt: createdAt,
    );
  }
}
