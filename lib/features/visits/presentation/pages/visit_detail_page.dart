import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nurse_app/features/visits/domain/entities/visit.dart' as domain;

import 'package:nurse_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:nurse_app/features/tasks/domain/entities/task.dart';
import '../../../../services/api_service.dart';
import '../../../../services/audio_recording_service.dart';
import '../../../../services/photo_capture_service.dart';
import '../../../../services/aws_s3_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../main.dart';

class VisitDetailPage extends StatefulWidget {
  final String visitId;
  
  const VisitDetailPage({
    super.key,
    required this.visitId,
  });

  @override
  State<VisitDetailPage> createState() => _VisitDetailPageState();
}

class _VisitDetailPageState extends State<VisitDetailPage> {
  final ApiService _apiService = ApiService();
  final AudioRecordingService _audioService = AudioRecordingService();
  final PhotoCaptureService _photoService = PhotoCaptureService();
  final AWSS3Service _s3Service = AWSS3Service();
  final AuthService _authService = AuthService();
  
  domain.Visit? _visit;
  List<TaskItem> _visitTasks = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadVisitDetails();
    _initializeServices();
  }

  void _initializeServices() async {
    // Initialize S3 service
    _s3Service.initialize();
    
    // Initialize audio service
    await _audioService.initialize();
    
    // Request photo permissions
    await _photoService.requestPermissions();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _loadVisitDetails() async {
    try {
      // Get all visits (not just today's) to find this specific visit
      final response = await _apiService.dio.get('/visits', queryParameters: {
        'limit': 1000, // Get more visits to ensure we find the one we need
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> visitsJson = data['data'] ?? [];
        
        // Find the specific visit
        final visitJson = visitsJson.firstWhere(
          (v) => v['_id'] == widget.visitId || v['id'] == widget.visitId,
          orElse: () => null,
        );
        
        if (visitJson != null) {
          final apiVisit = Visit.fromJson(visitJson);
          
          // Extract tasks from taskCompletions array
          final taskCompletions = visitJson['taskCompletions'] as List<dynamic>? ?? [];
          final visitTasks = taskCompletions
              .map((taskJson) => TaskItem.fromJson(taskJson, apiVisit))
              .toList();
          
          logger.i('Loaded visit ${apiVisit.id} with ${visitTasks.length} tasks');
        
          setState(() {
            _visit = domain.Visit(
              id: apiVisit.id,
              patientId: apiVisit.patientId,
              patientName: apiVisit.patientName ?? 'Unknown Patient',
              nurseId: apiVisit.nurseId ?? '',
              nurseName: apiVisit.nurseName ?? '',
              status: _mapApiStatusToVisitStatus(apiVisit.status),
              scheduledTime: apiVisit.scheduledTime ?? DateTime.now(),
              location: apiVisit.location,
              notes: apiVisit.notes,
              taskCompletions: [],
              vitalSigns: null,
              audioRecordingPath: null,
              hasAudioRecording: false,
              photos: const [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            _visitTasks = visitTasks;
            _isLoading = false;
          });
        } else {
          logger.w('Visit not found: ${widget.visitId}');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        logger.e('Failed to load visits: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.e('Error loading visit details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  domain.VisitStatus _mapApiStatusToVisitStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'planned':
        return domain.VisitStatus.planned;
      case 'in-progress':
        return domain.VisitStatus.inProgress;
      case 'finished':
      case 'completed':
        return domain.VisitStatus.completed;
      case 'cancelled':
        return domain.VisitStatus.cancelled;
      default:
        return domain.VisitStatus.planned;
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_visit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visit Details')),
        body: const Center(child: Text('Visit not found')),
      );
    }

    return BlocProvider<TaskBloc>(
      create: (context) => TaskBloc(ApiService())..add(LoadTasks(_visit!.patientId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_visit!.patientName),
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  _formatTime(_visit!.scheduledTime),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      body: Column(
        children: [
          
          // Tasks List
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visit Tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _visitTasks.isEmpty
                        ? const Center(
                            child: Text('No tasks for this visit'),
                          )
                        : ListView.builder(
                            itemCount: _visitTasks.length,
                            itemBuilder: (context, index) {
                              final task = _visitTasks[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: task.completed 
                                        ? Colors.green 
                                        : _getPriorityColor(task.priority),
                                    child: Icon(
                                      task.completed 
                                          ? Icons.check 
                                          : Icons.schedule,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(task.taskTitle),
                                  subtitle: Text(task.taskCategory),
                                  trailing: Checkbox(
                                    value: task.completed,
                                    onChanged: (value) {
                                      // Toggle task completion
                                      _toggleTaskCompletion(task);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          
          // Audio Recording Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                if (_isUploading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Uploading...'),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _isUploading ? null : _toggleRecording,
                      icon: Icon(
                        _audioService.isRecording ? Icons.stop : Icons.mic,
                        size: 32,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: _audioService.isRecording ? Colors.red : Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    IconButton(
                      onPressed: _isUploading ? null : _takePhoto,
                      icon: const Icon(Icons.camera_alt, size: 32),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    IconButton(
                      onPressed: _writeNote,
                      icon: const Icon(Icons.note_add, size: 32),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'critical':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _toggleTaskCompletion(TaskItem task) async {
    if (task.completed) {
      // Task is already completed, show message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task is already completed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Task'),
        content: Text('Mark "${task.taskTitle}" as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Get current staff info
    final currentStaffId = _authService.currentUserId ?? 'unknown';
    final currentUser = _authService.currentUser;
    final staffName = currentUser != null 
        ? '${currentUser['firstName'] ?? ''} ${currentUser['lastName'] ?? ''}'.trim()
        : null;

    // Call API to complete the task
    final success = await _apiService.completeTask(
      visitId: widget.visitId,
      taskId: task.taskId,
      staffId: currentStaffId,
      staffName: staffName,
      notes: 'Completed via mobile app',
    );

    if (!mounted) return;

    if (success) {
      // Reload visit details to get updated task status
      _loadVisitDetails();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to complete task'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleRecording() async {
    if (_audioService.isRecording) {
      // Stop recording
      final recordingPath = await _audioService.stopRecording();
      final currentStaffId = _authService.currentUserId ?? 'staff-1001';
      
      if (recordingPath != null && _visit != null) {
        // Check file size before upload
        final fileSize = await _audioService.getFileSize(recordingPath);
        logger.i('📊 Audio file size before upload: ${fileSize ?? 0} bytes');
        
        // Warn if file is too small (less than 1KB is likely empty or corrupted)
        if (fileSize != null && fileSize < 1000) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recording too short or empty. Please record for at least 2 seconds.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          // Delete the empty file
          await _audioService.deleteRecording(recordingPath);
          return;
        }
        
        setState(() {
          _isUploading = true;
        });
        
        // Upload to S3
        final s3Url = await _s3Service.uploadAudioRecording(
          audioFile: File(recordingPath),
          visitId: _visit!.id,
          patientId: _visit!.patientId,
          staffId: currentStaffId,
        );
        
        setState(() {
          _isUploading = false;
        });
        
        if (s3Url != null) {
          // Recording uploaded successfully
          // The transcription Lambda will automatically process it and post to visit notes
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Audio recording uploaded successfully. Transcription will be added to notes in 1-5 minutes.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
              ),
            );
          }
          
          // Clean up local file
          await _audioService.deleteRecording(recordingPath);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload audio recording'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } else {
      // Start recording
      final currentStaffId = _authService.currentUserId ?? 'staff-1001';
      
      if (_visit != null) {
        final success = await _audioService.startRecording(
          visitId: _visit!.id,
          staffId: currentStaffId,
        );
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎤 Recording... Speak now'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to start recording. Check microphone permissions.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    setState(() {});
  }

  void _takePhoto() async {
    final currentStaffId = _authService.currentUserId ?? 'staff-1001';
    
    if (_visit != null) {
      setState(() {
        _isUploading = true;
      });
      
      final photoPath = await _photoService.takePhoto(
        visitId: _visit!.id,
        staffId: currentStaffId,
      );
      
      if (photoPath != null) {
        // Upload to S3
        final s3Url = await _s3Service.uploadPhoto(
          photoFile: File(photoPath),
          visitId: _visit!.id,
          patientId: _visit!.patientId,
          staffId: currentStaffId,
          photoIndex: 0,
        );
        
        setState(() {
          _isUploading = false;
        });
        
        if (s3Url != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clean up local file
          await _photoService.deletePhoto(photoPath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload photo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() {
          _isUploading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to take photo. Check camera permissions.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _writeNote() {
    logger.i('Opening note editor');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) => _buildNoteEditor(scrollController),
        ),
      ),
    );
  }

  Widget _buildNoteEditor(ScrollController scrollController) {
    final TextEditingController noteController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Visit Note',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Show existing notes if any
          if (_visit?.notes != null && _visit!.notes!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Previous Notes:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: SingleChildScrollView(
                      child: Text(
                        _visit!.notes!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // New note input
          Expanded(
            child: TextField(
              controller: noteController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Write your new note here...\n\nThis will be appended to existing notes.',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (noteController.text.trim().isNotEmpty) {
                  _saveNote(noteController.text.trim());
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a note'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Add Note'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveNote(String noteText) async {
    if (_visit == null) return;

    // Get current staff info
    final currentStaffId = _authService.currentUserId ?? 'unknown';
    final currentUser = _authService.currentUser;
    final staffName = currentUser != null 
        ? '${currentUser['firstName'] ?? ''} ${currentUser['lastName'] ?? ''}'.trim()
        : null;

    // Call API to add note
    final success = await _apiService.addNoteToVisit(
      visitId: widget.visitId,
      noteText: noteText,
      staffId: currentStaffId,
      staffName: staffName,
      noteType: 'general',
    );

    if (!mounted) return;

    if (success) {
      // Reload visit details to get updated notes
      _loadVisitDetails();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add note'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveVisit() {
    logger.i('Saving visit');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visit saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}