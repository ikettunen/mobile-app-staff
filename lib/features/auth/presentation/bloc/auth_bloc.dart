import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const LoginRequested(this.email, this.password);
  
  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  
  const AuthAuthenticated(this.userId, this.email);
  
  @override
  List<Object?> get props => [userId, email];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // TODO: Implement actual auth check
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      // For demo purposes, assume user is not authenticated
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to check auth status: $e'));
    }
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // TODO: Implement actual login
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      // For demo purposes, accept any email/password
      emit(AuthAuthenticated('user123', event.email));
    } catch (e) {
      emit(AuthError('Failed to login: $e'));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      // TODO: Implement actual logout
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to logout: $e'));
    }
  }
}
