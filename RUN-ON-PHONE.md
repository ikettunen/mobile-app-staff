# Running Flutter App on Real Phone

## Your Device
- **Model**: Samsung SM A165F
- **OS**: Android 15 (API 35)
- **Connection**: USB Cable
- **Status**: ✅ Detected by Flutter

## Quick Start

### 1. Enable Developer Options (if not already done)
1. Go to **Settings** → **About phone**
2. Tap **Build number** 7 times
3. Go back to **Settings** → **Developer options**
4. Enable **USB debugging**
5. Enable **Install via USB** (if available)

### 2. Connect Phone
1. Connect phone to PC via USB cable
2. On phone, allow USB debugging when prompted
3. Select **File Transfer** or **MTP** mode

### 3. Verify Connection
```bash
flutter devices
```
You should see:
```
SM A165F (mobile) • R58Y909LCLE • android-arm64 • Android 15 (API 35)
```

### 4. Run the App
```bash
# Run on your Samsung phone
flutter run -d R58Y909LCLE

# Or simply (if it's the only device)
flutter run
```

## Important: Network Configuration

### Your Phone Must Connect to EC2
The app is configured to connect to your EC2 instance at:
- **IP**: `51.20.164.143`
- **Services**:
  - FHIR API: `http://51.20.164.143:8080/api`
  - Auth Service: `http://51.20.164.143:3002/api`
  - Visits Service: `http://51.20.164.143:3008/api`
  - S3 Service: `http://51.20.164.143:3009/api`
  - API Gateway: `http://51.20.164.143:3001/api`

### Network Requirements
Your phone needs internet access to reach the EC2 instance:
- ✅ **WiFi**: Connect to any WiFi network
- ✅ **Mobile Data**: Use your cellular connection
- ❌ **Localhost won't work** - EC2 is required

### Test EC2 Connection from Phone
1. Open Chrome on your phone
2. Visit: `http://51.20.164.143:8080/health`
3. You should see a health check response

## Build & Run Commands

### Debug Build (Development)
```bash
# Run in debug mode (hot reload enabled)
flutter run -d R58Y909LCLE

# Run with verbose logging
flutter run -d R58Y909LCLE -v

# Run and open DevTools
flutter run -d R58Y909LCLE --observatory-port=8888
```

### Release Build (Production)
```bash
# Build release APK
flutter build apk --release

# Install release APK on phone
flutter install -d R58Y909LCLE

# Or build and run in release mode
flutter run -d R58Y909LCLE --release
```

### Profile Build (Performance Testing)
```bash
# Run in profile mode (for performance testing)
flutter run -d R58Y909LCLE --profile
```

## Login Credentials

Once the app is running:
```
Email: anna.virtanen@nursinghome.fi
Password: password123
```

## Troubleshooting

### Issue: Device Not Detected
**Solution**:
```bash
# Check ADB connection
adb devices

# If device shows as "unauthorized"
# - Disconnect and reconnect USB cable
# - On phone, tap "Allow" when USB debugging prompt appears

# Restart ADB server
adb kill-server
adb start-server
flutter devices
```

### Issue: "Waiting for device to connect"
**Solution**:
1. Unplug and replug USB cable
2. Change USB mode on phone (try MTP, PTP, or File Transfer)
3. Try a different USB cable
4. Try a different USB port on PC

### Issue: Build Failed
**Solution**:
```bash
# Clean build
flutter clean
flutter pub get

# Try again
flutter run -d R58Y909LCLE
```

### Issue: "Cannot connect to backend"
**Solution**:
1. Verify EC2 services are running:
   ```bash
   ssh -i test-health-vpc-key.pem ubuntu@51.20.164.143
   pm2 status
   ```

2. Check if ports are open:
   ```bash
   # From your PC
   curl http://51.20.164.143:8080/health
   curl http://51.20.164.143:3002/health
   curl http://51.20.164.143:3008/health
   ```

3. Verify phone has internet:
   - Open browser on phone
   - Visit `http://51.20.164.143:8080/health`

### Issue: App Crashes on Startup
**Solution**:
```bash
# View logs
flutter logs -d R58Y909LCLE

# Or use ADB
adb logcat | grep flutter
```

