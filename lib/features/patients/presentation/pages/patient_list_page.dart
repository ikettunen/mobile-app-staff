import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nurse_app/core/navigation/app_router.dart';
import 'package:nurse_app/features/patients/presentation/bloc/patient_list_bloc.dart';
import '../../../../services/api_service.dart';

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
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<PatientListBloc, PatientListState>(
        builder: (context, state) {
          if (state is PatientListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PatientListLoaded) {
            if (state.patients.isEmpty) {
              return const Center(
                child: Text('No patients found'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PatientListBloc>().add(RefreshPatients());
              },
              child: ListView.builder(
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
                        backgroundColor: _getStatusColor(patient.status),
                        child: Text(
                          patient.firstName.isNotEmpty && patient.lastName.isNotEmpty
                              ? '${patient.firstName[0]}${patient.lastName[0]}'
                              : 'P',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(patient.fullName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Room: ${patient.room ?? 'N/A'} • ${patient.status}'),
                          if (patient.age != null)
                            Text('Age: ${patient.age}', 
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.medical_services),
                            onPressed: () {
                              _showPatientActions(context, patient);
                            },
                          ),
                          const Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.patientDetail,
                          arguments: {'patientId': patient.id},
                        );
                      },
                    ),
                  );
                },
              ),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add patient page
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'stable':
        return Colors.green;
      case 'improving':
        return Colors.blue;
      case 'critical':
        return Colors.red;
      case 'declining':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showPatientActions(BuildContext context, Patient patient) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              patient.fullName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.green),
              title: const Text('Start Visit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRouter.visitForm,
                  arguments: {
                    'patientId': patient.id,
                    'patientName': patient.fullName,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blue),
              title: const Text('View Info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRouter.info,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.orange),
              title: const Text('Patient Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRouter.patientDetail,
                  arguments: {'patientId': patient.id},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
