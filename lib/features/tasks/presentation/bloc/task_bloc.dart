import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nurse_app/features/tasks/domain/entities/task.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final String patientId;
  
  const LoadTasks(this.patientId);
  
  @override
  List<Object?> get props => [patientId];
}

class CompleteTask extends TaskEvent {
  final String taskId;
  
  const CompleteTask(this.taskId);
  
  @override
  List<Object?> get props => [taskId];
}

class UpdateTask extends TaskEvent {
  final Task task;
  
  const UpdateTask(this.task);
  
  @override
  List<Object?> get props => [task];
}

// States
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  
  const TaskLoaded(this.tasks);
  
  @override
  List<Object?> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;
  
  const TaskError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CompleteTask>(_onCompleteTask);
    on<UpdateTask>(_onUpdateTask);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      // TODO: Implement API call to load tasks
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      emit(const TaskLoaded([]));
    } catch (e) {
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  void _onCompleteTask(CompleteTask event, Emitter<TaskState> emit) async {
    try {
      // TODO: Implement API call to complete task
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      // For now, just emit the current state
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).tasks;
        final updatedTasks = currentTasks.map((task) => 
          task.id == event.taskId ? task.copyWith(status: TaskStatus.completed, completedAt: DateTime.now()) : task
        ).toList();
        emit(TaskLoaded(updatedTasks));
      }
    } catch (e) {
      emit(TaskError('Failed to complete task: $e'));
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      // TODO: Implement API call to update task
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      // For now, just emit the current state
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).tasks;
        final updatedTasks = currentTasks.map((task) => 
          task.id == event.task.id ? event.task : task
        ).toList();
        emit(TaskLoaded(updatedTasks));
      }
    } catch (e) {
      emit(TaskError('Failed to update task: $e'));
    }
  }
}
