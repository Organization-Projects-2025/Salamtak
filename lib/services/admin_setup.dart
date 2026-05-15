import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// One-time setup to create an admin account
/// Call this once to initialize the admin user
class AdminSetup {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Admin credentials
  static const String adminNationalId = '12345678901234';
  static const String adminPassword = 'admin123456';
  static const String adminName = 'System Administrator';
  static const String adminEmail = 'admin@salamtak.com';
  static const String adminPhone = '01000000000';

  /// Creates the admin account in Firebase Auth and Firestore
  static Future<bool> createAdminAccount() async {
    final fakeEmail = '$adminNationalId@salamtak.com';

    try {
      print('=== ADMIN SETUP START ===');
      print('Checking if admin exists...');

      String? uid;

      // Check if admin already exists in Firebase Auth
      try {
        final existingCred = await _auth.signInWithEmailAndPassword(
          email: fakeEmail,
          password: adminPassword,
        );
        uid = existingCred.user!.uid;
        print('✓ Admin Firebase Auth account exists with UID: $uid');
        await _auth.signOut();
      } catch (e) {
        print('Admin Auth account doesn\'t exist. Error: $e');

        // If email-already-in-use, the account exists but password might be wrong
        // or there's a mismatch. Let's try to get the user by email.
        if (e.toString().contains('email-already-in-use')) {
          print(
            '⚠ Email already in use but login failed. Attempting recovery...',
          );
          // We can't recover this automatically, need to delete and recreate
          print(
            'Please delete the user from Firebase Console and restart the app.',
          );
          return false;
        }
      }

      // If we successfully logged in, verify/create Firestore data
      if (uid != null) {
        print('Verifying Firestore data...');
        final doc = await _db.collection('users').doc(uid).get();

        if (doc.exists) {
          final data = doc.data()!;
          print('✓ Admin Firestore data exists');
          print('  - userType: ${data['userType']}');
          print('  - nationalId: ${data['nationalId']}');

          // Ensure userType is admin
          if (data['userType'] != 'admin') {
            print('⚠ Updating userType to admin...');
            await _db.collection('users').doc(uid).update({
              'userType': 'admin',
            });
            print('✓ Updated to admin');
          }
        } else {
          print('⚠ Admin Firestore data missing! Creating...');
          await _db.collection('users').doc(uid).set({
            'nationalId': adminNationalId,
            'name': adminName,
            'address': 'System',
            'email': adminEmail,
            'phone': adminPhone,
            'userType': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('✓ Admin Firestore data created');
        }

        print('');
        print('╔════════════════════════════════════════╗');
        print('║      ADMIN ACCOUNT READY TO USE       ║');
        print('╠════════════════════════════════════════╣');
        print('║ National ID: $adminNationalId      ║');
        print('║ Password: $adminPassword          ║');
        print('╚════════════════════════════════════════╝');
        print('');
        print('=== ADMIN SETUP COMPLETE ===');
        return true;
      }

      // Create new admin account
      print('Creating new Firebase Auth account...');
      final cred = await _auth.createUserWithEmailAndPassword(
        email: fakeEmail,
        password: adminPassword,
      );

      uid = cred.user!.uid;
      print('✓ Firebase Auth account created with UID: $uid');

      // Create admin profile in Firestore
      print('Creating Firestore profile...');
      await _db.collection('users').doc(uid).set({
        'nationalId': adminNationalId,
        'name': adminName,
        'address': 'System',
        'email': adminEmail,
        'phone': adminPhone,
        'userType': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✓ Firestore profile created');

      print('');
      print('╔════════════════════════════════════════╗');
      print('║   ADMIN ACCOUNT CREATED SUCCESSFULLY   ║');
      print('╠════════════════════════════════════════╣');
      print('║ National ID: $adminNationalId      ║');
      print('║ Password: $adminPassword          ║');
      print('╚════════════════════════════════════════╝');
      print('');

      await _auth.signOut();
      print('=== ADMIN SETUP COMPLETE ===');
      return true;
    } catch (e) {
      print('❌ Error creating admin account: $e');
      return false;
    }
  }
}
