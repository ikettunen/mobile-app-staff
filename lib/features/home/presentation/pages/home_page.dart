import 'package:flutter/material.dart';
import 'package:nurse_app/core/navigation/app_router.dart';
import 'package:nurse_app/features/patients/presentation/pages/patient_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const PatientListPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) => _onTabTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRouter.patientList);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRouter.taskList);
        break;
    }
  }
}
