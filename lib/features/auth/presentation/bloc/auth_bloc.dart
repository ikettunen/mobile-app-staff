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
  final String name;
  
  const AuthAuthenticated(this.userId, this.email, this.name);
  
  @override
  List<Object?> get props => [userId, email, name];
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
  // Mock credentials for demo
  static const String _mockEmail = 'anna.virtanen@nursinghome.fi';
  static const String _mockPassword = 'password123';
  static const String _mockUserId = 'nurse_001';
  static const String _mockUserName = 'Anna Virtanen';

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
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Check mock credentials
      if (event.email == _mockEmail && event.password == _mockPassword) {
        emit(AuthAuthenticated(_mockUserId, _mockEmail, _mockUserName));
      } else {
        // For demo purposes, also accept any email/password combination
        // In production, this would be removed
        emit(AuthAuthenticated('demo_user', event.email, 'Demo User'));
      }
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
