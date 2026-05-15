import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';

class Report {
  final String? id; // Firestore document ID
  final String uid; // Firebase Auth UID
  final String nationalId;
  final String name;
  final String type;
  final String description;
  final String imagePath;
  final String status;
  final String severity;
  final String createdAt;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;

  Report({
    this.id,
    required this.uid,
    required this.nationalId,
    required this.name,
    required this.type,
    required this.description,
    required this.imagePath,
    required this.status,
    required this.severity,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.locationAddress,
  });

  /// Check if this report has a valid image
  bool hasImage() {
    return imagePath.isNotEmpty;
  }

  /// Get the full image URL
  /// Handles both Firebase Storage URLs and website relative paths
  String getFullImageUrl() {
    if (imagePath.isEmpty) {
      return '';
    }
    return AppConfig.getImageUrl(imagePath);
  }

  /// Check if the image is from Firebase Storage
  bool isFirebaseImage() {
    return AppConfig.isFirebaseStorageUrl(imagePath);
  }

  /// Check if the image is from website upload
  bool isWebsiteImage() {
    return AppConfig.isWebsitePath(imagePath);
  }

  /// Validate that the report has all required fields
  bool isValid() {
    return uid.isNotEmpty &&
        nationalId.isNotEmpty &&
        type.isNotEmpty &&
        description.isNotEmpty &&
        status.isNotEmpty &&
        createdAt.isNotEmpty;
  }

  /// Get a human-readable location string
  String getLocationString() {
    if (locationAddress != null && locationAddress!.isNotEmpty) {
      return locationAddress!;
    }
    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}';
    }
    return 'Location not available';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'uid': uid,
    'nationalId': nationalId,
    'name': name,
    'type': type,
    'description': description,
    'imagePath': imagePath,
    'status': status,
    'severity': severity,
    'createdAt': createdAt,
    'latitude': latitude,
    'longitude': longitude,
    'locationAddress': locationAddress,
  };

  factory Report.fromMap(Map<String, dynamic> map) => Report(
    id: map['id']?.toString(),
    uid: map['uid'] ?? '',
    nationalId: map['nationalId'] ?? '',
    name: map['name'] ?? '',
    type: map['type'] ?? '',
    description: map['description'] ?? '',
    imagePath: map['imagePath'] ?? '',
    status: map['status'] ?? 'Pending',
    severity: map['severity'] ?? 'Medium',
    createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
    latitude:
        map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
    longitude:
        map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
    locationAddress: map['locationAddress'],
  );

  /// Build from a Firestore DocumentSnapshot
  /// Handles missing fields gracefully with default values
  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Handle both Timestamp and String formats for createdAt
    final createdAtField = data['createdAt'];
    String createdAt;

    if (createdAtField is Timestamp) {
      createdAt = createdAtField.toDate().toIso8601String();
    } else if (createdAtField is String) {
      createdAt = createdAtField;
    } else {
      // Fallback to current time if createdAt is missing
      createdAt = DateTime.now().toIso8601String();
      print('⚠️ Report ${doc.id} missing createdAt field, using current time');
    }

    return Report(
      id: doc.id,
      uid: data['uid'] ?? '',
      nationalId: data['nationalId'] ?? '',
      name: data['name'] ?? 'Unknown',
      type: data['type'] ?? 'Other',
      description: data['description'] ?? 'No description',
      imagePath: data['imagePath'] ?? '',
      status: data['status'] ?? 'pending',
      severity: data['severity'] ?? 'Medium',
      createdAt: createdAt,
      latitude:
          data['latitude'] != null
              ? (data['latitude'] as num).toDouble()
              : null,
      longitude:
          data['longitude'] != null
              ? (data['longitude'] as num).toDouble()
              : null,
      locationAddress: data['location'] ?? data['locationAddress'],
    );
  }

  /// Create a copy of this report with updated fields
  Report copyWith({
    String? id,
    String? uid,
    String? nationalId,
    String? name,
    String? type,
    String? description,
    String? imagePath,
    String? status,
    String? severity,
    String? createdAt,
    double? latitude,
    double? longitude,
    String? locationAddress,
  }) {
    return Report(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      nationalId: nationalId ?? this.nationalId,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAddress: locationAddress ?? this.locationAddress,
    );
  }
}
