# Tasks: Fix Reports Not Showing & Images Not Displaying

- [x] 1. Create App Configuration File
  - Create `lib/config/app_config.dart` file
  - Add `baseUrl` constant for website API (e.g., 'http://localhost:8000' for dev)
  - Add helper method `getImageUrl(String path)` to construct full URLs
  - Add environment detection (dev vs prod)
  - Export configuration class

- [x] 2. Create Reusable Report Image Widget @depends(1)
  - Create `lib/widgets/report_image_widget.dart` file
  - Implement `ReportImageWidget` class that accepts image path and dimensions
  - Detect image source type (Firebase Storage URL vs website relative path)
  - Handle Firebase Storage URLs (start with 'https://firebasestorage.googleapis.com')
  - Handle website relative paths using AppConfig.getImageUrl()
  - Add loading indicator while image loads
  - Add error placeholder with meaningful error icon
  - Add image caching for better performance
  - Support different border radius and fit options

- [x] 3. Fix Report Query Logic in Database Service
  - Modify `getUserReportsByNationalId()` in `database_service.dart`
  - Remove `orderBy('createdAt')` to avoid index issues
  - Add try-catch error handling
  - Add fallback query by `uid` if `nationalId` query returns empty
  - Sort reports in memory by `createdAt` after fetching
  - Handle missing or null `createdAt` fields gracefully
  - Add comprehensive debug logging
  - Update `getAllReportsStream()` to also remove orderBy and sort in memory

- [x] 4. Update Report Model with Helper Methods @depends(1)
  - Update `lib/models/report.dart`
  - Modify `fromFirestore()` to provide default values for missing fields
  - Add null safety for all optional fields
  - Add `getFullImageUrl()` helper method that uses AppConfig
  - Add `hasImage()` helper method to check if report has valid image
  - Add validation method `isValid()` to check required fields
  - Handle both string and Timestamp types for `createdAt` field

- [x] 5. Update History Screen to Use New Image Widget @depends(2,4)
  - Update `lib/screens/user/history_screen.dart`
  - Import `ReportImageWidget` and `AppConfig`
  - Replace existing image loading code in `_ReportCard` with `ReportImageWidget`
  - Use `report.hasImage()` to check if image should be displayed
  - Remove old error handling code (now handled by widget)
  - Test with different report types (app images, website images, no images)

- [ ] 6. Update Admin Home Screen to Use New Image Widget @depends(2,4)
  - Update `lib/screens/admin/admin_home_screen.dart`
  - Import `ReportImageWidget` and `AppConfig`
  - Replace existing image loading code in `_AdminReportCard` with `ReportImageWidget`
  - Update the modal bottom sheet image display to use `ReportImageWidget`
  - Use `report.hasImage()` to check if image should be displayed
  - Remove old error handling code
  - Test with different report types

- [~] 7. Add Firestore Indexes Configuration @optional
  - Create `firestore.indexes.json` in project root
  - Add composite index for `nationalId` + `createdAt` (descending)
  - Add composite index for `uid` + `createdAt` (descending)
  - Add documentation comment explaining when to deploy indexes
  - Note: This is optional since Task 3 removes orderBy, but good for future optimization

- [~] 8. Test Report Display and Image Loading @depends(3,5,6)
  - Test creating report from app with image → verify shows in history
  - Test creating report from website with image → verify shows in app
  - Test user with no reports → verify empty state
  - Test user with multiple reports → verify all show correctly
  - Test reports without images → verify no broken image placeholders
  - Test with no internet → verify error handling
  - Test image loading performance with many reports
  - Verify debug logs show useful information
