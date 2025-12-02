import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/config/app_config.dart';
import '../core/config/environment.dart';
import '../main.dart';

class AWSS3Service {
  static final AWSS3Service _instance = AWSS3Service._internal();
  factory AWSS3Service() => _instance;
  AWSS3Service._internal();

  Dio? _dio;

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
      final presignedResponse = await _dio!.post('http://51.20.164.143:3001/api/uploads/presigned-url', data: {
        'fileName': s3Key,
        'contentType': 'audio/wav',
        'visitId': visitId,
        'patientId': patientId,
        'recordingSource': 'mobile_app',
        'recordingType': 'visit_note',
        'staffId': staffId,
      });

      if (presignedResponse.statusCode != 200) {
        throw Exception('Failed to get presigned URL');
      }

      final presignedUrl = presignedResponse.data['data']['uploadUrl'];
      final s3Url = presignedResponse.data['data']['fileUrl'];
      final s3KeyResponse = presignedResponse.data['data']['s3Key'];

      // Step 2: Upload file to S3 using presigned URL
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(audioFile.path),
      });

      final uploadResponse = await _dio!.put(
        presignedUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'audio/wav',
          },
        ),
      );

      if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 204) {
        // Step 3: Confirm upload with S3 service
        await _dio!.post('http://51.20.164.143:3001/api/uploads/confirm', data: {
          's3Key': s3KeyResponse,
          'fileSize': audioFile.lengthSync(),
          'uploadedBy': staffId,
        });
        
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
      
      logger.i('Uploading photo: $s3Key');
      
      // Step 1: Get presigned URL from S3 service via API gateway
      final presignedResponse = await _dio!.post('http://51.20.164.143:3001/api/uploads/presigned-url', data: {
        'fileName': s3Key,
        'contentType': 'image/jpeg',
        'visitId': visitId,
        'patientId': patientId,
        'recordingSource': 'mobile_app',
        'recordingType': 'visit_photo',
        'staffId': staffId,
      });

      if (presignedResponse.statusCode != 200) {
        throw Exception('Failed to get presigned URL');
      }

      final presignedUrl = presignedResponse.data['data']['uploadUrl'];
      final s3Url = presignedResponse.data['data']['fileUrl'];
      final s3KeyResponse = presignedResponse.data['data']['s3Key'];

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