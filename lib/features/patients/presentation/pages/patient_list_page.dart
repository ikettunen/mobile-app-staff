import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nurse_app/core/navigation/app_router.dart';
import 'package:nurse_app/features/patients/presentation/bloc/patient_list_bloc.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  @override
  void initState() {
    super.initState();
    context.read<PatientListBloc>().add(LoadPatients());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: BlocBuilder<PatientListBloc, PatientListState>(
        builder: (context, state) {
          if (state is PatientListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PatientListLoaded) {
            if (state.patients.isEmpty) {
              return const Center(
                child: Text('No patients found'),
              );
            }
            return ListView.builder(
              itemCount: state.patients.length,
              itemBuilder: (context, index) {
                final patient = state.patients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        (patient['name'] as String? ?? '').isNotEmpty
                            ? (patient['name'] as String)[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(patient['name'] as String? ?? 'Unknown'),
                    subtitle: Text('Room: ${patient['roomNumber'] ?? 'N/A'}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.patientDetail,
                        arguments: {'patientId': patient['id']},
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is PatientListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PatientListBloc>().add(LoadPatients());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add patient page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
