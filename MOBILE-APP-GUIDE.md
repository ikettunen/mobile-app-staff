# Flutter Mobile App - Setup & Development Guide

## Current Status

The Flutter mobile app for nursing staff is **90% complete** with the following features:

### ✅ Implemented Features
- **Authentication**: Login with demo credentials
- **Patient Management**: List, search, and filter patients
- **Visit Management**: View, start, and track visits
- **Task Management**: View and manage nursing tasks
- **Audio Recording**: Record and upload audio notes
- **Photo Capture**: Take and upload photos
- **AWS S3 Integration**: File uploads to S3
- **Home Dashboard**: Stats and quick actions
- **Offline Support**: Local data caching

### 🔧 What Needs Work
1. **Backend Integration**: Connect to real APIs (currently using mock data fallback)
2. **Testing**: Run the app and fix any runtime issues
3. **Task Service Integration**: Connect to task-service backend
4. **Notification Integration**: Add push notifications

## Quick Start

### Prerequisites
- Flutter SDK 3.0+ installed
- Android Studio or Xcode (for emulators)
- Backend services running (see below)

### 1. Install Dependencies
```bash
cd mobile-app-staff
flutter pub get
```

### 2. Start Backend Services
Make sure these services are running:
```bash
# From project root
pm2 start ecosystem.config.js

# Verify services are running
pm2 status

# You need:
# - fhir-api-backend (port 8080) - Patient data
# - auth-service (port 3002) - Authentication
# - visits-service (port 3008) - Visits and tasks
# - s3-bucket-service (port 3009) - File uploads
```

### 3. Run the App

**For Android:**
```bash
flutter run
# or
flutter run -d <device-id>
```

**For iOS:**
```bash
flutter run -d ios
# or open in Xcode
open ios/Runner.xcworkspace
```

**For Web (testing only):**
```bash
flutter run -d chrome
```

### 4. Login Credentials
```
Email: anna.virtanen@nursinghome.fi
Password: password123
```

## Architecture

```
lib/
├── core/
│   ├── config/          # Environment configuration
│   ├── di/              # Dependency injection
│   ├── navigation/      # App routing
│   └── theme/           # App theme
├── features/
│   ├── auth/            # Authentication
│   ├── patients/        # Patient management
│   ├── visits/          # Visit management
│   ├── tasks/           # Task management
│   ├── home/            # Dashboard
│   ├── settings/        # App settings
│   └── splash/          # Splash screen
├── services/
│   ├── api_service.dart      # API client
│   └── aws_s3_service.dart   # S3 uploads
└── main.dart            # App entry point
```

## API Endpoints Used

### Authentication (port 3002)
- `POST /api/auth/login` - Login
- `POST /api/auth/logout` - Logout
- `GET /api/auth/me` - Get current user

### Patients (port 8080)
- `GET /api/patients` - List all patients
- `GET /api/patients/:id` - Get patient details

### Visits (port 3008)
- `GET /api/visits` - List all visits
- `GET /api/visits/patient/:id` - Get patient visits
- `POST /api/visits` - Create visit
- `PATCH /api/visits/:id` - Update visit
- `PATCH /api/visits/:id/recording` - Add recording URL

### Tasks (port 3008)
- `GET /api/tasks` - List all tasks
- `GET /api/tasks/patient/:id` - Get patient tasks
- `PATCH /api/tasks/:id/complete` - Mark task complete

### File Uploads (port 3009)
- `POST /api/upload/audio` - Upload audio file
- `POST /api/upload/photo` - Upload photo
- `GET /api/files/:id` - Get file metadata

## Key Features

### 1. Patient List
- Search by name, room, or status
- Quick filters for status and room
- Pull to refresh
- Tap to view details

### 2. Visit Management
- View today's visits
- Start/continue visits
- Record audio notes
- Take photos
- Add text notes
- Upload to S3

### 3. Audio Recording
- Record up to 5 minutes
- Play back recordings
- Upload to S3
- Attach to visits

### 4. Task Management
- View assigned tasks
- Mark tasks complete
- Filter by status
- Urgent task indicators

## Development Tips

### Hot Reload
Press `r` in terminal to hot reload
Press `R` to hot restart

### Debug Logging
All logs use the `logger` package:
```dart
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
logger.d('Debug message');
```

### Mock Data
If backend is unavailable, the app falls back to mock data in `api_service.dart`

### State Management
Uses BLoC pattern:
- `AuthBloc` - Authentication state
- `PatientListBloc` - Patient list state
- `VisitBloc` - Visit management state
- `TaskBloc` - Task management state

## Common Issues & Solutions

### Issue: "Microphone permission denied"
**Solution**: 
- Android: Check `android/app/src/main/AndroidManifest.xml` has microphone permission
- iOS: Check `ios/Runner/Info.plist` has microphone usage description

### Issue: "Failed to load patients"
**Solution**: 
- Verify FHIR backend is running on port 8080
- Check network connectivity
- App will use mock data as fallback

### Issue: "S3 upload failed"
**Solution**:
- Verify s3-bucket-service is running on port 3009
- Check AWS credentials in backend service
- Check file size limits

### Issue: "Build failed"
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

## Next Steps

### Priority 1: Backend Integration
1. Test API connectivity with all services
2. Replace mock data with real API calls
3. Add error handling for network failures
4. Implement token refresh logic

### Priority 2: Task Service
1. Create task-service backend (or use visits-service)
2. Implement task CRUD operations
3. Add task assignment logic
4. Add task notifications

### Priority 3: Notifications
1. Integrate Firebase Cloud Messaging
2. Add notification handlers
3. Show in-app notifications
4. Handle notification taps

### Priority 4: Testing
1. Add unit tests for BLoCs
2. Add widget tests for UI
3. Add integration tests
4. Test on real devices

### Priority 5: Polish
1. Add loading states
2. Improve error messages
3. Add animations
4. Optimize performance
5. Add offline sync

## Building for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# Then open in Xcode and archive
```

## Environment Configuration

The app supports three environments:
- **Development**: Local backend (localhost)
- **Staging**: Staging servers
- **Production**: Production servers

Configure in `lib/core/config/environment.dart`

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Flutter Sound](https://pub.dev/packages/flutter_sound)
- [Dio HTTP Client](https://pub.dev/packages/dio)

## Support

For issues or questions:
1. Check logs: `flutter logs`
2. Check backend logs: `pm2 logs`
3. Review this guide
4. Check Flutter documentation
