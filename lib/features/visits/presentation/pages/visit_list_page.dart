import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nurse_app/core/navigation/app_router.dart';
import 'package:nurse_app/features/visits/presentation/bloc/visit_bloc.dart';
import 'package:nurse_app/features/visits/domain/entities/visit.dart';
import '../../../../services/api_service.dart';
import '../../../../main.dart';

class VisitListPage extends StatefulWidget {
  const VisitListPage({super.key});

  @override
  State<VisitListPage> createState() => _VisitListPageState();
}

class _VisitListPageState extends State<VisitListPage> {
  @override
  void initState() {
    super.initState();
    // Load all visits for today
    logger.i('VisitListPage: Triggering LoadAllVisits event');
    context.read<VisitBloc>().add(const LoadAllVisits());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Visits',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<VisitBloc>().add(const LoadAllVisits());
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<VisitBloc, VisitState>(
              builder: (context, state) {
                logger.i('VisitListPage: Received state: ${state.runtimeType}');
                if (state is VisitLoading) {
                  logger.i('VisitListPage: Showing loading indicator');
                  return const Center(child: CircularProgressIndicator());
                } else if (state is VisitLoaded) {
                  logger.i('VisitListPage: Received ${state.visits.length} visits');
                  if (state.visits.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No visits scheduled for today',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<VisitBloc>().add(const LoadAllVisits());
                    },
                    child: ListView.builder(
                      itemCount: state.visits.length,
                      itemBuilder: (context, index) {
                        final visit = state.visits[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(visit.status),
                              child: Icon(
                                _getStatusIcon(visit.status),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(visit.patientName ?? 'Unknown Patient'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (visit.location != null)
                                  Text('Room: ${visit.location}'),
                                if (visit.scheduledTime != null)
                                  Text(
                                    'Time: ${_formatTime(visit.scheduledTime!)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                Text('Status: ${visit.status.name}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (visit.status == VisitStatus.planned)
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                                    onPressed: () => _startVisit(visit),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () => _viewVisitDetails(visit),
                                ),
                              ],
                            ),
                            onTap: () => _viewVisitDetails(visit),
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is VisitError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.message}'),
                        ElevatedButton(
                          onPressed: () {
                            context.read<VisitBloc>().add(const LoadAllVisits());
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
    );
  }

  Color _getStatusColor(VisitStatus status) {
    switch (status) {
      case VisitStatus.planned:
        return Colors.blue;
      case VisitStatus.inProgress:
        return Colors.orange;
      case VisitStatus.completed:
        return Colors.green;
      case VisitStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(VisitStatus status) {
    switch (status) {
      case VisitStatus.planned:
        return Icons.schedule;
      case VisitStatus.inProgress:
        return Icons.play_arrow;
      case VisitStatus.completed:
        return Icons.check;
      case VisitStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _startVisit(visit) {
    Navigator.pushNamed(
      context,
      AppRouter.visitForm,
      arguments: {
        'patientId': visit.patientId,
        'patientName': visit.patientName,
        'visitId': visit.id,
      },
    );
  }

  void _viewVisitDetails(visit) {
    Navigator.pushNamed(
      context,
      AppRouter.visitDetail,
      arguments: {'visitId': visit.id},
    );
  }
}