# Salamtak - Municipal Services & Safety Equipment App

A comprehensive Flutter application for municipal problem reporting and safety equipment e-commerce, built with Firebase backend.

## 🌟 Features

### User Features
- **Problem Reporting System**
  - Report municipal issues (Potholes, Broken Pipes, etc.)
  - Photo upload with location tagging
  - Voice-to-text description input
  - Interactive map location picker (Google Maps & Leaflet)
  - Real-time report status tracking
  - Report history with filtering

- **Safety Equipment Store**
  - Browse safety equipment catalog
  - Product details with reviews
  - Shopping cart management
  - Order placement and tracking
  - Order history and invoices

- **Multi-language Support**
  - English and Arabic (RTL support)
  - Seamless language switching

### Admin Features
- **Report Management**
  - View all submitted reports
  - Update report status
  - Filter by status and type
  - View report details with images and location

- **Order Management**
  - Process customer orders
  - Update order status
  - View order details

- **Product Management**
  - Add/edit/delete products
  - Manage product inventory
  - Set pricing and descriptions

## 🛠️ Tech Stack

- **Framework**: Flutter 3.7.0+
- **Backend**: Firebase
  - Authentication
  - Cloud Firestore
  - Cloud Storage
- **State Management**: Provider
- **Maps**: 
  - Google Maps Flutter
  - Flutter Map (Leaflet)
- **Additional Features**:
  - Speech-to-Text
  - Image Picker
  - Local Storage (SharedPreferences)
  - Cached Network Images

## 📋 Prerequisites

- Flutter SDK (3.7.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Google Maps API key (for Google Maps integration)

## 🚀 Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/Organization-Projects-2025/Salamtak.git
cd Salamtak
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download and place configuration files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`

4. Enable Firebase services:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Cloud Storage

### 4. Google Maps Setup (Optional)

1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Add the API key to:
   - Android: `android/app/src/main/AndroidManifest.xml`
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE"/>
   ```
   - iOS: `ios/Runner/AppDelegate.swift`

### 5. Run the app
```bash
flutter run
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🏗️ Project Structure

```
lib/
├── config/          # App configuration
├── l10n/            # Localization files
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
│   ├── admin/       # Admin screens
│   └── user/        # User screens
├── services/        # Business logic & API calls
├── widgets/         # Reusable widgets
├── main.dart        # App entry point
└── theme.dart       # App theme configuration
```

## 🔐 Default Admin Credentials

For testing purposes, you can create an admin account using the admin setup service:
- Check `lib/services/admin_setup.dart` for admin creation utilities

## 📸 Screenshots

_Add screenshots of your app here_

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team

Organization Projects 2025

## 📧 Contact

For questions or support, please open an issue in the GitHub repository.

## 🔄 Recent Changes

### v1.0.0 (Latest)
- ✅ Removed image classification/recognition features
- ✅ Simplified image upload workflow
- ✅ Enhanced location picker with dual map support
- ✅ Improved report management system
- ✅ Added comprehensive localization support

## 🐛 Known Issues

- None currently reported

## 🗺️ Roadmap

- [ ] Push notifications for report updates
- [ ] Advanced analytics dashboard
- [ ] Payment gateway integration
- [ ] Social media sharing
- [ ] Dark mode support

---

Made with ❤️ by Organization Projects 2025
