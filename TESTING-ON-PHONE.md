# Testing on Real Phone - Samsung SM A165F

## ✅ What's Working Now

### 1. API Connection
- App successfully connects to EC2 at `51.20.164.143:3001`
- Environment set to `production` in main.dart
- API Gateway routing works correctly

### 2. Data Fetching
- **Patients**: ✅ Shows 12 real patients from database
- **Visits**: ✅ Shows real visits with correct patient names and scheduled times
- **Tasks**: ✅ Shows real tasks extracted from visits

### 3. Authentication
- Login works with demo credentials:
  - Email: `anna.virtanen@nursinghome.fi`
  - Password: `password123`

## 🎯 Ready to Test on Phone

### Photo Upload Test
1. Open a visit from the Visits page
2. Tap the camera icon to take a photo
3. Take a photo using the phone camera
4. Photo should upload to S3 bucket
5. Check if photo appears in the visit

**S3 Configuration:**
- Bucket: `nursing-app-dev-bucket`
- Region: `us-east-1`
- Endpoint: `http://51.20.164.143:3009/api/upload`

### Audio Recording Test
1. Open a visit from the Visits page
2. Tap the microphone icon to start recording
3. Record some audio (speak for a few seconds)
4. Stop recording
5. Audio should upload to S3 bucket
6. Check if audio file is saved to the visit

**Audio Settings:**
- Max duration: 300 seconds (5 minutes)
- Format: WAV/MP3
- Upload endpoint: Same S3 service

## 📝 Known Issues

### 1. Visit Model Null Safety
- Fixed: Made `patientName` and `scheduledTime` nullable
- Fixed: Added camelCase field name support (API returns camelCase, not snake_case)

### 2. Tasks Filtering
- Current: Shows ALL tasks from ALL visits
- TODO: Filter tasks by logged-in nurse
- TODO: Add nurse assignment logic in backend

### 3. Hot Reload Issues
- Solution: Use full rebuild (`flutter clean && flutter pub get && flutter run`)
- Hot restart (R) works for most changes
- Hot reload (r) may not pick up constant changes

## 🔧 Quick Commands

### Rebuild App
```cmd
cd mobile-app-staff
flutter clean
flutter pub get
flutter run -d R58Y909LCLE
```

### Check Logs
```cmd
flutter logs -d R58Y909LCLE
```

### Restart EC2 Services (if needed)
```cmd
aws ec2 reboot-instances --instance-ids i-0a69cfbc3e66d4159
```

## 📱 Test Checklist

- [ ] Take photo in visit
- [ ] Upload photo to S3
- [ ] Verify photo appears in visit
- [ ] Record audio in visit
- [ ] Upload audio to S3
- [ ] Verify audio is saved to visit
- [ ] Test photo quality on phone
- [ ] Test audio quality on phone
- [ ] Check S3 bucket for uploaded files
- [ ] Verify file URLs are saved to visit records

## 🎉 Next Steps After Testing

1. **If uploads work**: Great! Move on to nurse-specific filtering
2. **If uploads fail**: Debug S3 permissions and network connectivity
3. **Add nurse filtering**: Modify API to return only visits/tasks for logged-in nurse
4. **Improve UI**: Add upload progress indicators, error handling

---

**Device**: Samsung SM A165F (R58Y909LCLE)
**EC2 IP**: 51.20.164.143
**API Gateway**: http://51.20.164.143:3001/api
**S3 Service**: http://51.20.164.143:3009/api
