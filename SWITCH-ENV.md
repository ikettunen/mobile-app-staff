# Switching Between Local and Production Environments

## Quick Switch

### For Local Development (localhost)
```cmd
copy .env.local .env
```

### For Production/Phone Testing (EC2)
```cmd
copy .env.production .env
```

## Environment Files

- `.env` - Active configuration (used by app)
- `.env.local` - Local development (localhost:3001)
- `.env.production` - Production/EC2 (51.20.164.143:3001)
- `.env.example` - Template for new setups

## What Changes Between Environments

### Local (.env.local)
- API Gateway: `http://localhost:3001/api`
- Environment: `development`
- Debug Logging: `true`
- Use when: Running services locally with PM2

### Production (.env.production)
- API Gateway: `http://51.20.164.143:3001/api`
- Environment: `production`
- Debug Logging: `false`
- Use when: Testing on real phone with EC2 backend

## Running the App

### Local Development
```cmd
copy .env.local .env
flutter run
```

### Phone with EC2
```cmd
copy .env.production .env
flutter run -d R58Y909LCLE
```

## Note

The app code now uses API Gateway for all requests, so you only need to change the API Gateway URL between environments. The gateway handles routing to individual services.