### Issue: Microphone Permission Denied
**Solution**:
1. On phone, go to **Settings** → **Apps** → **Nurse App**
2. Go to **Permissions**
3. Enable **Microphone** permission
4. Restart the app

### Issue: Camera Permission Denied
**Solution**:
1. On phone, go to **Settings** → **Apps** → **Nurse App**
2. Go to **Permissions**
3. Enable **Camera** permission
4. Restart the app

## Performance Tips

### Hot Reload
While app is running:
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Debug Performance
```bash
# Run with performance overlay
flutter run -d R58Y909LCLE --enable-software-rendering

# Profile mode for performance testing
flutter run -d R58Y909LCLE --profile
```

### Reduce APK Size
```bash
# Build with split APKs per ABI
flutter build apk --split-per-abi

# This creates:
# - app-armeabi-v7a-release.apk (32-bit ARM)
# - app-arm64-v8a-release.apk (64-bit ARM) ← Use this for your phone
# - app-x86_64-release.apk (64-bit Intel)
```

## Testing Checklist

After app launches on phone:

### Basic Functionality
- [ ] App launches without crashes
- [ ] Login screen appears
- [ ] Can login with demo credentials
- [ ] Home dashboard loads
- [ ] Bottom navigation works

### Network Connectivity
- [ ] Patient list loads from EC2
- [ ] Visits list loads from EC2
- [ ] Can view patient details
- [ ] Can view visit details

### Permissions
- [ ] Microphone permission requested
- [ ] Camera permission requested
- [ ] Storage permission requested (if needed)

### Features
- [ ] Can record audio notes
- [ ] Can play back recordings
- [ ] Can take photos
- [ ] Can add text notes
- [ ] Can upload files to S3

### Performance
- [ ] App is responsive
- [ ] No lag when scrolling
- [ ] Images load quickly
- [ ] Navigation is smooth

## Development Workflow

### Recommended Setup
1. Keep phone connected via USB
2. Run app in debug mode: `flutter run -d R58Y909LCLE`
3. Make code changes in your editor
4. Press `r` for hot reload (instant updates)
5. Press `R` for hot restart (full restart)

### Viewing Logs
```bash
# In separate terminal
flutter logs -d R58Y909LCLE

# Or filter logs
flutter logs -d R58Y909LCLE | grep "ERROR"
```

### Debugging
```bash
# Run with DevTools
flutter run -d R58Y909LCLE --observatory-port=8888

# Then open in browser:
# http://localhost:8888
```

## Building for Distribution

### Create Release APK
```bash
# Build release APK
flutter build apk --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

### Install Release APK
```bash
# Install on connected phone
flutter install -d R58Y909LCLE

# Or manually:
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Share APK
The APK file can be:
- Copied to phone and installed manually
- Shared via email/cloud storage
- Uploaded to Google Play Store (requires signing)

## Next Steps

1. **Run the app**: `flutter run -d R58Y909LCLE`
2. **Test login**: Use demo credentials
3. **Test features**: Try all main features
4. **Check logs**: Monitor for errors
5. **Report issues**: Note any bugs or crashes

## Useful Commands

```bash
# Check Flutter setup
flutter doctor

# List all devices
flutter devices

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run on phone
flutter run -d R58Y909LCLE

# Build release APK
flutter build apk --release

# View logs
flutter logs -d R58Y909LCLE

# Screenshot from phone
flutter screenshot -d R58Y909LCLE

# Uninstall app
flutter uninstall -d R58Y909LCLE
```

## EC2 Services Status

Before running, verify EC2 services are up:

```bash
# SSH to EC2
ssh -i test-health-vpc-key.pem ubuntu@51.20.164.143

# Check PM2 status
pm2 status

# Should show all services running:
# - fhir-api-backend (port 8080)
# - auth-service (port 3002)
# - visits-service (port 3008)
# - s3-bucket-service (port 3009)
# - api-gateway (port 3001)
```

## Support

If you encounter issues:
1. Check this guide's troubleshooting section
2. View Flutter logs: `flutter logs -d R58Y909LCLE`
3. Check EC2 logs: `pm2 logs`
4. Verify network connectivity from phone
