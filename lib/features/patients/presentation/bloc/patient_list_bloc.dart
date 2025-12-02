import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../services/api_service.dart';
import '../../../../main.dart';

// Events
abstract class PatientListEvent extends Equatable {
  const PatientListEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatients extends PatientListEvent {}

class RefreshPatients extends PatientListEvent {}

// States
abstract class PatientListState extends Equatable {
  const PatientListState();

  @override
  List<Object?> get props => [];
}

class PatientListInitial extends PatientListState {}

class PatientListLoading extends PatientListState {}

class PatientListLoaded extends PatientListState {
  final List<Patient> patients;
  
  const PatientListLoaded(this.patients);
  
  @override
  List<Object?> get props => [patients];
}

class PatientListError extends PatientListState {
  final String message;
  
  const PatientListError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class PatientListBloc extends Bloc<PatientListEvent, PatientListState> {
  final ApiService _apiService = ApiService();

  PatientListBloc() : super(PatientListInitial()) {
    on<LoadPatients>(_onLoadPatients);
    on<RefreshPatients>(_onRefreshPatients);
  }

  void _onLoadPatients(LoadPatients event, Emitter<PatientListState> emit) async {
    emit(PatientListLoading());
    try {
      logger.i('Loading patients...');
      final patients = await _apiService.getPatients();
      logger.i('Loaded ${patients.length} patients');
      emit(PatientListLoaded(patients));
    } catch (e) {
      logger.e('Failed to load patients: $e');
      emit(PatientListError('Failed to load patients: $e'));
    }
  }

  void _onRefreshPatients(RefreshPatients event, Emitter<PatientListState> emit) async {
    try {
      logger.i('Refreshing patients...');
      final patients = await _apiService.getPatients();
      logger.i('Refreshed ${patients.length} patients');
      emit(PatientListLoaded(patients));
    } catch (e) {
      logger.e('Failed to refresh patients: $e');
      emit(PatientListError('Failed to refresh patients: $e'));
    }
  }
}
