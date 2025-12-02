class AppConfig {
  // API Configuration
  static const String baseApiUrl = 'http://localhost:8080/api';
  static const String visitsApiUrl = 'http://localhost:3008/api';
  
  // AWS S3 Configuration
  static const String awsRegion = 'YOUR_AWS_REGION';
  static const String s3BucketName = 'YOUR_S3_BUCKET_NAME';
  static const String awsAccessKeyId = 'YOUR_AWS_ACCESS_KEY_ID';
  static const String awsSecretAccessKey = 'YOUR_AWS_SECRET_ACCESS_KEY';
  
  // S3 Access Configuration (choose one)
  static const String s3AccessPointAlias = 'sound-bucket-ap-xdntonpfnqeyswxmfztohndf17eareun1a-s3alias';
  static const String s3CustomEndpoint = ''; // e.g., 'https://my-custom-endpoint.com'
  static const bool useAccessPointAlias = true; // Set to true to use access point alias
  static const bool useCustomEndpoint = false; // Set to true to use custom endpoint
  
  // Audio Recording Configuration
  static const String audioFileExtension = '.wav';
  static const int maxRecordingDurationSeconds = 300; // 5 minutes
  
  // Photo Configuration
  static const int maxPhotoSizeMB = 5;
  static const int photoQuality = 90;
  static const int maxPhotoResolution = 1080;
  
  // App Configuration
  static const String appName = 'Nurse Mobile App';
  static const String appVersion = '1.0.0';
  static const bool enableDebugLogging = true;
  
  // Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int uploadTimeoutSeconds = 60;
  
  // File Storage Paths - Lambda expects: visits/{visitId}/{staffId}/{filename}
  static String getAudioFilePath(String visitId, String staffId, String timestamp) {
    return 'visits/$visitId/$staffId/audio_${timestamp}$audioFileExtension';
  }
  
  static String getPhotoFilePath(String visitId, String staffId, String timestamp, int index) {
    return 'visits/$visitId/$staffId/photo_${timestamp}_$index.jpg';
  }
  
  // S3 URL Generation
  static String getS3BaseUrl() {
    if (useCustomEndpoint && s3CustomEndpoint.isNotEmpty) {
      return s3CustomEndpoint;
    } else if (useAccessPointAlias && s3AccessPointAlias.isNotEmpty) {
      return 'https://$s3AccessPointAlias.s3-accesspoint.$awsRegion.amazonaws.com';
    } else {
      return 'https://$s3BucketName.s3.$awsRegion.amazonaws.com';
    }
  }
  
  static String getS3FileUrl(String fileName) {
    return '${getS3BaseUrl()}/$fileName';
  }
  
  static String getS3UploadEndpoint() {
    if (useAccessPointAlias && s3AccessPointAlias.isNotEmpty) {
      return s3AccessPointAlias; // Use alias directly for SDK calls
    } else {
      return s3BucketName; // Use bucket name for SDK calls
    }
  }
}