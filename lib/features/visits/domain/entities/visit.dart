import 'package:equatable/equatable.dart';

enum VisitStatus { planned, inProgress, completed, cancelled }

class TaskCompletion extends Equatable {
  final String taskId;
  final String taskTitle;
  final bool completed;
  final DateTime? completedAt;
  final String? notes;

  const TaskCompletion({
    required this.taskId,
    required this.taskTitle,
    required this.completed,
    this.completedAt,
    this.notes,
  });

  TaskCompletion copyWith({
    String? taskId,
    String? taskTitle,
    bool? completed,
    DateTime? completedAt,
    String? notes,
  }) {
    return TaskCompletion(
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [taskId, taskTitle, completed, completedAt, notes];
}

class VitalSigns extends Equatable {
  final double? temperature;
  final int? heartRate;
  final int? respiratoryRate;
  final int? systolicBP;
  final int? diastolicBP;
  final int? oxygenSaturation;
  final String? notes;

  const VitalSigns({
    this.temperature,
    this.heartRate,
    this.respiratoryRate,
    this.systolicBP,
    this.diastolicBP,
    this.oxygenSaturation,
    this.notes,
  });

  VitalSigns copyWith({
    double? temperature,
    int? heartRate,
    int? respiratoryRate,
    int? systolicBP,
    int? diastolicBP,
    int? oxygenSaturation,
    String? notes,
  }) {
    return VitalSigns(
      temperature: temperature ?? this.temperature,
      heartRate: heartRate ?? this.heartRate,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      systolicBP: systolicBP ?? this.systolicBP,
      diastolicBP: diastolicBP ?? this.diastolicBP,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      notes: notes ?? this.notes,
    );
  }

  bool get hasVitalSigns {
    return temperature != null ||
        heartRate != null ||
        respiratoryRate != null ||
        systolicBP != null ||
        diastolicBP != null ||
        oxygenSaturation != null;
  }

  @override
  List<Object?> get props => [
        temperature,
        heartRate,
        respiratoryRate,
        systolicBP,
        diastolicBP,
        oxygenSaturation,
        notes,
      ];
}

class Visit extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String nurseId;
  final String nurseName;
  final DateTime scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final VisitStatus status;
  final String? location;
  final List<TaskCompletion> taskCompletions;
  final VitalSigns? vitalSigns;
  final String? notes;
  final String? audioRecordingPath;
  final bool hasAudioRecording;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Visit({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.nurseId,
    required this.nurseName,
    required this.scheduledTime,
    this.startTime,
    this.endTime,
    required this.status,
    this.location,
    required this.taskCompletions,
    this.vitalSigns,
    this.notes,
    this.audioRecordingPath,
    this.hasAudioRecording = false,
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Visit copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? nurseId,
    String? nurseName,
    DateTime? scheduledTime,
    DateTime? startTime,
    DateTime? endTime,
    VisitStatus? status,
    String? location,
    List<TaskCompletion>? taskCompletions,
    VitalSigns? vitalSigns,
    String? notes,
    String? audioRecordingPath,
    bool? hasAudioRecording,
    List<String>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Visit(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      nurseId: nurseId ?? this.nurseId,
      nurseName: nurseName ?? this.nurseName,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      location: location ?? this.location,
      taskCompletions: taskCompletions ?? this.taskCompletions,
      vitalSigns: vitalSigns ?? this.vitalSigns,
      notes: notes ?? this.notes,
      audioRecordingPath: audioRecordingPath ?? this.audioRecordingPath,
      hasAudioRecording: hasAudioRecording ?? this.hasAudioRecording,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isCompleted => status == VisitStatus.completed;
  bool get isInProgress => status == VisitStatus.inProgress;
  bool get isPlanned => status == VisitStatus.planned;
  bool get isCancelled => status == VisitStatus.cancelled;

  int get completedTasksCount => taskCompletions.where((task) => task.completed).length;
  int get totalTasksCount => taskCompletions.length;
  double get completionPercentage => totalTasksCount > 0 
    ? (completedTasksCount / totalTasksCount) * 100 
    : 0;

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        nurseId,
        nurseName,
        scheduledTime,
        startTime,
        endTime,
        status,
        location,
        taskCompletions,
        vitalSigns,
        notes,
        audioRecordingPath,
        hasAudioRecording,
        photos,
        createdAt,
        updatedAt,
      ];
}
