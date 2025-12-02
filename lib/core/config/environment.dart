enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.development;
  
  static Environment get currentEnvironment => _currentEnvironment;
  
  static void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
  }
  
  static bool get isDevelopment => _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isProduction => _currentEnvironment == Environment.production;
  
  // Environment-specific configurations
  // All requests go through API Gateway which routes to individual services
  static String get apiGatewayUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://localhost:3001/api';
      case Environment.staging:
        return 'http://51.20.164.143:3001/api';
      case Environment.production:
        return 'http://51.20.164.143:3001/api';
    }
  }
  
  static String get s3BucketName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'nursing-app-dev-bucket';
      case Environment.staging:
        return 'nursing-app-staging-bucket';
      case Environment.production:
        return 'nursing-app-prod-bucket';
    }
  }
  
  static bool get enableDebugLogging {
    return _currentEnvironment != Environment.production;
  }
}