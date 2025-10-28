import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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
  final List<Map<String, dynamic>> patients;
  
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
  PatientListBloc() : super(PatientListInitial()) {
    on<LoadPatients>(_onLoadPatients);
    on<RefreshPatients>(_onRefreshPatients);
  }

  void _onLoadPatients(LoadPatients event, Emitter<PatientListState> emit) async {
    emit(PatientListLoading());
    try {
      // TODO: Implement API call to load patients
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      emit(const PatientListLoaded([]));
    } catch (e) {
      emit(PatientListError('Failed to load patients: $e'));
    }
  }

  void _onRefreshPatients(RefreshPatients event, Emitter<PatientListState> emit) async {
    try {
      // TODO: Implement API call to refresh patients
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      emit(const PatientListLoaded([]));
    } catch (e) {
      emit(PatientListError('Failed to refresh patients: $e'));
    }
  }
}
