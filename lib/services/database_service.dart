import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user.dart' as app_user;
import '../models/report.dart';
import '../models/review.dart';
import 'local_image_storage.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Current logged-in Firebase user
  User? get currentFirebaseUser => _auth.currentUser;

  /// Login with National ID or Work ID + password
  /// Uses nationalId@salamtak.com as the Firebase Auth email
  Future<app_user.User?> login(String nationalId, String password) async {
    print('=== LOGIN ATTEMPT ===');
    print('ID: $nationalId');

    // HARDCODED ADMIN - Work ID 221007689
    if (nationalId == '221007689' && password == '631663') {
      print('✓ Admin login successful (Work ID)');
      return app_user.User(
        id: 'admin-221007689',
        nationalId: '221007689',
        phoneNumber: '01000000000',
        name: 'Administrator',
        userType: 'admin',
      );
    }

    // LEGACY ADMIN - Keep for backward compatibility
    if (nationalId == '12345678901234' && password == 'admin123456') {
      print('✓ Admin login successful (legacy)');
      return app_user.User(
        id: 'admin-hardcoded',
        nationalId: '12345678901234',
        phoneNumber: '01000000000',
        name: 'System Administrator',
        userType: 'admin',
      );
    }

    // HARDCODED TEST USER - Bypass Firebase Auth completely
    if (nationalId == '11111111111111' && password == 'user123456') {
      print('✓ Test user login successful (hardcoded bypass)');
      return app_user.User(
        id: 'user-hardcoded',
        nationalId: '11111111111111',
        phoneNumber: '01111111111',
        name: 'Test User',
        userType: 'user',
      );
    }

    // Regular Firebase Auth login for other users
    final fakeEmail = '$nationalId@salamtak.com';
    print('Email: $fakeEmail');
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );
      print('✓ Firebase Auth successful');
      final uid = cred.user!.uid;
      print('UID: $uid');
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) {
        print('❌ User document not found in Firestore');
        return null;
      }
      final data = doc.data()!;
      print('✓ User data: $data');
      final user = app_user.User(
        id: uid,
        nationalId: data['nationalId'] ?? nationalId,
        phoneNumber: data['phone'] ?? '',
        name: data['name'] ?? '',
        userType: data['userType'] ?? 'user',
      );
      print('✓ Login successful as ${user.userType}');
      return user;
    } catch (e) {
      print('❌ Login failed: $e');
      return null;
    }
  }

  /// Sign up with National ID + password — also saves profile to Firestore
  Future<app_user.User?> signUp({
    required String nationalId,
    required String name,
    required String address,
    required String email,
    required String phone,
    required String password,
  }) async {
    final fakeEmail = '$nationalId@salamtak.com';
    print('=== SIGNUP ATTEMPT ===');
    print('National ID: $nationalId');
    print('Name: $name');
    print('Email: $fakeEmail');

    try {
      print('Creating Firebase Auth account...');
      final cred = await _auth.createUserWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );
      final uid = cred.user!.uid;
      print('✓ Firebase Auth account created with UID: $uid');

      print('Creating Firestore profile...');
      await _db.collection('users').doc(uid).set({
        'nationalId': nationalId,
        'name': name,
        'address': address,
        'email': email,
        'phone': phone,
        'userType': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✓ Firestore profile created');
      print('✓ Signup successful!');

      return app_user.User(
        id: uid,
        nationalId: nationalId,
        phoneNumber: phone,
        name: name,
        userType: 'user',
        email: email,
        address: address,
      );
    } catch (e) {
      print('❌ Signup failed: $e');
      return null;
    }
  }

  /// Register user (alternative method name for signup)
  Future<bool> registerUser(app_user.User user, String password) async {
    final result = await signUp(
      nationalId: user.nationalId,
      name: user.name,
      address: user.address ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber,
      password: password,
    );
    return result != null;
  }

  /// Submit a report — saved to Firestore "reports" collection
  Future<String?> createReport(Report report) async {
    print('=== CREATING REPORT ===');
    print('Report UID: ${report.uid}');
    print('National ID: ${report.nationalId}');
    print('Type: ${report.type}');

    try {
      // Use the UID from the report object (which comes from SharedPreferences)
      // This works for both Firebase Auth users and hardcoded users
      final uid =
          report.uid.isNotEmpty ? report.uid : (currentFirebaseUser?.uid ?? '');

      print('Using UID: $uid');

      // Get current timestamp as string for consistency with website
      final now = DateTime.now().toIso8601String();

      final docRef = await _db.collection('reports').add({
        'uid': uid,
        'nationalId': report.nationalId,
        'name': report.name,
        'type': report.type,
        'description': report.description,
        'imagePath': report.imagePath,
        'status': 'pending',
        'severity': report.severity,
        'location': report.locationAddress ?? '',
        'latitude': report.latitude,
        'longitude': report.longitude,
        'createdAt': now, // String format for website compatibility
        'updatedAt': now, // Add updatedAt field
      });

      print('✓ Report created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating report: $e');
      return null;
    }
  }

  /// Get reports for the current logged-in user (real-time stream)
  /// Query by nationalId to match website reports
  Stream<List<Report>> getUserReportsStream(String uid) {
    print('=== FETCHING USER REPORTS ===');
    print('UID: $uid');

    // Remove orderBy to avoid Firestore index requirement
    // Sort in memory instead
    return _db
        .collection('reports')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          print('Found ${snap.docs.length} reports for UID: $uid');
          final reports =
              snap.docs.map((d) => Report.fromFirestore(d)).toList();

          // Sort by createdAt in memory (newest first)
          reports.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.createdAt);
              final dateB = DateTime.parse(b.createdAt);
              return dateB.compareTo(dateA); // Descending order
            } catch (e) {
              print('Error parsing date for sorting: $e');
              return 0; // Keep original order if parsing fails
            }
          });

          return reports;
        });
  }

  /// Get reports by national ID (for website compatibility)
  /// This method now includes fallback logic for better reliability
  Stream<List<Report>> getUserReportsByNationalId(String nationalId) {
    print('=== FETCHING REPORTS BY NATIONAL ID ===');
    print('National ID: $nationalId');

    // Remove orderBy to avoid Firestore index requirement
    // Sort in memory instead
    return _db
        .collection('reports')
        .where('nationalId', isEqualTo: nationalId)
        .snapshots()
        .handleError((error) {
          print('❌ Error fetching reports by nationalId: $error');
          // Return empty stream on error
          return const Stream.empty();
        })
        .map((snap) {
          print(
            'Found ${snap.docs.length} reports for National ID: $nationalId',
          );

          if (snap.docs.isEmpty) {
            print('⚠️ No reports found for nationalId: $nationalId');
            print('   This could mean:');
            print('   1. User has no reports yet');
            print(
              '   2. Reports were created with different nationalId format',
            );
            print('   3. Reports only have uid field (app-created reports)');
          }

          final reports =
              snap.docs
                  .map((d) {
                    try {
                      return Report.fromFirestore(d);
                    } catch (e) {
                      print('❌ Error parsing report ${d.id}: $e');
                      return null;
                    }
                  })
                  .whereType<Report>()
                  .toList(); // Filter out nulls

          // Sort by createdAt in memory (newest first)
          reports.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.createdAt);
              final dateB = DateTime.parse(b.createdAt);
              return dateB.compareTo(dateA); // Descending order
            } catch (e) {
              print('Error parsing date for sorting: $e');
              return 0; // Keep original order if parsing fails
            }
          });

          return reports;
        });
  }

  /// Get all reports (admin) — real-time stream
  /// Removed orderBy to avoid index requirement, sorts in memory
  Stream<List<Report>> getAllReportsStream() {
    print('=== FETCHING ALL REPORTS (ADMIN) ===');

    return _db
        .collection('reports')
        .snapshots()
        .handleError((error) {
          print('❌ Error fetching all reports: $error');
          return const Stream.empty();
        })
        .map((snap) {
          print('Found ${snap.docs.length} total reports');

          final reports =
              snap.docs
                  .map((d) {
                    try {
                      return Report.fromFirestore(d);
                    } catch (e) {
                      print('❌ Error parsing report ${d.id}: $e');
                      return null;
                    }
                  })
                  .whereType<Report>()
                  .toList(); // Filter out nulls

          // Sort by createdAt in memory (newest first)
          reports.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.createdAt);
              final dateB = DateTime.parse(b.createdAt);
              return dateB.compareTo(dateA); // Descending order
            } catch (e) {
              print('Error parsing date for sorting: $e');
              return 0; // Keep original order if parsing fails
            }
          });

          return reports;
        });
  }

  /// Update report status (admin)
  Future<void> updateReportStatus(String reportId, String status) async {
    await _db.collection('reports').doc(reportId).update({'status': status});
  }

  /// Upload report image to local storage
  /// Images are saved to uploads/reports/ folder on your PC
  /// For web: images are stored as data URLs in the browser
  Future<String?> uploadReportImage(XFile imageFile) async {
    try {
      print('=== UPLOADING IMAGE TO LOCAL STORAGE ===');
      
      // Use local image storage instead of Firebase
      final imagePath = await LocalImageStorage.instance.saveImage(imageFile);
      
      if (imagePath != null) {
        print('✓ Image saved locally: $imagePath');
        return imagePath;
      } else {
        print('❌ Failed to save image locally');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  /// Create a product review
  Future<String?> createReview(Review review) async {
    print('=== CREATING REVIEW ===');
    print('Product ID: ${review.productId}');
    print('User ID: ${review.userId}');
    print('Rating: ${review.rating}');

    try {
      final docRef = await _db.collection('reviews').add({
        'productId': review.productId,
        'userId': review.userId,
        'userName': review.userName,
        'rating': review.rating,
        'comment': review.comment,
        'createdAt': review.createdAt,
      });

      print('✓ Review created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating review: $e');
      return null;
    }
  }

  /// Get reviews for a specific product
  Stream<List<Review>> getProductReviewsStream(String productId) {
    return _db
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Review.fromFirestore(d)).toList());
  }

  /// Get all reviews for a product (one-time fetch)
  Future<List<Review>> getProductReviews(String productId) async {
    try {
      final snapshot =
          await _db
              .collection('reviews')
              .where('productId', isEqualTo: productId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((d) => Review.fromFirestore(d)).toList();
    } catch (e) {
      print('❌ Error fetching reviews: $e');
      return [];
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
