import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  static const String route = '/privacy-settings';
  
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _shareAnalytics = true;
  bool _personalizedContent = true;
  bool _dataSyncEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Control how your data is used and shared',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          
          // Data Collection
          _buildSectionHeader('Data Collection'),
          SwitchListTile(
            title: const Text('Share Anonymous Analytics'),
            subtitle: const Text('Help us improve the app'),
            value: _shareAnalytics,
            onChanged: (value) => setState(() => _shareAnalytics = value),
          ),
          SwitchListTile(
            title: const Text('Personalized Content'),
            subtitle: const Text('Show recommendations based on your activity'),
            value: _personalizedContent,
            onChanged: (value) => setState(() => _personalizedContent = value),
          ),
          
          // Data Sync
          _buildSectionHeader('Data Sync'),
          SwitchListTile(
            title: const Text('Cloud Sync'),
            subtitle: const Text('Sync your data across devices'),
            value: _dataSyncEnabled,
            onChanged: (value) => setState(() => _dataSyncEnabled = value),
          ),
          
          // Data Management
          _buildSectionHeader('Data Management'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export My Data'),
            subtitle: const Text('Download all your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportData,
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('Delete All Data'),
            subtitle: const Text('Permanently remove all your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _deleteAllData,
          ),
          
          const Divider(height: 32),
          
          // Information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Privacy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your mental health data is encrypted and stored securely. '
                  'We never share your personal information with third parties '
                  'without your explicit consent.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy Policy - Coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Read Privacy Policy'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<void> _exportData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Your data will be exported as a JSON file. This may take a few moments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Export'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data export - Coming soon!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'Are you sure? This will permanently delete all your mood entries, '
          'journal entries, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delete all data - Coming soon!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
