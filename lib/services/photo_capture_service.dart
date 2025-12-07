import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../main.dart';
import '../core/config/app_config.dart';

class PhotoCaptureService {
  static final PhotoCaptureService _instance = PhotoCaptureService._internal();
  factory PhotoCaptureService() => _instance;
  PhotoCaptureService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Take a photo using the device camera
  Future<String?> takePhoto({
    required String visitId,
    required String staffId,
    int photoIndex = 0,
  }) async {
    try {
      // Request camera permission
      final permission = await Permission.camera.request();
      if (permission != PermissionStatus.granted) {
        logger.e('Camera permission denied');
        return null;
      }

      // Take photo
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: AppConfig.photoQuality,
        maxWidth: AppConfig.maxPhotoResolution.toDouble(),
        maxHeight: AppConfig.maxPhotoResolution.toDouble(),
      );

      if (photo == null) {
        logger.i('Photo capture cancelled by user');
        return null;
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = 'photo_${timestamp}_$photoIndex.jpg';
      
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final photoPath = '${directory.path}/$fileName';
      
      // Copy photo to app directory
      final File photoFile = File(photo.path);
      final File savedPhoto = await photoFile.copy(photoPath);
      
      // Check file size
      final fileSize = await savedPhoto.length();
      final maxSizeBytes = AppConfig.maxPhotoSizeMB * 1024 * 1024;
      
      if (fileSize > maxSizeBytes) {
        logger.w('Photo size (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB) exceeds limit (${AppConfig.maxPhotoSizeMB}MB)');
        // Could implement compression here if needed
      }

      logger.i('Photo captured: $photoPath (${(fileSize / 1024).toStringAsFixed(1)}KB)');
      return photoPath;
    } catch (e) {
      logger.e('Failed to take photo: $e');
      return null;
    }
  }

  /// Pick a photo from gallery
  Future<String?> pickFromGallery({
    required String visitId,
    required String staffId,
    int photoIndex = 0,
  }) async {
    try {
      // Request photo library permission
      final permission = await Permission.photos.request();
      if (permission != PermissionStatus.granted) {
        logger.e('Photo library permission denied');
        return null;
      }

      // Pick photo from gallery
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: AppConfig.photoQuality,
        maxWidth: AppConfig.maxPhotoResolution.toDouble(),
        maxHeight: AppConfig.maxPhotoResolution.toDouble(),
      );

      if (photo == null) {
        logger.i('Photo selection cancelled by user');
        return null;
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = 'photo_${timestamp}_$photoIndex.jpg';
      
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final photoPath = '${directory.path}/$fileName';
      
      // Copy photo to app directory
      final File photoFile = File(photo.path);
      final File savedPhoto = await photoFile.copy(photoPath);
      
      // Check file size
      final fileSize = await savedPhoto.length();
      final maxSizeBytes = AppConfig.maxPhotoSizeMB * 1024 * 1024;
      
      if (fileSize > maxSizeBytes) {
        logger.w('Photo size (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB) exceeds limit (${AppConfig.maxPhotoSizeMB}MB)');
        // Could implement compression here if needed
      }

      logger.i('Photo selected: $photoPath (${(fileSize / 1024).toStringAsFixed(1)}KB)');
      return photoPath;
    } catch (e) {
      logger.e('Failed to pick photo from gallery: $e');
      return null;
    }
  }

  /// Take multiple photos
  Future<List<String>> takeMultiplePhotos({
    required String visitId,
    required String staffId,
    int maxPhotos = 5,
  }) async {
    final List<String> photoPaths = [];
    
    for (int i = 0; i < maxPhotos; i++) {
      final photoPath = await takePhoto(
        visitId: visitId,
        staffId: staffId,
        photoIndex: i,
      );
      
      if (photoPath != null) {
        photoPaths.add(photoPath);
      } else {
        // User cancelled or error occurred
        break;
      }
    }
    
    return photoPaths;
  }

  /// Show photo source selection dialog
  Future<String?> showPhotoSourceDialog({
    required String visitId,
    required String staffId,
    int photoIndex = 0,
  }) async {
    // This would typically show a dialog to choose between camera and gallery
    // For now, we'll default to camera
    return await takePhoto(
      visitId: visitId,
      staffId: staffId,
      photoIndex: photoIndex,
    );
  }

  /// Get photo file size in bytes
  Future<int?> getPhotoSize(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      logger.e('Failed to get photo size: $e');
      return null;
    }
  }

  /// Delete photo file
  Future<bool> deletePhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
        logger.i('Deleted photo: $photoPath');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Failed to delete photo: $e');
      return false;
    }
  }

  /// Check if camera is available
  Future<bool> isCameraAvailable() async {
    try {
      final cameras = await _picker.pickImage(source: ImageSource.camera);
      return cameras != null;
    } catch (e) {
      logger.e('Camera not available: $e');
      return false;
    }
  }

  /// Check camera permission status
  Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  /// Check photo library permission status
  Future<PermissionStatus> getPhotoLibraryPermissionStatus() async {
    return await Permission.photos.status;
  }

  /// Request all necessary permissions
  Future<bool> requestPermissions() async {
    try {
      final cameraPermission = await Permission.camera.request();
      final photosPermission = await Permission.photos.request();
      
      final allGranted = cameraPermission == PermissionStatus.granted && 
                        photosPermission == PermissionStatus.granted;
      
      if (allGranted) {
        logger.i('All photo permissions granted');
      } else {
        logger.w('Some photo permissions denied - Camera: $cameraPermission, Photos: $photosPermission');
      }
      
      return allGranted;
    } catch (e) {
      logger.e('Failed to request photo permissions: $e');
      return false;
    }
  }
}