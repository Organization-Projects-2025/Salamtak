import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/app_config.dart';
import '../theme.dart';
import '../services/local_image_storage.dart';

/// A reusable widget for displaying report images with smart loading
///
/// Handles different image sources:
/// - Firebase Storage URLs (https://firebasestorage.googleapis.com/...)
/// - Website relative paths (uploads/image.jpg)
/// - Empty/missing images
///
/// Features:
/// - Loading indicator while fetching
/// - Error placeholder with icon
/// - Image caching for performance
/// - Customizable dimensions and border radius
class ReportImageWidget extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const ReportImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // No image provided
    if (imagePath.isEmpty) {
      return _buildPlaceholder(
        icon: Icons.image_not_supported_outlined,
        message: 'No image',
        color: Colors.grey,
      );
    }

    // Debug logging
    debugPrint('=== REPORT IMAGE WIDGET ===');
    debugPrint('Original path: $imagePath');

    // Handle different image sources
    Widget imageWidget;

    if (kIsWeb) {
      // Web: Load from IndexedDB
      debugPrint('Type: Web (IndexedDB)');
      debugPrint('Image path: $imagePath');
      
      imageWidget = FutureBuilder<Uint8List?>(
        future: LocalImageStorage.instance.getImageBytes(imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          }

          if (snapshot.hasError) {
            debugPrint('❌ Error loading from IndexedDB: ${snapshot.error}');
          }
          
          if (!snapshot.hasData || snapshot.data == null) {
            debugPrint('⚠️ No image data in IndexedDB for: $imagePath');
            return _buildPlaceholder(
              icon: Icons.image_not_supported_outlined,
              message: 'Image unavailable',
              color: Colors.grey,
            );
          }

          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('❌ Error displaying image: $error');
              return _buildPlaceholder(
                icon: Icons.broken_image_outlined,
                message: 'Image unavailable',
                color: Colors.red[300]!,
              );
            },
          );
        },
      );
    } else if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      // Network image (Firebase Storage or website URL)
      debugPrint('Type: Network URL');
      final imageUrl = AppConfig.getImageUrl(imagePath);
      debugPrint('Full URL: $imageUrl');

      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildLoadingIndicator(),
        errorWidget: (context, url, error) {
          debugPrint('❌ Error loading image: $error');
          debugPrint('   URL: $url');
          return _buildPlaceholder(
            icon: Icons.broken_image_outlined,
            message: 'Image unavailable',
            color: Colors.red[300]!,
          );
        },
      );
    } else {
      // Local file path (desktop/mobile)
      debugPrint('Type: Local file');
      
      // Use FutureBuilder to load local file
      imageWidget = FutureBuilder<String>(
        future: LocalImageStorage.instance.getFullPath(imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            debugPrint('❌ Error getting file path: ${snapshot.error}');
            return _buildPlaceholder(
              icon: Icons.broken_image_outlined,
              message: 'Image unavailable',
              color: Colors.red[300]!,
            );
          }

          final fullPath = snapshot.data!;
          debugPrint('Full path: $fullPath');

          final file = File(fullPath);
          
          return FutureBuilder<bool>(
            future: file.exists(),
            builder: (context, existsSnapshot) {
              if (existsSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingIndicator();
              }

              if (existsSnapshot.data != true) {
                debugPrint('❌ File does not exist: $fullPath');
                return _buildPlaceholder(
                  icon: Icons.broken_image_outlined,
                  message: 'Image not found',
                  color: Colors.red[300]!,
                );
              }

              return Image.file(
                file,
                width: width,
                height: height,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('❌ Error loading file: $error');
                  return _buildPlaceholder(
                    icon: Icons.broken_image_outlined,
                    message: 'Image unavailable',
                    color: Colors.red[300]!,
                  );
                },
              );
            },
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        width: width,
        height: height,
        color: backgroundColor ?? Colors.grey[100],
        child: imageWidget,
      ),
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppTheme.primary.withValues(alpha: 0.05),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Build placeholder for missing or error images
  Widget _buildPlaceholder({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? color.withValues(alpha: 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: (height != null && height! < 150) ? 32 : 48,
            color: color.withValues(alpha: 0.4),
          ),
          if (height == null || height! >= 100) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Thumbnail variant for smaller images (e.g., in lists)
class ReportImageThumbnail extends StatelessWidget {
  final String imagePath;
  final double size;
  final BorderRadius? borderRadius;

  const ReportImageThumbnail({
    super.key,
    required this.imagePath,
    this.size = 100,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ReportImageWidget(
      imagePath: imagePath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
    );
  }
}

/// Full-width variant for detail views
class ReportImageFull extends StatelessWidget {
  final String imagePath;
  final double height;
  final BorderRadius? borderRadius;

  const ReportImageFull({
    super.key,
    required this.imagePath,
    this.height = 200,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ReportImageWidget(
      imagePath: imagePath,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius ?? BorderRadius.zero,
    );
  }
}
