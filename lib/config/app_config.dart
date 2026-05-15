/// Application configuration for environment-specific settings
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  /// Base URL for the website API and image serving
  /// Change this based on your environment:
  /// - Development: 'http://localhost:8000' or 'http://10.0.2.2:8000' (Android emulator)
  /// - Production: 'https://your-production-domain.com'
  static const String baseUrl = 'http://10.0.2.2:8000';

  /// Alternative base URL for physical devices on same network
  /// Use your computer's local IP address (e.g., 'http://192.168.1.100:8000')
  static const String localNetworkUrl = 'http://192.168.1.100:8000';

  /// Determine if we're in production mode
  static const bool isProduction = false;

  /// Get the appropriate base URL based on environment
  static String get apiBaseUrl => isProduction ? baseUrl : baseUrl;

  /// Construct full image URL from relative path
  ///
  /// Handles different image path formats:
  /// - Firebase Storage URLs (start with 'https://firebasestorage.googleapis.com')
  /// - Website relative paths (e.g., 'uploads/image.jpg')
  /// - Already full URLs (start with 'http://' or 'https://')
  ///
  /// Example:
  /// ```dart
  /// AppConfig.getImageUrl('uploads/report_123.jpg')
  /// // Returns: 'http://10.0.2.2:8000/uploads/report_123.jpg'
  ///
  /// AppConfig.getImageUrl('https://firebasestorage.googleapis.com/...')
  /// // Returns: 'https://firebasestorage.googleapis.com/...' (unchanged)
  /// ```
  static String getImageUrl(String path) {
    if (path.isEmpty) {
      return '';
    }

    // Already a full URL (Firebase Storage or other)
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Relative path from website - construct full URL
    // Remove leading slash if present to avoid double slashes
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$apiBaseUrl/$cleanPath';
  }

  /// Check if an image path is a Firebase Storage URL
  static bool isFirebaseStorageUrl(String path) {
    return path.startsWith('https://firebasestorage.googleapis.com');
  }

  /// Check if an image path is a website relative path
  static bool isWebsitePath(String path) {
    return path.isNotEmpty &&
        !path.startsWith('http://') &&
        !path.startsWith('https://');
  }

  /// Get environment name for debugging
  static String get environmentName =>
      isProduction ? 'Production' : 'Development';

  /// Print configuration info (useful for debugging)
  static void printConfig() {
    print('=== APP CONFIGURATION ===');
    print('Environment: $environmentName');
    print('Base URL: $apiBaseUrl');
    print('Is Production: $isProduction');
    print('========================');
  }
}
