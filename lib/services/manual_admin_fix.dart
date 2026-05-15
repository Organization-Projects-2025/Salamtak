import 'package:cloud_firestore/cloud_firestore.dart';

/// Manual fix for admin account Firestore data
/// Run this if admin login fails with unknown-error
class ManualAdminFix {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Searches for any user with admin national ID and fixes their data
  static Future<void> fixAdminAccount() async {
    const adminNationalId = '12345678901234';
    const adminName = 'System Administrator';
    const adminEmail = 'admin@salamtak.com';
    const adminPhone = '01000000000';

    try {
      print('=== MANUAL ADMIN FIX START ===');
      print('Searching for admin user in Firestore...');

      // Search for user with admin national ID
      final querySnapshot =
          await _db
              .collection('users')
              .where('nationalId', isEqualTo: adminNationalId)
              .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ No user found with National ID: $adminNationalId');
        print(
          'The Firebase Auth account exists but Firestore document is missing.',
        );
        print('');
        print(
          'SOLUTION: You need to manually get the UID from Firebase Console:',
        );
        print('1. Go to Firebase Console > Authentication');
        print('2. Find user with email: $adminNationalId@salamtak.com');
        print('3. Copy the UID');
        print(
          '4. Then call: ManualAdminFix.createFirestoreDoc("YOUR_UID_HERE")',
        );
        return;
      }

      // Fix the found user
      for (final doc in querySnapshot.docs) {
        print('✓ Found user with ID: ${doc.id}');
        print('Current data: ${doc.data()}');

        await _db.collection('users').doc(doc.id).update({
          'nationalId': adminNationalId,
          'name': adminName,
          'email': adminEmail,
          'phone': adminPhone,
          'userType': 'admin',
          'address': 'System',
        });

        print('✓ Admin account fixed!');
        print('');
        print('╔════════════════════════════════════════╗');
        print('║        ADMIN ACCOUNT FIXED             ║');
        print('╠════════════════════════════════════════╣');
        print('║ National ID: $adminNationalId      ║');
        print('║ Password: admin123456          ║');
        print('╚════════════════════════════════════════╝');
      }

      print('=== MANUAL ADMIN FIX COMPLETE ===');
    } catch (e) {
      print('❌ Error fixing admin account: $e');
    }
  }

  /// Creates Firestore document for admin if you have the UID
  static Future<void> createFirestoreDoc(String uid) async {
    const adminNationalId = '12345678901234';
    const adminName = 'System Administrator';
    const adminEmail = 'admin@salamtak.com';
    const adminPhone = '01000000000';

    try {
      print('Creating Firestore document for UID: $uid');

      await _db.collection('users').doc(uid).set({
        'nationalId': adminNationalId,
        'name': adminName,
        'address': 'System',
        'email': adminEmail,
        'phone': adminPhone,
        'userType': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✓ Firestore document created successfully!');
      print('You can now login with:');
      print('National ID: $adminNationalId');
      print('Password: admin123456');
    } catch (e) {
      print('❌ Error creating Firestore document: $e');
    }
  }
}
