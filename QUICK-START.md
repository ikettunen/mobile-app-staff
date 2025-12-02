# Quick Start - Flutter Mobile App

## 1. Fix API Configuration (One-time setup)
```cmd
fix-s3-localhost.bat
```
This replaces any remaining localhost references with EC2 IP.

## 2. Run on Phone
```cmd
RUN-APP.bat
```

Or manually:
```cmd
flutter run -d R58Y909LCLE
```

## 3. Login
```
Email: anna.virtanen@nursinghome.fi
Password: password123
```

## Architecture

```
Flutter App (Phone)
    ↓
API Gateway (51.20.164.143:3001)
    ↓
├── /api/patients → FHIR Backend (port 8080)
├── /api/auth → Auth Service (port 3002)
├── /api/visits → Visits Service (port 3008)
└── /api/uploads → S3 Service (port 3009)
```

## Key Changes Made

✅ **All requests now go through API Gateway (port 3001)**
- Before: Direct connections to individual services
- After: Single entry point through API Gateway
- Benefits: Centralized routing, easier to manage

✅ **Simplified API Service**
- Removed separate Dio clients for each service
- Single client pointing to API Gateway
- API Gateway handles routing to correct service

## Files Updated

1. `lib/services/api_service.dart` - Now uses API Gateway only
2. `lib/core/config/environment.dart` - Single API Gateway URL
3. `lib/services/aws_s3_service.dart` - Uses API Gateway for uploads
4. `.env` - Updated configuration

## Testing

After running the app:
1. Check logs for API calls: `flutter logs -d R58Y909LCLE`
2. Look for: `http://51.20.164.143:3001/api/...`
3. Should NOT see direct calls to ports 8080, 3002, 3008, 3009

## Troubleshooting

**Still seeing mock patients?**
- Check API Gateway is running: `curl http://51.20.164.143:3001/health`
- Check patients endpoint: `curl http://51.20.164.143:3001/api/patients`
- View app logs: `flutter logs -d R58Y909LCLE`

**Connection errors?**
- Verify phone has internet
- Test from phone browser: `http://51.20.164.143:3001/health`
- Check EC2 security groups allow port 3001

**Build errors?**
```cmd
flutter clean
flutter pub get
flutter run -d R58Y909LCLE
```
