# Mobile App Upload Testing Guide

## What We Just Implemented

✅ **Real Audio Recording**: Using `flutter_sound` package with device microphone
✅ **Real Photo Capture**: Using `image_picker` package with device camera  
✅ **S3 Upload Integration**: Direct upload to your S3 bucket via backend API
✅ **Progress Indicators**: Shows upload status to user
✅ **Error Handling**: Proper error messages for permissions and upload failures
✅ **File Cleanup**: Removes local files after successful upload

## Before Testing

### 1. Verify Backend Services
```bash
cd mobile-app-staff
node test-backend-connection.js
```

All services should show ✅ OK status.

### 2. Check Environment Configuration
The app is now configured to use:
- **S3 Bucket**: `nursing-home-audio-recordings-20251124`
- **AWS Region**: `eu-north-1`
- **Backend**: `http://51.20.164.143:3001/api`

## Testing Steps

### Step 1: Run the App
```bash
cd mobile-app-staff
flutter run -d R58Y909LCLE
```

### Step 2: Login
- Email: `anna.virtanen@nursinghome.fi`
- Password: `password123`

### Step 3: Navigate to a Visit
1. Go to "Visits" tab
2. Tap on any visit to open details
3. You should see 3 buttons at bottom: 🎤 📷 📝

### Step 4: Test Audio Recording
1. **Tap microphone button** 🎤
   - Should request microphone permission (first time)
   - Button turns red when recording
   - Tap again to stop and upload
   - Should show "Uploading..." progress
   - Success: "Audio recording uploaded successfully"
   - Error: Check permissions or backend connection

### Step 5: Test Photo Capture
1. **Tap camera button** 📷
   - Should request camera permission (first time)
   - Opens camera app
   - Take a photo
   - Should show "Uploading..." progress
   - Success: "Photo uploaded successfully"
   - Error: Check permissions or backend connection

## Expected Workflow

### Audio Recording Flow:
1. **Tap mic** → Request permission → Start recording
2. **Tap stop** → Save to local file → Upload to S3 → Confirm with backend → Delete local file → Show success

### Photo Capture Flow:
1. **Tap camera** → Request permission → Open camera → Take photo
2. **Photo taken** → Save to local file → Upload to S3 → Confirm with backend → Delete local file → Show success

## Troubleshooting

### "Microphone permission denied"
- Go to phone Settings → Apps → Nurse App → Permissions
- Enable Microphone permission

### "Camera permission denied"  
- Go to phone Settings → Apps → Nurse App → Permissions
- Enable Camera permission

### "Failed to upload"
- Check backend services are running: `pm2 status`
- Check network connection
- Check S3 credentials in backend

### "Failed to start recording"
- Close other apps using microphone
- Restart the app
- Check microphone hardware

### App crashes
- Check Flutter logs: `flutter logs -d R58Y909LCLE`
- Look for permission or initialization errors

## Backend Integration

The mobile app now integrates with your tested backend workflow:

1. **Generates presigned URLs** via `POST /api/uploads/presigned-url`
2. **Uploads files to S3** using presigned URLs
3. **Confirms uploads** via `POST /api/uploads/confirm`
4. **Triggers notifications** (your lambda function should handle this)

## File Naming Convention

The app uses the same naming convention as your backend tests:
- **Audio**: `visits/{visitId}/{staffId}/audio_{timestamp}.wav`
- **Photos**: `visits/{visitId}/{staffId}/photo_{timestamp}_0.jpg`

## Next Steps

Once basic upload works:

1. **Test notification workflow** - Check if lambda triggers
2. **Test with multiple files** - Take several photos/recordings
3. **Test offline/online scenarios** - What happens with poor connection
4. **Test file size limits** - Large recordings/photos
5. **Polish UI** - Add playback for recordings, photo preview

## Success Criteria

✅ Can record audio and upload to S3
✅ Can take photos and upload to S3  
✅ Files appear in S3 bucket with correct naming
✅ Backend receives upload confirmations
✅ Lambda function triggers (if configured)
✅ No app crashes or permission issues

## Files Modified

- `lib/services/audio_recording_service.dart` - NEW: Real audio recording
- `lib/services/photo_capture_service.dart` - NEW: Real photo capture  
- `lib/features/visits/presentation/pages/visit_detail_page.dart` - Updated with real implementations
- `lib/core/config/app_config.dart` - Updated AWS credentials
- `lib/core/config/environment.dart` - Updated S3 bucket name
- `.env.production` - Updated AWS region and bucket

The implementation is now ready for real device testing! 🚀