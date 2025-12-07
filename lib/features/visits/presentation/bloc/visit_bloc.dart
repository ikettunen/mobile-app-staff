import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nurse_app/features/visits/domain/entities/visit.dart' as domain;
import '../../../../services/api_service.dart';
import '../../../../main.dart';

// Events
abstract class VisitEvent extends Equatable {
  const VisitEvent();

  @override
  List<Object?> get props => [];
}

class LoadVisits extends VisitEvent {
  final String patientId;
  
  const LoadVisits(this.patientId);
  
  @override
  List<Object?> get props => [patientId];
}

class LoadAllVisits extends VisitEvent {
  const LoadAllVisits();
}

class LoadNurseVisits extends VisitEvent {
  final String nurseId;
  
  const LoadNurseVisits(this.nurseId);
  
  @override
  List<Object?> get props => [nurseId];
}

class CreateVisit extends VisitEvent {
  final domain.Visit visit;
  
  const CreateVisit(this.visit);
  
  @override
  List<Object?> get props => [visit];
}

class UpdateVisit extends VisitEvent {
  final domain.Visit visit;
  
  const UpdateVisit(this.visit);
  
  @override
  List<Object?> get props => [visit];
}

// States
abstract class VisitState extends Equatable {
  const VisitState();

  @override
  List<Object?> get props => [];
}

class VisitInitial extends VisitState {}

class VisitLoading extends VisitState {}

class VisitLoaded extends VisitState {
  final List<domain.Visit> visits;
  
  const VisitLoaded(this.visits);
  
  @override
  List<Object?> get props => [visits];
}

class VisitError extends VisitState {
  final String message;
  
  const VisitError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final ApiService _apiService = ApiService();

  VisitBloc() : super(VisitInitial()) {
    on<LoadVisits>(_onLoadVisits);
    on<LoadAllVisits>(_onLoadAllVisits);
    on<LoadNurseVisits>(_onLoadNurseVisits);
    on<CreateVisit>(_onCreateVisit);
    on<UpdateVisit>(_onUpdateVisit);
  }

  void _onLoadVisits(LoadVisits event, Emitter<VisitState> emit) async {
    emit(VisitLoading());
    try {
      logger.i('Loading visits from API...');
      final apiVisits = await _apiService.getTodaysVisits();
      
      // Convert API visits to domain visits
      final domainVisits = apiVisits.map((apiVisit) => domain.Visit(
        id: apiVisit.id,
        patientId: apiVisit.patientId,
        patientName: apiVisit.patientName ?? 'Unknown Patient',
        nurseId: apiVisit.nurseId ?? '',
        nurseName: apiVisit.nurseName ?? '',
        status: _mapApiStatusToVisitStatus(apiVisit.status),
        scheduledTime: apiVisit.scheduledTime ?? DateTime.now(),
        startTime: apiVisit.startTime,
        endTime: apiVisit.endTime,
        location: apiVisit.location,
        notes: apiVisit.notes,
        taskCompletions: const [],
        vitalSigns: null,
        audioRecordingPath: null,
        hasAudioRecording: false,
        photos: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).toList();
      
      // Sort visits by scheduled time (oldest first)
      domainVisits.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      
      logger.i('Loaded ${domainVisits.length} visits');
      emit(VisitLoaded(domainVisits));
    } catch (e) {
      logger.e('Error loading visits: $e');
      emit(VisitError('Failed to load visits: $e'));
    }
  }

  void _onLoadAllVisits(LoadAllVisits event, Emitter<VisitState> emit) async {
    emit(VisitLoading());
    try {
      logger.i('VisitBloc: Starting to load all visits from API...');
      final apiVisits = await _apiService.getTodaysVisits();
      logger.i('VisitBloc: Received ${apiVisits.length} visits from API service');
      
      // Convert API visits to domain visits
      final domainVisits = apiVisits.map((apiVisit) => domain.Visit(
        id: apiVisit.id,
        patientId: apiVisit.patientId,
        patientName: apiVisit.patientName ?? 'Unknown Patient',
        nurseId: apiVisit.nurseId ?? '',
        nurseName: apiVisit.nurseName ?? '',
        status: _mapApiStatusToVisitStatus(apiVisit.status),
        scheduledTime: apiVisit.scheduledTime ?? DateTime.now(),
        startTime: apiVisit.startTime,
        endTime: apiVisit.endTime,
        location: apiVisit.location,
        notes: apiVisit.notes,
        taskCompletions: const [],
        vitalSigns: null,
        audioRecordingPath: null,
        hasAudioRecording: false,
        photos: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).toList();
      
      // Sort visits by scheduled time (oldest first)
      domainVisits.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      
      logger.i('VisitBloc: Successfully converted to ${domainVisits.length} domain visits');
      logger.i('VisitBloc: Emitting VisitLoaded state with visits');
      emit(VisitLoaded(domainVisits));
    } catch (e) {
      logger.e('VisitBloc: Error loading visits: $e');
      emit(VisitError('Failed to load visits: $e'));
    }
  }

  void _onLoadNurseVisits(LoadNurseVisits event, Emitter<VisitState> emit) async {
    emit(VisitLoading());
    try {
      logger.i('VisitBloc: Starting to load visits for nurse ${event.nurseId}...');
      final apiVisits = await _apiService.getNurseActiveVisits(event.nurseId);
      logger.i('VisitBloc: Received ${apiVisits.length} visits for nurse ${event.nurseId}');
      
      // Convert API visits to domain visits
      final domainVisits = apiVisits.map((apiVisit) => domain.Visit(
        id: apiVisit.id,
        patientId: apiVisit.patientId,
        patientName: apiVisit.patientName ?? 'Unknown Patient',
        nurseId: apiVisit.nurseId ?? '',
        nurseName: apiVisit.nurseName ?? '',
        status: _mapApiStatusToVisitStatus(apiVisit.status),
        scheduledTime: apiVisit.scheduledTime ?? DateTime.now(),
        startTime: apiVisit.startTime,
        endTime: apiVisit.endTime,
        location: apiVisit.location,
        notes: apiVisit.notes,
        taskCompletions: const [],
        vitalSigns: null,
        audioRecordingPath: null,
        hasAudioRecording: false,
        photos: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).toList();
      
      // Sort visits by scheduled time (oldest first)
      domainVisits.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      
      logger.i('VisitBloc: Successfully converted to ${domainVisits.length} domain visits for nurse');
      emit(VisitLoaded(domainVisits));
    } catch (e) {
      logger.e('VisitBloc: Error loading nurse visits: $e');
      emit(VisitError('Failed to load nurse visits: $e'));
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

  void _onCreateVisit(CreateVisit event, Emitter<VisitState> emit) async {
    try {
      // TODO: Implement API call to create visit
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      // For now, just emit the current state
      if (state is VisitLoaded) {
        final currentVisits = (state as VisitLoaded).visits;
        emit(VisitLoaded([...currentVisits, event.visit]));
      }
    } catch (e) {
      emit(VisitError('Failed to create visit: $e'));
    }
  }

  void _onUpdateVisit(UpdateVisit event, Emitter<VisitState> emit) async {
    try {
      // TODO: Implement API call to update visit
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      // For now, just emit the current state
      if (state is VisitLoaded) {
        final currentVisits = (state as VisitLoaded).visits;
        final updatedVisits = currentVisits.map((visit) => 
          visit.id == event.visit.id ? event.visit : visit
        ).toList();
        emit(VisitLoaded(updatedVisits));
      }
    } catch (e) {
      emit(VisitError('Failed to update visit: $e'));
    }
  }
}
