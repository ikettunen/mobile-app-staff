import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nurse_app/core/navigation/app_router.dart';
import 'package:nurse_app/features/visits/presentation/bloc/visit_bloc.dart';
import 'package:nurse_app/features/visits/domain/entities/visit.dart';
import 'package:nurse_app/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../main.dart';

class VisitListPage extends StatefulWidget {
  const VisitListPage({super.key});

  @override
  State<VisitListPage> createState() => _VisitListPageState();
}

class _VisitListPageState extends State<VisitListPage> {
  bool _showOnlyMyVisits = true; // Default to showing only assigned visits

  @override
  void initState() {
    super.initState();
    // Load visits based on filter
    _loadVisits();
  }

  void _loadVisits() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && _showOnlyMyVisits) {
      // Use staff-{staffId} format to match database
      final staffId = authState.staffId ?? '1001'; // Default to 1001 if not available
      final nurseId = 'staff-$staffId';
      logger.i('VisitListPage: Loading visits for nurse $nurseId');
      context.read<VisitBloc>().add(LoadNurseVisits(nurseId));
    } else {
      logger.i('VisitListPage: Loading all visits');
      context.read<VisitBloc>().add(const LoadAllVisits());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                      onPressed: _loadVisits,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _showOnlyMyVisits ? 'My Visits' : 'All Visits',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Switch(
                      value: _showOnlyMyVisits,
                      onChanged: (value) {
                        setState(() {
                          _showOnlyMyVisits = value;
                        });
                        _loadVisits();
                      },
                      activeColor: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Only My Visits',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
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
                      _loadVisits();
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
                                Text(
                                  _formatDateTime(visit.scheduledTime),
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
                          onPressed: _loadVisits,
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final visitDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    if (visitDate == today) {
      return 'Today $time';
    } else if (visitDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow $time';
    } else if (visitDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday $time';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} $time';
    }
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