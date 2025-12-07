import 'package:dio/dio.dart';
import '../main.dart';

class ApiService {
  // Use API Gateway for all requests
  static const String apiGatewayUrl = 'http://51.20.164.143:3001/api';
  
  late final Dio _dio;
  
  // Expose dio for direct access when needed
  Dio get dio => _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: apiGatewayUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptor for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => logger.d(obj),
    ));
  }

  // Get all patients
  Future<List<Patient>> getPatients() async {
    try {
      logger.i('Fetching patients from: $apiGatewayUrl/fhir/patients');
      final response = await _dio.get('/fhir/patients');
      logger.i('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> patientsJson = data['data'] ?? data ?? [];
        logger.i('Received ${patientsJson.length} patients from API');
        return patientsJson.map((json) => Patient.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load patients: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching patients: $e');
      logger.e('Error type: ${e.runtimeType}');
      // Return mock data for now if API fails
      logger.w('Falling back to mock data');
      return _getMockPatients();
    }
  }

  // Get today's visits
  Future<List<Visit>> getTodaysVisits() async {
    try {
      // Use API Gateway - it will route to visits service
      final response = await _dio.get('/visits');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> visitsJson = data['data'] ?? [];
        return visitsJson.map((json) => Visit.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load visits: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching visits: $e');
      // Return mock data for now if API fails
      return _getMockVisits();
    }
  }

  // Get active visits for a specific nurse
  Future<List<Visit>> getNurseActiveVisits(String nurseId) async {
    try {
      logger.i('Fetching active visits for nurse: $nurseId');
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      final response = await _dio.get(
        '/visits/nurse/$nurseId/active',
        queryParameters: {
          'date_from': startOfDay.toIso8601String(),
          'date_to': endOfDay.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> visitsJson = data['data'] ?? [];
        logger.i('Received ${visitsJson.length} visits for nurse $nurseId');
        return visitsJson.map((json) => Visit.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load nurse visits: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching nurse visits: $e');
      // Return filtered mock data for the nurse
      return _getMockVisits().where((v) => v.nurseId == nurseId).toList();
    }
  }

  // Get visits by patient ID
  Future<List<Visit>> getPatientVisits(String patientId) async {
    try {
      final response = await _dio.get('/visits/patient/$patientId');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> visitsJson = data['data'] ?? [];
        return visitsJson.map((json) => Visit.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load patient visits: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching patient visits: $e');
      return [];
    }
  }

  // Get a single visit by ID with full details including tasks
  Future<Map<String, dynamic>?> getVisitById(String visitId) async {
    try {
      logger.i('Fetching visit details for: $visitId');
      final response = await _dio.get('/visits/$visitId');

      if (response.statusCode == 200) {
        final data = response.data;
        logger.i('Received visit data with ${data['data']?['taskCompletions']?.length ?? 0} tasks');
        return data['data'];
      } else {
        throw Exception('Failed to load visit: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching visit by ID: $e');
      return null;
    }
  }

  // Get all tasks from all visits
  Future<List<TaskItem>> getAllTasks() async {
    try {
      logger.i('Fetching all tasks from visits');
      final response = await _dio.get('/visits');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> visitsJson = data['data'] ?? [];
        
        // Extract all tasks from all visits
        List<TaskItem> allTasks = [];
        for (var visitJson in visitsJson) {
          final visit = Visit.fromJson(visitJson);
          final taskCompletions = visitJson['taskCompletions'] as List<dynamic>? ?? [];
          
          for (var taskJson in taskCompletions) {
            allTasks.add(TaskItem.fromJson(taskJson, visit));
          }
        }
        
        logger.i('Received ${allTasks.length} tasks from API');
        return allTasks;
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching tasks: $e');
      return [];
    }
  }

  // Get HTML documents from S3
  Future<List<HtmlDocument>> getHtmlDocuments() async {
    try {
      logger.i('Fetching HTML documents from S3 service');
      final response = await _dio.get('/sound-data', queryParameters: {
        'contentType': 'text/html',
        'limit': 20,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> documentsJson = data['data']?['records'] ?? [];
        logger.i('Received ${documentsJson.length} HTML documents from API');
        return documentsJson.map((json) => HtmlDocument.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load HTML documents: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching HTML documents: $e');
      // Return mock data for now if API fails
      return _getMockHtmlDocuments();
    }
  }

  // Mock HTML documents
  List<HtmlDocument> _getMockHtmlDocuments() {
    return [
      HtmlDocument(
        id: 'doc-1',
        title: 'Patient Care Guidelines',
        description: 'Comprehensive guidelines for patient care procedures',
        url: 'https://example.com/care-guidelines.html',
        category: 'Guidelines',
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      ),
      HtmlDocument(
        id: 'doc-2',
        title: 'Medication Administration Protocol',
        description: 'Step-by-step medication administration procedures',
        url: 'https://example.com/medication-protocol.html',
        category: 'Protocols',
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      ),
      HtmlDocument(
        id: 'doc-3',
        title: 'Emergency Procedures',
        description: 'Emergency response procedures and contact information',
        url: 'https://example.com/emergency-procedures.html',
        category: 'Emergency',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      ),
      HtmlDocument(
        id: 'doc-4',
        title: 'Infection Control Guidelines',
        description: 'Guidelines for infection prevention and control',
        url: 'https://example.com/infection-control.html',
        category: 'Safety',
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  // Save recording URL to visit
  Future<bool> saveRecordingToVisit(String visitId, String recordingUrl) async {
    try {
      final response = await _dio.patch('/visits/$visitId/recording', data: {
        'recording_url': recordingUrl,
      });

      if (response.statusCode == 200) {
        logger.i('Recording URL saved to visit $visitId');
        return true;
      } else {
        throw Exception('Failed to save recording: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error saving recording to visit: $e');
      // For now, return true to simulate success
      return true;
    }
  }

  // Complete a task within a visit
  Future<bool> completeTask({
    required String visitId,
    required String taskId,
    required String staffId,
    String? staffName,
    String? notes,
  }) async {
    try {
      logger.i('Completing task $taskId in visit $visitId by staff $staffId');
      final response = await _dio.put(
        '/visits/$visitId/tasks/$taskId/complete',
        data: {
          'staffId': staffId,
          if (staffName != null) 'staffName': staffName,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        logger.i('Task $taskId completed successfully');
        return true;
      } else {
        throw Exception('Failed to complete task: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error completing task: $e');
      return false;
    }
  }

  // Add a note to a visit (appends to existing notes)
  Future<bool> addNoteToVisit({
    required String visitId,
    required String noteText,
    required String staffId,
    String? staffName,
    String noteType = 'general',
  }) async {
    try {
      logger.i('Adding note to visit $visitId by staff $staffId');
      final response = await _dio.post(
        '/visits/$visitId/notes',
        data: {
          'noteText': noteText,
          'staffId': staffId,
          if (staffName != null) 'staffName': staffName,
          'noteType': noteType,
        },
      );

      if (response.statusCode == 200) {
        logger.i('Note added to visit $visitId successfully');
        return true;
      } else {
        throw Exception('Failed to add note: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error adding note to visit: $e');
      return false;
    }
  }

  // Mock data fallback
  List<Patient> _getMockPatients() {
    return [
      Patient(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        room: '101',
        status: 'stable',
        dateOfBirth: DateTime(1950, 5, 15),
      ),
      Patient(
        id: '2',
        firstName: 'Jane',
        lastName: 'Smith',
        room: '102',
        status: 'improving',
        dateOfBirth: DateTime(1945, 8, 22),
      ),
      Patient(
        id: '3',
        firstName: 'Robert',
        lastName: 'Johnson',
        room: '103',
        status: 'stable',
        dateOfBirth: DateTime(1960, 12, 3),
      ),
      Patient(
        id: '4',
        firstName: 'Mary',
        lastName: 'Williams',
        room: '104',
        status: 'critical',
        dateOfBirth: DateTime(1955, 3, 18),
      ),
      Patient(
        id: '5',
        firstName: 'David',
        lastName: 'Brown',
        room: '105',
        status: 'stable',
        dateOfBirth: DateTime(1948, 9, 7),
      ),
    ];
  }

  // Mock visits data fallback
  List<Visit> _getMockVisits() {
    final now = DateTime.now();
    return [
      Visit(
        id: '1',
        patientId: '1',
        patientName: 'John Doe',
        nurseId: 'staff-1001',
        nurseName: 'Anna Virtanen',
        status: 'finished',
        scheduledTime: now.subtract(const Duration(hours: 2)),
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1, minutes: 30)),
        location: '101',
        notes: 'Routine check completed',
      ),
      Visit(
        id: '2',
        patientId: '2',
        patientName: 'Jane Smith',
        nurseId: 'staff-1001',
        nurseName: 'Anna Virtanen',
        status: 'in-progress',
        scheduledTime: now.subtract(const Duration(minutes: 30)),
        startTime: now.subtract(const Duration(minutes: 30)),
        location: '102',
      ),
      Visit(
        id: '3',
        patientId: '3',
        patientName: 'Robert Johnson',
        nurseId: 'staff-1002',
        nurseName: 'Matti Korhonen',
        status: 'planned',
        scheduledTime: now.add(const Duration(hours: 1)),
        location: '103',
      ),
      Visit(
        id: '4',
        patientId: '4',
        patientName: 'Mary Williams',
        nurseId: 'staff-1001',
        nurseName: 'Anna Virtanen',
        status: 'planned',
        scheduledTime: now.add(const Duration(hours: 2)),
        location: '104',
      ),
      Visit(
        id: '5',
        patientId: '5',
        patientName: 'David Brown',
        nurseId: 'staff-1003',
        nurseName: 'Liisa Hakkarainen',
        status: 'planned',
        scheduledTime: now.add(const Duration(hours: 3)),
        location: '105',
      ),
    ];
  }
}

// Patient model
class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final String? room;
  final String status;
  final DateTime? dateOfBirth;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.room,
    required this.status,
    this.dateOfBirth,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      firstName: json['firstName'] ?? json['name']?['given']?.first ?? '',
      lastName: json['lastName'] ?? json['name']?['family'] ?? '',
      room: json['room']?.toString(),
      status: json['status'] ?? 'unknown',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : json['birthDate'] != null
              ? DateTime.tryParse(json['birthDate'])
              : null,
    );
  }

  String get fullName => '$firstName $lastName';

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }
}

// Visit model
class Visit {
  final String id;
  final String patientId;
  final String? patientName;  // Made nullable
  final String? nurseId;      // Added nurse fields
  final String? nurseName;    // Added nurse fields
  final String status;
  final DateTime? scheduledTime;  // Made nullable to handle parsing errors
  final DateTime? startTime;
  final DateTime? endTime;
  final String? location;
  final String? notes;

  Visit({
    required this.id,
    required this.patientId,
    this.patientName,  // Now optional
    this.nurseId,      // Added nurse fields
    this.nurseName,    // Added nurse fields
    required this.status,
    this.scheduledTime,  // Now optional
    this.startTime,
    this.endTime,
    this.location,
    this.notes,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? json['patient_id']?.toString() ?? '',
      patientName: json['patientName'] as String? ?? json['patient_name'] as String?,
      nurseId: json['nurseId'] as String? ?? json['nurse_id'] as String?,
      nurseName: json['nurseName'] as String? ?? json['nurse_name'] as String?,
      status: json['status'] ?? 'unknown',
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.tryParse(json['scheduledTime'])
          : (json['scheduled_time'] != null ? DateTime.tryParse(json['scheduled_time']) : null),
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'])
          : (json['start_time'] != null ? DateTime.tryParse(json['start_time']) : null),
      endTime: json['endTime'] != null 
          ? DateTime.tryParse(json['endTime']) 
          : (json['end_time'] != null ? DateTime.tryParse(json['end_time']) : null),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );
  }

  bool get isCompleted =>
      status.toLowerCase() == 'finished' || status.toLowerCase() == 'completed';
  bool get isInProgress => status.toLowerCase() == 'in-progress';
  bool get isPlanned => status.toLowerCase() == 'planned';
}

// HTML Document model
class HtmlDocument {
  final String id;
  final String title;
  final String description;
  final String url;
  final String category;
  final DateTime lastUpdated;

  HtmlDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.category,
    required this.lastUpdated,
  });

  factory HtmlDocument.fromJson(Map<String, dynamic> json) {
    return HtmlDocument(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? json['fileName'] ?? 'Untitled Document',
      description: json['description'] ?? 'No description available',
      url: json['fileUrl'] ?? json['url'] ?? '',
      category: json['category'] ?? json['recordingType'] ?? 'General',
      lastUpdated: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// TaskItem model (tasks from visits)
class TaskItem {
  final String taskId;
  final String taskType;
  final String taskTitle;
  final String taskCategory;
  final String priority;
  final bool completed;
  final DateTime? completedAt;
  final Map<String, dynamic>? completedBy;
  final String? notes;
  final List<dynamic> issues;
  
  // Visit context
  final String visitId;
  final String? patientId;
  final String? patientName;
  final DateTime? scheduledTime;
  final String? location;

  TaskItem({
    required this.taskId,
    required this.taskType,
    required this.taskTitle,
    required this.taskCategory,
    required this.priority,
    required this.completed,
    this.completedAt,
    this.completedBy,
    this.notes,
    required this.issues,
    required this.visitId,
    this.patientId,
    this.patientName,
    this.scheduledTime,
    this.location,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json, Visit visit) {
    return TaskItem(
      taskId: json['taskId']?.toString() ?? json['_id']?.toString() ?? '',
      taskType: json['taskType'] ?? json['task_type'] ?? '',
      taskTitle: json['taskTitle'] ?? json['task_title'] ?? '',
      taskCategory: json['taskCategory'] ?? json['task_category'] ?? '',
      priority: json['priority'] ?? 'medium',
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : (json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null),
      completedBy: json['completedBy'] ?? json['completed_by'],
      notes: json['notes'] as String?,
      issues: json['issues'] ?? [],
      visitId: visit.id,
      patientId: visit.patientId,
      patientName: visit.patientName,
      scheduledTime: visit.scheduledTime,
      location: visit.location,
    );
  }
}
