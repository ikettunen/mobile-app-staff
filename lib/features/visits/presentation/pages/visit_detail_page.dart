import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nurse_app/features/visits/domain/entities/visit.dart' as domain;
import 'package:nurse_app/features/visits/presentation/widgets/audio_recording_section.dart';
import 'package:nurse_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:nurse_app/features/tasks/domain/entities/task.dart';
import '../../../../services/api_service.dart';
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
  domain.Visit? _visit;
  bool _isLoading = true;
  bool _isRecording = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _loadVisitDetails();
  }

  void _loadVisitDetails() async {
    try {
      // Get visits from API service to find the specific visit
      final apiVisits = await _apiService.getTodaysVisits();
      Visit? apiVisit;
      
      try {
        apiVisit = apiVisits.firstWhere(
          (visit) => visit.id == widget.visitId,
        );
      } catch (e) {
        // If visit not found, use the first visit as fallback or null
        apiVisit = apiVisits.isNotEmpty ? apiVisits.first : null;
      }
      
      if (apiVisit != null) {
        setState(() {
          _visit = domain.Visit(
            id: apiVisit!.id,
            patientId: apiVisit!.patientId,
            patientName: apiVisit!.patientName ?? 'Unknown Patient',
            nurseId: apiVisit!.nurseId ?? '',
            nurseName: apiVisit!.nurseName ?? '',
            status: _mapApiStatusToVisitStatus(apiVisit!.status),
            scheduledTime: apiVisit!.scheduledTime ?? DateTime.now(),
            location: apiVisit!.location,
            notes: apiVisit!.notes,
            taskCompletions: const [],
            vitalSigns: null,
            audioRecordingPath: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          _isLoading = false;
        });
      } else {
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
          // Visit Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _visit!.patientName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('${_visit!.location} • ${_visit!.status.name}'),
                Text('Scheduled: ${_formatTime(_visit!.scheduledTime)}'),
              ],
            ),
          ),
          
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
                    child: BlocBuilder<TaskBloc, TaskState>(
                      builder: (context, state) {
                        if (state is TaskLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is TaskLoaded) {
                          // Filter tasks for this visit/patient
                          final visitTasks = state.tasks.where((task) => 
                            task.patientId == _visit!.patientId
                          ).toList();
                          
                          if (visitTasks.isEmpty) {
                            return const Center(
                              child: Text('No tasks for this visit'),
                            );
                          }
                          
                          return ListView.builder(
                            itemCount: visitTasks.length,
                            itemBuilder: (context, index) {
                              final task = visitTasks[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: task.status == TaskStatus.completed 
                                        ? Colors.green 
                                        : _getPriorityColor(task.priority),
                                    child: Icon(
                                      task.status == TaskStatus.completed 
                                          ? Icons.check 
                                          : Icons.schedule,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(task.title),
                                  subtitle: Text(task.categories.isNotEmpty ? task.categories.first : 'General'),
                                  trailing: Checkbox(
                                    value: task.status == TaskStatus.completed,
                                    onChanged: (value) {
                                      // Toggle task completion
                                      _toggleTaskCompletion(task);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (state is TaskError) {
                          return Center(child: Text('Error: ${state.message}'));
                        }
                        return const Center(child: Text('No tasks loaded'));
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AudioRecordingSection(
                  isRecording: _isRecording,
                  audioPath: _audioPath,
                  onStartRecording: _startRecording,
                  onStopRecording: _stopRecording,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _startRecording,
                      icon: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 32,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: _isRecording ? Colors.red : Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    IconButton(
                      onPressed: _takePhoto,
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

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _toggleTaskCompletion(Task task) {
    // TODO: Implement task completion toggle
    logger.i('Toggling task completion for: ${task.title}');
  }

  void _startRecording() {
    if (_isRecording) {
      // Stop recording
      setState(() {
        _isRecording = false;
        _audioPath = 'path/to/recorded/audio.wav'; // Mock path
      });
      logger.i('Stopped audio recording');
    } else {
      // Start recording
      setState(() {
        _isRecording = true;
      });
      logger.i('Started audio recording');
    }
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _audioPath = 'path/to/recorded/audio.wav'; // Mock path
    });
    logger.i('Stopped audio recording');
  }

  void _takePhoto() {
    logger.i('Taking photo');
    // TODO: Implement photo capture
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
    if (_visit?.notes != null) {
      noteController.text = _visit!.notes!;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Visit Notes',
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
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: noteController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Write your visit notes here...',
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
                _saveNote(noteController.text);
                Navigator.pop(context);
              },
              child: const Text('Save Note'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveNote(String note) {
    setState(() {
      if (_visit != null) {
        _visit = _visit!.copyWith(notes: note);
      }
    });
    logger.i('Saved visit note: ${note.length} characters');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
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