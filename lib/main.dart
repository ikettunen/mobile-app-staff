import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nurse_app/core/di/service_locator.dart';
import 'package:nurse_app/core/navigation/app_router.dart';
import 'package:nurse_app/core/theme/app_theme.dart';
import 'package:nurse_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nurse_app/features/patients/presentation/bloc/patient_list_bloc.dart';
import 'package:nurse_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:nurse_app/features/visits/presentation/bloc/visit_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const NurseApp());
}

class NurseApp extends StatefulWidget {
  const NurseApp({super.key});

  @override
  State<NurseApp> createState() => _NurseAppState();
}

class _NurseAppState extends State<NurseApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt.authBloc..add(CheckAuthStatus()),
        ),
        BlocProvider<PatientListBloc>(
          create: (_) => getIt.patientListBloc,
        ),
        BlocProvider<TaskBloc>(
          create: (_) => getIt.taskBloc,
        ),
        BlocProvider<VisitBloc>(
          create: (_) => getIt.visitBloc,
        ),
      ],
      child: MaterialApp(
        title: 'Nurse App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
