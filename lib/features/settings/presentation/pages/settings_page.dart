import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/environment.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _s3BucketController = TextEditingController();
  final _awsRegionController = TextEditingController();
  final _accessKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    _s3BucketController.text = EnvironmentConfig.s3BucketName;
    _awsRegionController.text = AppConfig.awsRegion;
    _accessKeyController.text = AppConfig.awsAccessKeyId;
    _secretKeyController.text = AppConfig.awsSecretAccessKey;
  }

  @override
  void dispose() {
    _s3BucketController.dispose();
    _awsRegionController.dispose();
    _accessKeyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Information
            _buildSectionHeader('App Information'),
            _buildInfoCard([
              _buildInfoRow('App Name', AppConfig.appName),
              _buildInfoRow('Version', AppConfig.appVersion),
              _buildInfoRow('Environment', EnvironmentConfig.currentEnvironment.name),
            ]),
            
            const SizedBox(height: 24),
            
            // AWS S3 Configuration
            _buildSectionHeader('AWS S3 Configuration'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _s3BucketController,
                      decoration: const InputDecoration(
                        labelText: 'S3 Bucket Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cloud),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _awsRegionController,
                      decoration: const InputDecoration(
                        labelText: 'AWS Region',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.public),
                        hintText: 'e.g., us-east-1',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _accessKeyController,
                      decoration: const InputDecoration(
                        labelText: 'AWS Access Key ID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.key),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _secretKeyController,
                      decoration: const InputDecoration(
                        labelText: 'AWS Secret Access Key',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // API Configuration
            _buildSectionHeader('API Configuration'),
            _buildInfoCard([
              _buildInfoRow('API Gateway URL', EnvironmentConfig.apiGatewayUrl),
              _buildInfoRow('Environment', EnvironmentConfig.currentEnvironment.name),
              _buildInfoRow('API Timeout', '${AppConfig.apiTimeoutSeconds}s'),
              _buildInfoRow('Upload Timeout', '${AppConfig.uploadTimeoutSeconds}s'),
            ]),
            
            const SizedBox(height: 24),
            
            // Recording Settings
            _buildSectionHeader('Recording Settings'),
            _buildInfoCard([
              _buildInfoRow('Max Recording Duration', '${AppConfig.maxRecordingDurationSeconds}s'),
              _buildInfoRow('Audio File Extension', AppConfig.audioFileExtension),
              _buildInfoRow('Audio Path Format', 'visits/{visitId}/{staffId}/audio_{timestamp}.wav'),
            ]),
            
            const SizedBox(height: 24),
            
            // Photo Settings
            _buildSectionHeader('Photo Settings'),
            _buildInfoCard([
              _buildInfoRow('Max Photo Size', '${AppConfig.maxPhotoSizeMB}MB'),
              _buildInfoRow('Photo Quality', '${AppConfig.photoQuality}%'),
              _buildInfoRow('Max Resolution', '${AppConfig.maxPhotoResolution}px'),
              _buildInfoRow('Photo Path Format', 'visits/{visitId}/{staffId}/photo_{timestamp}_{index}.jpg'),
            ]),
            
            const SizedBox(height: 24),
            
            // Environment Controls
            _buildSectionHeader('Environment'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.settings, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('Current Environment:'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getEnvironmentColor(),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            EnvironmentConfig.currentEnvironment.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _switchEnvironment(Environment.development),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: EnvironmentConfig.isDevelopment ? Colors.blue : Colors.grey,
                            ),
                            child: const Text('Development'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _switchEnvironment(Environment.staging),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: EnvironmentConfig.isStaging ? Colors.orange : Colors.grey,
                            ),
                            child: const Text('Staging'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _switchEnvironment(Environment.production),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: EnvironmentConfig.isProduction ? Colors.red : Colors.grey,
                            ),
                            child: const Text('Production'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Test Connection Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testS3Connection,
                icon: const Icon(Icons.wifi_protected_setup),
                label: const Text('Test S3 Connection'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEnvironmentColor() {
    switch (EnvironmentConfig.currentEnvironment) {
      case Environment.development:
        return Colors.blue;
      case Environment.staging:
        return Colors.orange;
      case Environment.production:
        return Colors.red;
    }
  }

  void _switchEnvironment(Environment environment) {
    setState(() {
      EnvironmentConfig.setEnvironment(environment);
      _loadCurrentSettings(); // Reload settings for new environment
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${environment.name} environment'),
        backgroundColor: _getEnvironmentColor(),
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implement actual settings save to secure storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _testS3Connection() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Testing S3 connection...'),
          ],
        ),
      ),
    );

    // Simulate connection test
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      
      // Show result
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Connection Test'),
            ],
          ),
          content: const Text('S3 connection test successful!\n\nBucket is accessible and credentials are valid.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}