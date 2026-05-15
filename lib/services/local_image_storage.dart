import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:idb_shim/idb_browser.dart';

/// Local image storage service for storing report images
/// - Desktop/Mobile: Saves to filesystem (uploads/reports/)
/// - Web: Saves to IndexedDB (persistent browser storage)
class LocalImageStorage {
  static final LocalImageStorage instance = LocalImageStorage._init();
  LocalImageStorage._init();

  // IndexedDB for web
  static const String _dbName = 'salamtak_images';
  static const String _storeName = 'images';
  static const int _dbVersion = 1;
  Database? _db;

  /// Initialize IndexedDB for web platform
  Future<Database> _getDatabase() async {
    if (_db != null) return _db!;

    final idbFactory = getIdbFactory()!;
    _db = await idbFactory.open(_dbName, version: _dbVersion,
        onUpgradeNeeded: (VersionChangeEvent event) {
      final db = event.database;
      if (!db.objectStoreNames.contains(_storeName)) {
        db.createObjectStore(_storeName);
      }
    });

    return _db!;
  }

  /// Get the uploads directory path (desktop/mobile only)
  Future<Directory> getUploadsDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('File system not available on web');
    }

    final currentDir = Directory.current;
    final uploadsDir = Directory(
      path.join(currentDir.path, 'uploads', 'reports'),
    );

    if (!await uploadsDir.exists()) {
      await uploadsDir.create(recursive: true);
      print('✓ Created uploads directory: ${uploadsDir.path}');
    }

    return uploadsDir;
  }

  /// Save an image file to local storage
  /// Returns the relative path to the image (e.g., "uploads/reports/123456_image.jpg")
  Future<String?> saveImage(XFile imageFile) async {
    try {
      print('=== SAVING IMAGE LOCALLY ===');
      print('Original file: ${imageFile.name}');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.name);
      final fileName = '${timestamp}_${imageFile.name}';
      final relativePath = 'uploads/reports/$fileName';

      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      print('Image size: ${bytes.length} bytes');

      if (kIsWeb) {
        // Web: Save to IndexedDB
        print('Web platform: Saving to IndexedDB');
        print('Key: $relativePath');
        
        final db = await _getDatabase();
        final txn = db.transaction(_storeName, idbModeReadWrite);
        final store = txn.objectStore(_storeName);
        
        // Store as List<int> for better compatibility
        await store.put(bytes.toList(), relativePath);
        await txn.completed;
        
        print('✓ Image saved to IndexedDB');
        print('Stored ${bytes.length} bytes');
        
        // Verify it was saved
        final verifyTxn = db.transaction(_storeName, idbModeReadOnly);
        final verifyStore = verifyTxn.objectStore(_storeName);
        final retrieved = await verifyStore.getObject(relativePath);
        print('✓ Verification: ${retrieved != null ? "Data found" : "Data NOT found"}');
        
        return relativePath;
      }

      // Desktop/Mobile: Save to filesystem
      final uploadsDir = await getUploadsDirectory();
      final filePath = path.join(uploadsDir.path, fileName);

      print('Saving to: $filePath');

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      print('✓ Image saved successfully');
      print('Relative path: $relativePath');

      return relativePath;
    } catch (e) {
      print('❌ Error saving image locally: $e');
      return null;
    }
  }

  /// Get the full file path for a relative path (desktop/mobile only)
  Future<String> getFullPath(String relativePath) async {
    if (kIsWeb) {
      return relativePath; // Return as-is for web
    }

    final currentDir = Directory.current;
    return path.join(currentDir.path, relativePath);
  }

  /// Check if an image file exists
  Future<bool> imageExists(String relativePath) async {
    if (kIsWeb) {
      try {
        final db = await _getDatabase();
        final txn = db.transaction(_storeName, idbModeReadOnly);
        final store = txn.objectStore(_storeName);
        final value = await store.getObject(relativePath);
        return value != null;
      } catch (e) {
        print('Error checking image existence: $e');
        return false;
      }
    }

    try {
      final fullPath = await getFullPath(relativePath);
      final file = File(fullPath);
      return await file.exists();
    } catch (e) {
      print('Error checking image existence: $e');
      return false;
    }
  }

  /// Delete an image file
  Future<bool> deleteImage(String relativePath) async {
    if (kIsWeb) {
      try {
        final db = await _getDatabase();
        final txn = db.transaction(_storeName, idbModeReadWrite);
        final store = txn.objectStore(_storeName);
        await store.delete(relativePath);
        await txn.completed;
        print('✓ Deleted image from IndexedDB: $relativePath');
        return true;
      } catch (e) {
        print('❌ Error deleting image: $e');
        return false;
      }
    }

    try {
      final fullPath = await getFullPath(relativePath);
      final file = File(fullPath);
      
      if (await file.exists()) {
        await file.delete();
        print('✓ Deleted image: $relativePath');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  /// Get image as bytes
  Future<Uint8List?> getImageBytes(String relativePath) async {
    if (kIsWeb) {
      try {
        print('=== LOADING IMAGE FROM INDEXEDDB ===');
        print('Key: $relativePath');
        
        final db = await _getDatabase();
        final txn = db.transaction(_storeName, idbModeReadOnly);
        final store = txn.objectStore(_storeName);
        final value = await store.getObject(relativePath);
        
        print('Retrieved value type: ${value?.runtimeType}');
        
        if (value == null) {
          print('❌ No data found for key: $relativePath');
          
          // Debug: List all keys in IndexedDB
          final allKeysTxn = db.transaction(_storeName, idbModeReadOnly);
          final allKeysStore = allKeysTxn.objectStore(_storeName);
          final cursor = allKeysStore.openCursor(autoAdvance: true);
          final keys = <String>[];
          await cursor.listen((cursorWithValue) {
            keys.add(cursorWithValue.key.toString());
          }).asFuture();
          print('Available keys in IndexedDB: $keys');
          
          return null;
        }
        
        if (value is Uint8List) {
          print('✓ Loaded ${value.length} bytes (Uint8List)');
          return value;
        } else if (value is List) {
          print('✓ Loaded ${value.length} bytes (List, converting)');
          return Uint8List.fromList(value.cast<int>());
        } else {
          print('❌ Unexpected value type: ${value.runtimeType}');
          return null;
        }
      } catch (e, stackTrace) {
        print('❌ Error reading image from IndexedDB: $e');
        print('Stack trace: $stackTrace');
        return null;
      }
    }

    try {
      final fullPath = await getFullPath(relativePath);
      final file = File(fullPath);
      
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      
      return null;
    } catch (e) {
      print('❌ Error reading image bytes: $e');
      return null;
    }
  }

  /// Convert base64 string to bytes (public for use by widgets)
  Uint8List base64ToBytes(String base64String) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final charMap = <String, int>{};
    for (var i = 0; i < chars.length; i++) {
      charMap[chars[i]] = i;
    }
    
    final cleanString = base64String.replaceAll(RegExp(r'\s'), '');
    final bytes = <int>[];
    
    for (var i = 0; i < cleanString.length; i += 4) {
      final c1 = charMap[cleanString[i]] ?? 0;
      final c2 = charMap[cleanString[i + 1]] ?? 0;
      final c3 = i + 2 < cleanString.length ? (charMap[cleanString[i + 2]] ?? 0) : 0;
      final c4 = i + 3 < cleanString.length ? (charMap[cleanString[i + 3]] ?? 0) : 0;
      
      final n = (c1 << 18) | (c2 << 12) | (c3 << 6) | c4;
      
      bytes.add((n >> 16) & 0xFF);
      if (i + 2 < cleanString.length && cleanString[i + 2] != '=') {
        bytes.add((n >> 8) & 0xFF);
      }
      if (i + 3 < cleanString.length && cleanString[i + 3] != '=') {
        bytes.add(n & 0xFF);
      }
    }
    
    return Uint8List.fromList(bytes);
  }
}
