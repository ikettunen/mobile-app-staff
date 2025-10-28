import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nurse_app/features/visits/domain/entities/visit.dart';

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

class CreateVisit extends VisitEvent {
  final Visit visit;
  
  const CreateVisit(this.visit);
  
  @override
  List<Object?> get props => [visit];
}

class UpdateVisit extends VisitEvent {
  final Visit visit;
  
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
  final List<Visit> visits;
  
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
  VisitBloc() : super(VisitInitial()) {
    on<LoadVisits>(_onLoadVisits);
    on<CreateVisit>(_onCreateVisit);
    on<UpdateVisit>(_onUpdateVisit);
  }

  void _onLoadVisits(LoadVisits event, Emitter<VisitState> emit) async {
    emit(VisitLoading());
    try {
      // TODO: Implement API call to load visits
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      emit(const VisitLoaded([]));
    } catch (e) {
      emit(VisitError('Failed to load visits: $e'));
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
