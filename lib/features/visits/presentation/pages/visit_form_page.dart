import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nurse_app/features/visits/presentation/bloc/visit_bloc.dart';

class VisitFormPage extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String? visitId;

  const VisitFormPage({
    super.key,
    required this.patientId,
    required this.patientName,
    this.visitId,
  });

  @override
  State<VisitFormPage> createState() => _VisitFormPageState();
}

class _VisitFormPageState extends State<VisitFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime _visitDate = DateTime.now();
  TimeOfDay _visitTime = TimeOfDay.now();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveVisit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement visit saving logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visit saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _visitDate) {
      setState(() {
        _visitDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _visitTime,
    );
    if (picked != null && picked != _visitTime) {
      setState(() {
        _visitTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visit for ${widget.patientName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveVisit,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visit Information',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Patient', widget.patientName),
                      _buildInfoRow('Patient ID', widget.patientId),
                      _buildInfoRow('Visit ID', widget.visitId ?? 'New Visit'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visit Details',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date'),
                        subtitle: Text(
                          '${_visitDate.day}/${_visitDate.month}/${_visitDate.year}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _selectDate,
                      ),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Time'),
                        subtitle: Text(_visitTime.format(context)),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _selectTime,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Visit Notes',
                          hintText: 'Enter notes about this visit...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter visit notes';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vital Signs',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Blood Pressure',
                                hintText: '120/80',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Heart Rate',
                                hintText: '72',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Temperature',
                                hintText: '98.6',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'O2 Saturation',
                                hintText: '98',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasks Completed',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      const ListTile(
                        leading: Icon(Icons.medication),
                        title: Text('Medication Administration'),
                        trailing: Checkbox(value: false, onChanged: null),
                      ),
                      const ListTile(
                        leading: Icon(Icons.favorite),
                        title: Text('Vital Signs Check'),
                        trailing: Checkbox(value: true, onChanged: null),
                      ),
                      const ListTile(
                        leading: Icon(Icons.assessment),
                        title: Text('Patient Assessment'),
                        trailing: Checkbox(value: false, onChanged: null),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveVisit,
        icon: const Icon(Icons.save),
        label: const Text('Save Visit'),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}