import 'package:equatable/equatable.dart';

enum TaskPriority { high, medium, low }

enum TaskStatus { pending, inProgress, completed, cancelled }

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final String patientId;
  final String patientName;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime dueDate;
  final String? assignedTo;
  final String? assignedToName;
  final List<String> categories;
  final DateTime? completedAt;
  final String? completedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.patientId,
    required this.patientName,
    required this.priority,
    required this.status,
    required this.dueDate,
    this.assignedTo,
    this.assignedToName,
    required this.categories,
    this.completedAt,
    this.completedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? patientId,
    String? patientName,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    String? assignedTo,
    String? assignedToName,
    List<String>? categories,
    DateTime? completedAt,
    String? completedBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      categories: categories ?? this.categories,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        patientId,
        patientName,
        priority,
        status,
        dueDate,
        assignedTo,
        assignedToName,
        categories,
        completedAt,
        completedBy,
        notes,
        createdAt,
        updatedAt,
      ];
}
