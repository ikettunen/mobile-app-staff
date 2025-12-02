import 'package:flutter/material.dart';
import 'package:nurse_app/features/auth/presentation/pages/login_page.dart';
import 'package:nurse_app/features/home/presentation/pages/home_page.dart';
import 'package:nurse_app/features/patients/presentation/pages/patient_detail_page.dart';
import 'package:nurse_app/features/patients/presentation/pages/patient_list_page.dart';
import 'package:nurse_app/features/splash/presentation/pages/splash_page.dart';
import 'package:nurse_app/features/tasks/presentation/pages/task_detail_page.dart';
import 'package:nurse_app/features/info/presentation/pages/info_page.dart';
import 'package:nurse_app/features/visits/presentation/pages/visit_detail_page.dart';
import 'package:nurse_app/features/visits/presentation/pages/visit_form_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String patientList = '/home/patients';
  static const String info = '/home/info';
  static const String patientDetail = '/patient';
  static const String taskDetail = '/task';
  static const String visitForm = '/visit/new';
  static const String visitDetail = '/visit';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case patientList:
        return MaterialPageRoute(
          builder: (_) => const PatientListPage(),
          settings: settings,
        );
      case info:
        return MaterialPageRoute(
          builder: (_) => const InfoPage(),
          settings: settings,
        );
      case patientDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final patientId = args?['patientId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => PatientDetailPage(patientId: patientId),
          settings: settings,
        );
      case taskDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final taskId = args?['taskId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => TaskDetailPage(taskId: taskId),
          settings: settings,
        );
      case visitForm:
        final args = settings.arguments as Map<String, dynamic>?;
        final patientId = args?['patientId'] as String? ?? '';
        final patientName = args?['patientName'] as String? ?? 'Unknown Patient';
        return MaterialPageRoute(
          builder: (_) => VisitFormPage(
            patientId: patientId,
            patientName: patientName,
          ),
          settings: settings,
        );
      case visitDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final visitId = args?['visitId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => VisitDetailPage(visitId: visitId),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
