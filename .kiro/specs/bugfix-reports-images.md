# Bugfix Spec: Reports Not Showing & Images Not Displaying in App

## Bug Description

**Problem 1: Reports Not Showing in App**
- User reports are not displaying in the history screen
- The StreamBuilder is querying by `nationalId` but may have data consistency issues
- Reports created from website vs app may have different field structures

**Problem 2: Report Images Not Displaying**
- Images uploaded from the app show "image unavailable" icon
- Images from website reports don't load correctly
- Image path handling differs between app uploads (Firebase Storage URLs) and website uploads (relative paths)

## Root Cause Analysis

### Reports Not Showing:
1. **Firestore Query Issue**: The `getUserReportsByNationalId()` method queries by `nationalId` field, but there may be:
   - Missing `nationalId` field in some reports
   - Inconsistent field naming between app and website
   - Missing Firestore index for `nationalId` + `createdAt` ordering

2. **Data Format Inconsistency**: 
   - App stores `createdAt` as ISO string
   - Website may store it differently
   - The `orderBy('createdAt')` may fail if field is missing or has wrong type

### Images Not Displaying:
1. **Path Handling Issue**: The code tries to detect if path starts with 'http' to determine if it's a full URL or relative path
2. **Website Image Paths**: Website stores relative paths like `uploads/filename.jpg` but the hardcoded URL `http://localhost:8000/` won't work in production
3. **Error Handling**: Images fail silently with placeholder icons instead of showing useful error messages

## Solution Design

### Fix 1: Improve Report Querying
- Add fallback query mechanism: try `nationalId` first, then fall back to `uid`
- Handle missing `createdAt` field gracefully
- Add better error logging to identify data issues
- Ensure Firestore composite index exists

### Fix 2: Fix Image Path Handling
- Detect image source properly (Firebase Storage vs Website upload)
- Use environment-aware base URL for website images (not hardcoded localhost)
- Add proper error handling and retry logic
- Show meaningful error messages for debugging

### Fix 3: Data Consistency
- Ensure all reports have required fields (`nationalId`, `uid`, `createdAt`)
- Standardize date format across app and website
- Add data migration/validation if needed

## Implementation Plan

### Task 1: Fix Report Query Logic
**File**: `lib/services/database_service.dart`
- Modify `getUserReportsByNationalId()` to handle missing fields
- Add try-catch with fallback to `uid` query
- Remove `orderBy` if it's causing index issues (sort in memory instead)
- Add comprehensive logging

### Task 2: Fix Image Display Logic
**Files**: 
- `lib/screens/user/history_screen.dart`
- `lib/screens/admin/admin_home_screen.dart`

Changes:
- Create a reusable `ReportImageWidget` that handles all image loading scenarios
- Detect Firebase Storage URLs (start with `https://firebasestorage.googleapis.com`)
- For website images, construct proper URL using base URL from config
- Add loading states and better error messages
- Implement image caching

### Task 3: Add Configuration for Base URLs
**File**: `lib/config/app_config.dart` (create if doesn't exist)
- Add configurable base URL for website API
- Support different environments (dev, prod)
- Use this for constructing website image URLs

### Task 4: Update Report Model
**File**: `lib/models/report.dart`
- Ensure `fromFirestore` handles missing fields gracefully
- Add validation for required fields
- Add helper method to get full image URL

### Task 5: Add Firestore Index
**File**: `firestore.indexes.json` (create if doesn't exist)
- Add composite index for `nationalId` + `createdAt`
- Add composite index for `uid` + `createdAt`

## Testing Plan

1. **Test Report Display**:
   - Create report from app → verify it shows in history
   - Create report from website → verify it shows in app
   - Test with user that has no reports
   - Test with user that has many reports

2. **Test Image Display**:
   - Upload image from app → verify it displays correctly
   - Create report with image from website → verify it displays in app
   - Test with missing images
   - Test with invalid image URLs
   - Test image loading states

3. **Test Error Scenarios**:
   - No internet connection
   - Firestore query fails
   - Image load fails
   - Missing required fields

## Success Criteria

- ✅ All reports show correctly in user history screen
- ✅ All reports show correctly in admin dashboard
- ✅ Images from app uploads display correctly
- ✅ Images from website uploads display correctly
- ✅ Proper error messages shown when images fail to load
- ✅ Loading states shown while fetching data
- ✅ No console errors or warnings
- ✅ Works for both hardcoded test users and Firebase Auth users

## Files to Modify

1. `lib/services/database_service.dart` - Fix query logic
2. `lib/screens/user/history_screen.dart` - Fix image display
3. `lib/screens/admin/admin_home_screen.dart` - Fix image display
4. `lib/models/report.dart` - Add helper methods
5. `lib/config/app_config.dart` - Add configuration (new file)
6. `lib/widgets/report_image_widget.dart` - Reusable image widget (new file)
7. `firestore.indexes.json` - Add indexes (new file)

## Priority

**HIGH** - This is a critical bug affecting core functionality

## Estimated Effort

- 2-3 hours for implementation
- 1 hour for testing
- Total: 3-4 hours
