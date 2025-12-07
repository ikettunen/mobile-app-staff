import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../services/auth_service.dart';
import '../../../../main.dart';

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
  final String token;
  final String? staffId;
  
  const AuthAuthenticated(this.userId, this.email, this.name, this.token, {this.staffId});
  
  @override
  List<Object?> get props => [userId, email, name, token, staffId];
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
  final AuthService _authService = AuthService();

  AuthBloc() : super(AuthInitial()) {
    _authService.initialize();
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Check if we have stored auth data
      final hasStoredAuth = await _authService.loadStoredAuthData();
      
      if (hasStoredAuth && _authService.isAuthenticated) {
        final user = _authService.currentUser;
        if (user != null) {
          emit(AuthAuthenticated(
            _authService.currentUserId ?? 'unknown',
            user['email'] ?? 'unknown@example.com',
            '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
            _authService.currentToken ?? '',
            staffId: user['staffId'],
          ));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      logger.e('Failed to check auth status: $e');
      emit(AuthError('Failed to check auth status: $e'));
    }
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      logger.i('Attempting login for: ${event.email}');
      
      final authData = await _authService.login(event.email, event.password);
      
      if (authData != null) {
        final user = authData['user'];
        final token = authData['token'];
        
        emit(AuthAuthenticated(
          user['id'] ?? user['_id'] ?? 'unknown',
          user['email'] ?? event.email,
          '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
          token,
          staffId: user['staffId'],
        ));
        
        logger.i('Login successful via AuthBloc');
      } else {
        emit(AuthError('Invalid email or password'));
      }
    } catch (e) {
      logger.e('Login failed in AuthBloc: $e');
      emit(AuthError('Failed to login: $e'));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authService.logout();
      emit(AuthUnauthenticated());
      logger.i('Logout successful via AuthBloc');
    } catch (e) {
      logger.e('Logout failed in AuthBloc: $e');
      emit(AuthError('Failed to logout: $e'));
    }
  }
}
