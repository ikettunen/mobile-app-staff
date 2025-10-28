import 'package:nurse_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nurse_app/features/patients/presentation/bloc/patient_list_bloc.dart';
import 'package:nurse_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:nurse_app/features/visits/presentation/bloc/visit_bloc.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // BLoC instances
  AuthBloc? _authBloc;
  PatientListBloc? _patientListBloc;
  TaskBloc? _taskBloc;
  VisitBloc? _visitBloc;

  // Getters for BLoCs
  AuthBloc get authBloc => _authBloc ??= AuthBloc();
  PatientListBloc get patientListBloc => _patientListBloc ??= PatientListBloc();
  TaskBloc get taskBloc => _taskBloc ??= TaskBloc();
  VisitBloc get visitBloc => _visitBloc ??= VisitBloc();

  // Cleanup method
  void dispose() {
    _authBloc?.close();
    _patientListBloc?.close();
    _taskBloc?.close();
    _visitBloc?.close();
    
    _authBloc = null;
    _patientListBloc = null;
    _taskBloc = null;
    _visitBloc = null;
  }
}

// Global instance
final getIt = ServiceLocator();

Future<void> setupServiceLocator() async {
  // Service locator is already initialized
  // This function is kept for compatibility with main.dart
}