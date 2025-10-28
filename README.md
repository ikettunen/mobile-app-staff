# Nurse App - Mobile Application for Patient Visits

A Flutter mobile application designed for nurses to manage and document patient visits in a nursing home environment.

## Features

### Patient Visit Management
- **Task Completion**: One-click interface to mark nursing tasks as completed
- **Visit Documentation**: Record vital signs, notes, and observations during visits
- **Audio Recording**: Capture audio notes for detailed documentation (with future expandability)
- **Photo Capture**: Take and attach photos to visit records
- **Offline Support**: Work without internet connectivity with local data synchronization

### User Experience
- **Intuitive Interface**: Simple, focused UI designed for healthcare professionals
- **Dark Mode Support**: Comfortable usage in different lighting conditions
- **Accessibility**: Large touch targets and clear visuals

## Technical Details

### Architecture
- **Clean Architecture**: Separation of concerns with domain, data, and presentation layers
- **BLoC Pattern**: State management using the BLoC (Business Logic Component) pattern
- **Dependency Injection**: Service locator pattern for dependency management

### Key Dependencies
- `flutter_bloc`: State management
- `dio`: HTTP client for API communication
- `flutter_sound`: Audio recording and playback
- `image_picker`: Camera and gallery integration
- `auto_route`: Type-safe routing
- `get_it`: Dependency injection

## Backend Integration

The app integrates with the nursing home dashboard microservices backend:
- Authenticates with the Auth Service
- Fetches patient data from the Patient Service
- Retrieves and updates tasks via the Tasks Service (custom microservice)
- Submits visit documentation to the Visit Service (custom microservice)

## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourorg/nursing-home-dashboard.git
cd nursing-home-dashboard/mobile/nurse_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Configuration
- Update the API endpoints in `lib/core/di/service_locator.dart` to point to your backend services
- Configure the environment variables in `.env` files for different environments

## Building for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Security Features

- Secure storage for authentication tokens
- HTTPS communication with backend services
- Permission-based access to device features (camera, microphone)
- Data encryption for sensitive patient information

## Future Enhancements

- **Speech-to-Text**: Convert audio recordings to text notes
- **Biometric Authentication**: Fingerprint/Face ID login
- **Push Notifications**: Real-time alerts for urgent tasks
- **Offline First**: Complete offline functionality with conflict resolution
- **Wearable Integration**: Companion app for smartwatches
