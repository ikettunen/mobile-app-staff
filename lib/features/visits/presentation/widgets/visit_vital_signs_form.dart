import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nurse_app/features/visits/domain/entities/visit.dart';

class VisitVitalSignsForm extends StatefulWidget {
  final VitalSigns initialVitalSigns;
  final Function(VitalSigns) onChanged;

  const VisitVitalSignsForm({
    super.key,
    required this.initialVitalSigns,
    required this.onChanged,
  });

  @override
  State<VisitVitalSignsForm> createState() => _VisitVitalSignsFormState();
}

class _VisitVitalSignsFormState extends State<VisitVitalSignsForm> {
  late TextEditingController _temperatureController;
  late TextEditingController _heartRateController;
  late TextEditingController _respiratoryRateController;
  late TextEditingController _systolicBPController;
  late TextEditingController _diastolicBPController;
  late TextEditingController _oxygenSaturationController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _temperatureController = TextEditingController(
      text: widget.initialVitalSigns.temperature?.toString() ?? '',
    );
    _heartRateController = TextEditingController(
      text: widget.initialVitalSigns.heartRate?.toString() ?? '',
    );
    _respiratoryRateController = TextEditingController(
      text: widget.initialVitalSigns.respiratoryRate?.toString() ?? '',
    );
    _systolicBPController = TextEditingController(
      text: widget.initialVitalSigns.systolicBP?.toString() ?? '',
    );
    _diastolicBPController = TextEditingController(
      text: widget.initialVitalSigns.diastolicBP?.toString() ?? '',
    );
    _oxygenSaturationController = TextEditingController(
      text: widget.initialVitalSigns.oxygenSaturation?.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.initialVitalSigns.notes ?? '',
    );
  }

  @override
  void didUpdateWidget(VisitVitalSignsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialVitalSigns != widget.initialVitalSigns) {
      _temperatureController.text = widget.initialVitalSigns.temperature?.toString() ?? '';
      _heartRateController.text = widget.initialVitalSigns.heartRate?.toString() ?? '';
      _respiratoryRateController.text = widget.initialVitalSigns.respiratoryRate?.toString() ?? '';
      _systolicBPController.text = widget.initialVitalSigns.systolicBP?.toString() ?? '';
      _diastolicBPController.text = widget.initialVitalSigns.diastolicBP?.toString() ?? '';
      _oxygenSaturationController.text = widget.initialVitalSigns.oxygenSaturation?.toString() ?? '';
      _notesController.text = widget.initialVitalSigns.notes ?? '';
    }
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _heartRateController.dispose();
    _respiratoryRateController.dispose();
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    _oxygenSaturationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateVitalSigns() {
    double? temperature;
    int? heartRate;
    int? respiratoryRate;
    int? systolicBP;
    int? diastolicBP;
    int? oxygenSaturation;

    if (_temperatureController.text.isNotEmpty) {
      temperature = double.tryParse(_temperatureController.text);
    }
    if (_heartRateController.text.isNotEmpty) {
      heartRate = int.tryParse(_heartRateController.text);
    }
    if (_respiratoryRateController.text.isNotEmpty) {
      respiratoryRate = int.tryParse(_respiratoryRateController.text);
    }
    if (_systolicBPController.text.isNotEmpty) {
      systolicBP = int.tryParse(_systolicBPController.text);
    }
    if (_diastolicBPController.text.isNotEmpty) {
      diastolicBP = int.tryParse(_diastolicBPController.text);
    }
    if (_oxygenSaturationController.text.isNotEmpty) {
      oxygenSaturation = int.tryParse(_oxygenSaturationController.text);
    }

    final vitalSigns = VitalSigns(
      temperature: temperature,
      heartRate: heartRate,
      respiratoryRate: respiratoryRate,
      systolicBP: systolicBP,
      diastolicBP: diastolicBP,
      oxygenSaturation: oxygenSaturation,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    widget.onChanged(vitalSigns);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildVitalSignField(
                label: 'Temperature (°C)',
                controller: _temperatureController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                suffix: '°C',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}$')),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildVitalSignField(
                label: 'Heart Rate (bpm)',
                controller: _heartRateController,
                keyboardType: TextInputType.number,
                suffix: 'bpm',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildVitalSignField(
                label: 'Respiratory Rate',
                controller: _respiratoryRateController,
                keyboardType: TextInputType.number,
                suffix: '/min',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildVitalSignField(
                label: 'O₂ Saturation',
                controller: _oxygenSaturationController,
                keyboardType: TextInputType.number,
                suffix: '%',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _MaxValueTextInputFormatter(100),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildVitalSignField(
                label: 'Systolic BP',
                controller: _systolicBPController,
                keyboardType: TextInputType.number,
                suffix: 'mmHg',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildVitalSignField(
                label: 'Diastolic BP',
                controller: _diastolicBPController,
                keyboardType: TextInputType.number,
                suffix: 'mmHg',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          maxLines: 2,
          onChanged: (_) => _updateVitalSigns(),
        ),
      ],
    );
  }

  Widget _buildVitalSignField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    String? suffix,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        suffixText: suffix,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: (_) => _updateVitalSigns(),
    );
  }
}

// Custom input formatter to limit values to a maximum
class _MaxValueTextInputFormatter extends TextInputFormatter {
  final int maxValue;

  _MaxValueTextInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final int? value = int.tryParse(newValue.text);
    if (value == null) {
      return oldValue;
    }
    
    if (value > maxValue) {
      return TextEditingValue(
        text: maxValue.toString(),
        selection: TextSelection.collapsed(offset: maxValue.toString().length),
      );
    }
    
    return newValue;
  }
}
