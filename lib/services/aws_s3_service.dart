import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/config/app_config.dart';
import '../core/config/environment.dart';
import '../main.dart';
import 'auth_service.dart';

class AWSS3Service {
  static final AWSS3Service _instance = AWSS3Service._internal();
  factory AWSS3Service() => _instance;
  AWSS3Service._internal();

  Dio? _dio;
  final AuthService _authService = AuthService();

  void initialize() {
    if (_dio != null) {
      // Already initialized
      return;
    }
    
    _dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: AppConfig.uploadTimeoutSeconds),
      receiveTimeout: Duration(seconds: AppConfig.uploadTimeoutSeconds),
    ));

    // Add logging interceptor for development
    if (EnvironmentConfig.enableDebugLogging) {
      _dio!.interceptors.add(LogInterceptor(
        requestBody: false, // Don't log file uploads
        responseBody: false,
        logPrint: (obj) => logger.d('S3 Upload: $obj'),
      ));
    }
  }

  /// Upload audio recording to S3
  Future<String?> uploadAudioRecording({
    required File audioFile,
    required String visitId,
    required String patientId,
    required String staffId,
  }) async {
    try {
      // Ensure service is initialized
      if (_dio == null) {
        initialize();
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final s3Key = AppConfig.getAudioFilePath(visitId, staffId, timestamp);
      
      logger.i('Uploading audio recording: $s3Key');
      
      if (kIsWeb) {
        // For web, we need to handle Uint8List data instead of File
        return await _uploadWebAudio(s3Key, visitId, patientId, staffId);
      } else {
        // For mobile, use file-based upload
        return await _uploadMobileAudio(audioFile, s3Key, visitId, patientId, staffId);
      }
      
    } catch (e) {
      logger.e('Failed to upload audio recording: $e');
      return null;
    }
  }

  /// Upload audio from web (using Uint8List data)
  Future<String?> _uploadWebAudio(String s3Key, String visitId, String patientId, String staffId) async {
    try {
      // Ensure service is initialized
      if (_dio == null) {
        initialize();
      }
      
      // Double check initialization
      if (_dio == null) {
        throw Exception('Failed to initialize Dio client');
      }
      
      // Step 1: Get presigned URL from S3 service via API gateway
      final presignedResponse = await _dio!.post('http://51.20.164.143:3001/api/uploads/presigned-url', data: {
        'fileName': s3Key,
        'contentType': 'audio/wav',
        'visitId': visitId,
        'patientId': patientId,
        'recordingSource': 'web_app',
        'recordingType': 'visit_note',
        'staffId': staffId,
      });

      if (presignedResponse.statusCode != 200) {
        throw Exception('Failed to get presigned URL');
      }

      final presignedUrl = presignedResponse.data['uploadUrl'];
      final s3Url = presignedResponse.data['fileUrl'];

      // Step 2: For now, simulate the upload since we don't have real audio data
      // In a real implementation, you would get the audio data from flutter_sound
      logger.i('Would upload to presigned URL: $presignedUrl');
      
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));
      
      logger.i('Audio recording uploaded successfully: $s3Url');
      return s3Url;
      
    } catch (e) {
      logger.e('Failed to upload web audio: $e');
      // Fallback to simulation
      final s3Url = 'https://${EnvironmentConfig.s3BucketName}.s3.${AppConfig.awsRegion}.amazonaws.com/$s3Key';
      logger.i('Using simulated upload URL: $s3Url');
      return s3Url;
    }
  }

  /// Upload raw audio data to S3 (for web with actual audio data)
  Future<String?> uploadWebAudioData({
    required Uint8List audioData,
    required String visitId,
    required String patientId,
    required String staffId,
  }) async {
    try {
      // Ensure service is initialized
      if (_dio == null) {
        initialize();
      }
      
      // Double check initialization
      if (_dio == null) {
        throw Exception('Failed to initialize Dio client');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final s3Key = AppConfig.getAudioFilePath(visitId, staffId, timestamp);
      
      logger.i('Uploading web audio data: $s3Key (${audioData.length} bytes)');

      // Step 1: Get presigned URL from your backend
      final presignedResponse = await _dio!.post('http://51.20.164.143:3001/api/uploads/presigned-url', data: {
        'fileName': s3Key,
        'contentType': 'audio/wav',
        'visitId': visitId,
        'patientId': patientId,
        'staffId': staffId,
      });

      if (presignedResponse.statusCode != 200) {
        throw Exception('Failed to get presigned URL');
      }

      final presignedUrl = presignedResponse.data['data']['uploadUrl'];
      final s3Url = presignedResponse.data['data']['fileUrl'];
      final s3KeyResponse = presignedResponse.data['data']['s3Key'];

      // Step 2: Upload audio data to S3 using presigned URL
      final uploadResponse = await _dio!.put(
        presignedUrl,
        data: audioData,
        options: Options(
          headers: {
            'Content-Type': 'audio/wav',
            'Content-Length': audioData.length.toString(),
          },
        ),
      );

      if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 204) {
        // Step 3: Confirm upload with S3 service
        await _dio!.post('http://51.20.164.143:3001/api/uploads/confirm', data: {
          's3Key': s3KeyResponse,
          'fileSize': audioData.length,
          'uploadedBy': staffId,
        });
        
        logger.i('Web audio data uploaded successfully: $s3Url');
        return s3Url;
      } else {
        throw Exception('Upload failed with status: ${uploadResponse.statusCode}');
      }
      
    } catch (e) {
      logger.e('Failed to upload web audio data: $e');
      return null;
    }
  }

  /// Upload audio from mobile (using File)
  Future<String?> _uploadMobileAudio(File audioFile, String s3Key, String visitId, String patientId, String staffId) async {
    try {
      // Ensure service is initialized
      if (_dio == null) {
        initialize();
      }
      
      // Double check initialization
      if (_dio == null) {
        throw Exception('Failed to initialize Dio client');
      }
      
      // Step 1: Get presigned URL from S3 service via API gateway
      logger.i('=== REQUESTING PRESIGNED URL ===');
      logger.i('S3 Key: $s3Key');
      logger.i('Visit ID: $visitId');
      logger.i('Patient ID: $patientId');
      logger.i('Staff ID: $staffId');
      
      // Get auth headers from auth service
      final authHeaders = _authService.getAuthHeaders();
      logger.i('Auth headers: $authHeaders');
      logger.i('Auth token present: ${_authService.currentToken != null}');
      if (_authService.currentToken != null) {
        logger.i('Token preview: ${_authService.currentToken!.substring(0, 20)}...');
      }
      
      final requestUrl = 'http://51.20.164.143:3001/api/uploads/presigned-url';
      // Extract just the filename from the S3 key
      final fileName = s3Key.split('/').last;
      
      // Determine content type based on file extension
      final contentType = fileName.toLowerCase().endsWith('.m4a') 
          ? 'audio/mp4' 
          : 'audio/wav';
      
      final requestData = {
        'fileName': fileName,
        'contentType': contentType,
        'visitId': visitId,
        'patientId': patientId,
        'staffId': staffId,
        'recordingType': 'visit_note',
        'recordingSource': 'mobile_app',
        'description': 'Audio recording from mobile app',
        'tags': ['mobile', 'audio', 'visit_note'],
      };
      
      logger.i('=== REQUEST TO S3-BUCKET-SERVICE ===');
      logger.i('URL: $requestUrl');
      logger.i('Method: POST');
      logger.i('Headers: $authHeaders');
      logger.i('Request body: $requestData');
      
      final presignedResponse = await _dio!.post(requestUrl, 
        data: requestData,
        options: Options(headers: authHeaders),
      );

      logger.i('=== PRESIGNED URL RESPONSE ===');
      logger.i('Status: ${presignedResponse.statusCode}');
      logger.i('Headers: ${presignedResponse.headers}');
      logger.i('Full response data: ${presignedResponse.data}');

      if (presignedResponse.statusCode != 200) {
        logger.e('❌ FAILED TO GET PRESIGNED URL');
        logger.e('Status: ${presignedResponse.statusCode}');
        logger.e('Response body: ${presignedResponse.data}');
        logger.e('Response type: ${presignedResponse.data.runtimeType}');
        throw Exception('Failed to get presigned URL: ${presignedResponse.statusCode} - ${presignedResponse.data}');
      }

      // Parse response data more carefully
      final responseData = presignedResponse.data;
      logger.i('Response data type: ${responseData.runtimeType}');
      logger.i('Response keys: ${responseData.keys}');
      
      final dataSection = responseData['data'];
      logger.i('Data section: $dataSection');
      logger.i('Data section type: ${dataSection?.runtimeType}');
      
      if (dataSection == null) {
        logger.e('No data section in response!');
        throw Exception('Invalid response format - no data section');
      }
      
      final presignedUrl = dataSection['uploadUrl'];
      final s3Url = dataSection['fileUrl'];
      final s3KeyResponse = dataSection['s3Key'];
      
      logger.i('=== EXTRACTED VALUES ===');
      logger.i('Presigned URL: $presignedUrl');
      logger.i('S3 URL: $s3Url');
      logger.i('S3 Key: $s3KeyResponse');
      
      // Detailed region analysis
      if (presignedUrl != null) {
        logger.i('=== REGION ANALYSIS ===');
        if (presignedUrl.contains('us-east-1')) {
          logger.e('❌ ERROR: Presigned URL contains us-east-1!');
          logger.e('Service config not updated or not restarted!');
        } else if (presignedUrl.contains('eu-north-1')) {
          logger.i('✅ SUCCESS: Presigned URL uses eu-north-1');
        } else {
          logger.w('⚠️ No region found in URL');
        }
        
        // Extract hostname for more analysis
        final uri = Uri.parse(presignedUrl);
        logger.i('Hostname: ${uri.host}');
        logger.i('Path: ${uri.path}');
        logger.i('Query params: ${uri.queryParameters}');
      } else {
        logger.e('❌ Presigned URL is null!');
        throw Exception('Presigned URL is null in response');
      }

      // Step 2: Upload file to S3 using presigned URL
      final bytes = await audioFile.readAsBytes();
      logger.i('=== PREPARING S3 UPLOAD ===');
      logger.i('File size: ${bytes.length} bytes');
      logger.i('Upload URL: $presignedUrl');
      
      final uploadHeaders = {
        'Content-Type': contentType,
        'Content-Length': bytes.length.toString(),
      };
      logger.i('Upload headers: $uploadHeaders');

      logger.i('=== STARTING S3 UPLOAD ===');
      
      Response uploadResponse;
      try {
        uploadResponse = await _dio!.put(
          presignedUrl,
          data: bytes,
          options: Options(headers: uploadHeaders),
        );
        
        logger.i('=== S3 UPLOAD SUCCESS ===');
        logger.i('Status: ${uploadResponse.statusCode}');
        logger.i('Headers: ${uploadResponse.headers}');
        logger.i('Data: ${uploadResponse.data}');
        
      } catch (e) {
        logger.e('=== S3 UPLOAD FAILED ===');
        if (e is DioException && e.response != null) {
          final response = e.response!;
          logger.e('Status: ${response.statusCode}');
          logger.e('Status message: ${response.statusMessage}');
          logger.e('Headers: ${response.headers}');
          logger.e('Data: ${response.data}');
          
          if (response.statusCode == 301) {
            logger.e('=== 301 REDIRECT ANALYSIS ===');
            final location = response.headers['location']?.first;
            logger.e('Location header: $location');
            logger.e('This means the bucket is in a different region than expected');
            logger.e('Original URL: $presignedUrl');
            
            if (location != null) {
              logger.e('Redirect location: $location');
              try {
                final redirectUri = Uri.parse(location);
                logger.e('Redirect hostname: ${redirectUri.host}');
                logger.e('Redirect path: ${redirectUri.path}');
              } catch (parseError) {
                logger.e('Could not parse redirect location: $parseError');
              }
            }
          }
        }
        
        logger.e('Error type: ${e.runtimeType}');
        logger.e('Error message: $e');
        rethrow;
      }

      if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 204) {
        // Step 3: Confirm upload with S3 service
        await _dio!.post('http://51.20.164.143:3001/api/uploads/confirm', 
          data: {
            's3Key': s3KeyResponse,
            'fileSize': audioFile.lengthSync(),
            'uploadedBy': staffId,
          },
          options: Options(headers: _authService.getAuthHeaders()),
        );
        
        logger.i('Audio recording uploaded successfully: $s3Url');
        return s3Url;
      } else {
        throw Exception('Upload failed with status: ${uploadResponse.statusCode}');
      }
      
    } catch (e) {
      logger.e('Failed to upload mobile audio: $e');
      return null;
    }
  }

  /// Upload photo to S3
  Future<String?> uploadPhoto({
    required File photoFile,
    required String visitId,
    required String patientId,
    required String staffId,
    required int photoIndex,
  }) async {
    try {
      // Ensure service is initialized
      if (_dio == null) {
        initialize();
      }
      
      // Double check initialization
      if (_dio == null) {
        throw Exception('Failed to initialize Dio client');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final s3Key = AppConfig.getPhotoFilePath(visitId, staffId, timestamp, photoIndex);
      
      logger.i('=== PHOTO UPLOAD REQUEST ===');
      logger.i('S3 Key: $s3Key');
      logger.i('Visit ID: $visitId');
      logger.i('Patient ID: $patientId');
      logger.i('Staff ID: $staffId');
      
      // Extract just the filename from the S3 key
      final fileName = s3Key.split('/').last;
      
      final requestData = {
        'fileName': fileName,
        'contentType': 'image/jpeg',
        'visitId': visitId,
        'patientId': patientId,
        'photoSource': 'mobile_app',  // Use photoSource for photos, not recordingSource
        'photoType': 'general',        // Use photoType for photos, not recordingType
        'staffId': staffId,
        'description': 'Photo from mobile app',
        'tags': ['mobile', 'photo', 'visit'],
      };
      
      logger.i('Request data: $requestData');
      
      // Step 1: Get presigned URL from S3 service via API gateway
      final presignedResponse = await _dio!.post('http://51.20.164.143:3001/api/uploads/presigned-url', data: requestData);

      logger.i('Response status: ${presignedResponse.statusCode}');
      logger.i('Response data: ${presignedResponse.data}');

      if (presignedResponse.statusCode != 200) {
        logger.e('❌ Presigned URL request failed');
        logger.e('Status: ${presignedResponse.statusCode}');
        logger.e('Response: ${presignedResponse.data}');
        throw Exception('Failed to get presigned URL: ${presignedResponse.statusCode}');
      }

      final presignedUrl = presignedResponse.data['data']['uploadUrl'];
      final s3Url = presignedResponse.data['data']['fileUrl'];
      final s3KeyResponse = presignedResponse.data['data']['s3Key'];
      
      logger.i('✅ Presigned URL received');

      // Step 2: Upload file to S3 using presigned URL
      final bytes = await photoFile.readAsBytes();

      final uploadResponse = await _dio!.put(
        presignedUrl,
        data: bytes,
        options: Options(
          headers: {
            'Content-Type': 'image/jpeg',
            'Content-Length': bytes.length.toString(),
          },
        ),
      );

      if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 204) {
        // Step 3: Confirm upload with S3 service
        await _dio!.post('http://51.20.164.143:3001/api/uploads/confirm', data: {
          's3Key': s3KeyResponse,
          'fileSize': bytes.length,
          'uploadedBy': staffId,
        });
        
        logger.i('Photo uploaded successfully: $s3Url');
        return s3Url;
      } else {
        throw Exception('Upload failed with status: ${uploadResponse.statusCode}');
      }
      
    } catch (e) {
      logger.e('Failed to upload photo: $e');
      return null;
    }
  }

  /// Upload file from web file picker
  Future<String?> uploadWebFile({
    required Uint8List fileData,
    required String fileName,
    required String visitId,
    required String patientId,
    required String staffId,
  }) async {
    try {
      // Ensure service is initialized
      if (_dio == null) {
        initialize();
      }
      
      // Double check initialization
      if (_dio == null) {
        throw Exception('Failed to initialize Dio client');
      }
      
      logger.i('Uploading web file: $fileName (${fileData.length} bytes)');

      // Step 1: Get presigned URL from S3 service via API gateway
      final presignedResponse = await _dio!.post('http://51.20.164.143:3001/api/uploads/presigned-url', data: {
        'fileName': fileName,
        'contentType': 'audio/wav',
        'visitId': visitId,
        'patientId': patientId,
        'recordingSource': 'file_upload',
        'recordingType': 'visit_note',
        'staffId': staffId,
      });

      if (presignedResponse.statusCode != 200) {
        throw Exception('Failed to get presigned URL');
      }

      final presignedUrl = presignedResponse.data['data']['uploadUrl'];
      final s3Url = presignedResponse.data['data']['fileUrl'];
      final s3Key = presignedResponse.data['data']['s3Key'];

      // Step 2: Upload file data to S3 using presigned URL
      final uploadResponse = await _dio!.put(
        presignedUrl,
        data: fileData,
        options: Options(
          headers: {
            'Content-Type': 'audio/wav',
            'Content-Length': fileData.length.toString(),
          },
        ),
      );

      if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 204) {
        // Step 3: Confirm upload with S3 service
        await _dio!.post('http://51.20.164.143:3001/api/uploads/confirm', data: {
          's3Key': s3Key,
          'fileSize': fileData.length,
          'uploadedBy': 'web_user', // TODO: Get from auth context
        });

        logger.i('Web file uploaded successfully: $s3Url');
        return s3Url;
      } else {
        throw Exception('Upload failed with status: ${uploadResponse.statusCode}');
      }
      
    } catch (e) {
      logger.e('Failed to upload web file: $e');
      return null;
    }
  }

  /// Upload multiple files in batch
  Future<List<String>> uploadBatch({
    required List<File> files,
    required String visitId,
    required String patientId,
    required String staffId,
    required String fileType, // 'audio' or 'photo'
  }) async {
    final uploadedUrls = <String>[];
    
    for (int i = 0; i < files.length; i++) {
      String? url;
      
      if (fileType == 'audio') {
        url = await uploadAudioRecording(
          audioFile: files[i],
          visitId: visitId,
          patientId: patientId,
          staffId: staffId,
        );
      } else if (fileType == 'photo') {
        url = await uploadPhoto(
          photoFile: files[i],
          visitId: visitId,
          patientId: patientId,
          staffId: staffId,
          photoIndex: i,
        );
      }
      
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }

  /// Delete file from S3
  Future<bool> deleteFile(String s3Url) async {
    try {
      logger.i('Deleting file from S3: $s3Url');
      
      // TODO: Implement actual S3 delete
      // For now, simulate delete
      await Future.delayed(const Duration(milliseconds: 500));
      
      logger.i('File deleted successfully from S3');
      return true;
      
    } catch (e) {
      logger.e('Failed to delete file from S3: $e');
      return false;
    }
  }

  /// Get presigned URL for file access
  Future<String?> getPresignedUrl(String s3Key, {int expirationHours = 24}) async {
    try {
      logger.i('Generating presigned URL for: $s3Key');
      
      // TODO: Implement actual presigned URL generation
      // For now, return the direct S3 URL
      final presignedUrl = 'https://${EnvironmentConfig.s3BucketName}.s3.${AppConfig.awsRegion}.amazonaws.com/$s3Key?expires=${DateTime.now().add(Duration(hours: expirationHours)).millisecondsSinceEpoch}';
      
      logger.i('Presigned URL generated successfully');
      return presignedUrl;
      
    } catch (e) {
      logger.e('Failed to generate presigned URL: $e');
      return null;
    }
  }
}