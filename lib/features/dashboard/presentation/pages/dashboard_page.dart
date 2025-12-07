import 'package:flutter/material.dart';
import '../../../../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  final Function(int)? onTabChange;
  
  const DashboardPage({super.key, this.onTabChange});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  
  int totalPatients = 0;
  int todayVisits = 0;
  int completedTasks = 0;
  int pendingTasks = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _apiService.getPatients(),
        _apiService.getTodaysVisits(),
        _apiService.getAllTasks(),
      ]);

      final patients = results[0] as List<Patient>;
      final visits = results[1] as List<Visit>;
      final tasks = results[2] as List<TaskItem>;

      setState(() {
        totalPatients = patients.length;
        todayVisits = visits.length;
        completedTasks = tasks.where((task) => task.completed).length;
        pendingTasks = tasks.where((task) => !task.completed).length;
        _isLoading = false;
      });
    } catch (e) {
      // If API fails, keep showing 0s
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadDashboardData();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Today is ${_formatDate(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Statistics Grid
              const Text(
                'Today\'s Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    'Total Patients',
                    totalPatients.toString(),
                    Icons.people,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Today\'s Visits',
                    todayVisits.toString(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Completed Tasks',
                    completedTasks.toString(),
                    Icons.check_circle,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Pending Tasks',
                    pendingTasks.toString(),
                    Icons.pending,
                    Colors.red,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      'View Patients',
                      Icons.people,
                      Colors.blue,
                      () => _navigateToTab(1), // Patients is now tab 1
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      'Today\'s Visits',
                      Icons.calendar_today,
                      Colors.green,
                      () => _navigateToTab(2), // Visits is now tab 2
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      'Task Instructions',
                      Icons.info_outline,
                      Colors.orange,
                      () => _navigateToTab(3), // Info is now tab 3
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      'Emergency',
                      Icons.emergency,
                      Colors.red,
                      () => _showEmergencyDialog(),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Recent Activity
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildActivityCard(
                'Visit completed for John Doe',
                'Room 101 • 2 hours ago',
                Icons.check_circle,
                Colors.green,
              ),
              _buildActivityCard(
                'New patient admitted: Jane Smith',
                'Room 205 • 4 hours ago',
                Icons.person_add,
                Colors.blue,
              ),
              _buildActivityCard(
                'Medication administered to Robert Johnson',
                'Room 103 • 6 hours ago',
                Icons.medication,
                Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTab(int index) {
    // Call the parent HomePage to switch tabs
    if (widget.onTabChange != null) {
      widget.onTabChange!(index);
    }
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Contacts'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.local_hospital, color: Colors.red),
              title: Text('Emergency Services'),
              subtitle: Text('112'),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.blue),
              title: Text('Nursing Supervisor'),
              subtitle: Text('+358 40 123 4567'),
            ),
            ListTile(
              leading: Icon(Icons.medical_services, color: Colors.green),
              title: Text('On-Call Doctor'),
              subtitle: Text('+358 40 987 6543'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}