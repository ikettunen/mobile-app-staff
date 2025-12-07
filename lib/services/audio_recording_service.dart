import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../main.dart';
import '../core/config/app_config.dart';

class AudioRecordingService {
  static final AudioRecordingService _instance = AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  // Getters
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  bool get isInitialized => _isRecorderInitialized;
  String? get currentRecordingPath => _currentRecordingPath;

  /// Initialize the audio recording service
  Future<bool> initialize() async {
    try {
      // Request microphone permission
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        logger.e('Microphone permission denied');
        return false;
      }

      // Initialize recorder
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      _isRecorderInitialized = true;

      // Initialize player
      _player = FlutterSoundPlayer();
      await _player!.openPlayer();
      _isPlayerInitialized = true;

      logger.i('Audio recording service initialized successfully');
      return true;
    } catch (e) {
      logger.e('Failed to initialize audio recording service: $e');
      return false;
    }
  }

  /// Start recording audio
  Future<bool> startRecording({
    required String visitId,
    required String staffId,
  }) async {
    try {
      if (!_isRecorderInitialized) {
        final initialized = await initialize();
        if (!initialized) return false;
      }

      if (_isRecording) {
        logger.w('Already recording');
        return false;
      }

      // Generate file path
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      // Use .m4a extension for AAC codec (better Android compatibility)
      final fileName = 'audio_$timestamp.m4a';
      
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final recordingPath = '${directory.path}/$fileName';
      
      // Start recording
      // Use AAC codec which works better on Android
      // AWS Transcribe supports both WAV and M4A formats
      await _recorder!.startRecorder(
        toFile: recordingPath,
        codec: Codec.aacMP4,
        bitRate: 128000,
        sampleRate: 44100,
      );

      _isRecording = true;
      _currentRecordingPath = recordingPath;
      _recordingStartTime = DateTime.now();
      
      logger.i('✅ Started recording: $recordingPath');
      logger.i('📱 Recording codec: aacMP4 (AAC in M4A container)');
      logger.i('📱 Bitrate: 128kbps, Sample rate: 44.1kHz');
      logger.i('⏰ Start time: $_recordingStartTime');
      return true;
    } catch (e) {
      logger.e('Failed to start recording: $e');
      return false;
    }
  }

  /// Stop recording audio
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        logger.w('⚠️ Not currently recording');
        return null;
      }

      // Calculate recording duration
      final duration = _recordingStartTime != null 
          ? DateTime.now().difference(_recordingStartTime!)
          : Duration.zero;
      
      logger.i('⏱️ Recording duration: ${duration.inSeconds} seconds');
      
      // Warn if recording is very short
      if (duration.inMilliseconds < 500) {
        logger.w('⚠️ WARNING: Recording is very short (${duration.inMilliseconds}ms)');
        logger.w('⚠️ This may result in an empty or header-only file');
      }

      await _recorder!.stopRecorder();
      _isRecording = false;

      final recordingPath = _currentRecordingPath;
      logger.i('✅ Stopped recording: $recordingPath');
      
      // Check file size immediately after stopping
      if (recordingPath != null) {
        final file = File(recordingPath);
        if (await file.exists()) {
          final fileSize = await file.length();
          logger.i('📊 File size after recording: $fileSize bytes');
          
          // M4A files have variable header sizes, but should be at least 1KB for any real audio
          if (fileSize < 1000) {
            logger.e('❌ ERROR: File is too small ($fileSize bytes)!');
            logger.e('❌ No audio data was captured');
            logger.e('❌ Possible causes:');
            logger.e('   - Recording stopped too quickly');
            logger.e('   - Microphone permission denied');
            logger.e('   - Audio input device not available');
            logger.e('   - Codec not supported on this device');
          } else {
            logger.i('✅ Audio data captured: $fileSize bytes');
            logger.i('✅ File format: ${recordingPath.split('.').last.toUpperCase()}');
          }
        } else {
          logger.e('❌ Recording file does not exist!');
        }
      }
      
      return recordingPath;
    } catch (e) {
      logger.e('❌ Failed to stop recording: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Play recorded audio
  Future<bool> playRecording(String filePath) async {
    try {
      if (!_isPlayerInitialized) {
        final initialized = await initialize();
        if (!initialized) return false;
      }

      if (_isPlaying) {
        await stopPlayback();
      }

      await _player!.startPlayer(
        fromURI: filePath,
        whenFinished: () {
          _isPlaying = false;
          logger.i('Playback finished');
        },
      );

      _isPlaying = true;
      logger.i('Started playback: $filePath');
      return true;
    } catch (e) {
      logger.e('Failed to play recording: $e');
      return false;
    }
  }

  /// Stop audio playback
  Future<void> stopPlayback() async {
    try {
      if (_isPlaying) {
        await _player!.stopPlayer();
        _isPlaying = false;
        logger.i('Stopped playback');
      }
    } catch (e) {
      logger.e('Failed to stop playback: $e');
    }
  }

  /// Get recording duration
  Future<Duration?> getRecordingDuration(String filePath) async {
    try {
      if (!File(filePath).existsSync()) {
        logger.w('Recording file does not exist: $filePath');
        return null;
      }

      // For now, return null as flutter_sound doesn't provide easy duration access
      // In a real implementation, you might use another package or native code
      return null;
    } catch (e) {
      logger.e('Failed to get recording duration: $e');
      return null;
    }
  }

  /// Delete recording file
  Future<bool> deleteRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        logger.i('Deleted recording: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Failed to delete recording: $e');
      return false;
    }
  }

  /// Get file size in bytes
  Future<int?> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      logger.e('Failed to get file size: $e');
      return null;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      if (_isRecording) {
        await stopRecording();
      }
      
      if (_isPlaying) {
        await stopPlayback();
      }

      if (_isRecorderInitialized) {
        await _recorder!.closeRecorder();
        _isRecorderInitialized = false;
      }

      if (_isPlayerInitialized) {
        await _player!.closePlayer();
        _isPlayerInitialized = false;
      }

      logger.i('Audio recording service disposed');
    } catch (e) {
      logger.e('Error disposing audio recording service: $e');
    }
  }
}