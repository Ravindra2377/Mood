/// Crisis response dialog widget.
/// Displays emergency resources and immediate action steps.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:soul/models/chat_models.dart';

class CrisisDialog extends StatelessWidget {
  final CrisisResponse crisis;
  final VoidCallback onDismiss;

  const CrisisDialog({
    Key? key,
    required this.crisis,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.shade50,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with emergency icon
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.shade100,
                      ),
                      child: const Center(
                        child: Text('🆘', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Crisis Support',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Message
                Text(
                  crisis.message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade800,
                      ),
                ),

                const SizedBox(height: 24),

                // Emergency contacts
                Text(
                  'Immediate Resources:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 12),

                // 988 Suicide Prevention Lifeline
                _buildContactCard(
                  context,
                  icon: '📞',
                  title: '988 Suicide & Crisis Lifeline',
                  subtitle: 'Call 988 • Available 24/7',
                  onTap: () => _launchPhone('988'),
                ),

                const SizedBox(height: 12),

                // Crisis Text Line
                _buildContactCard(
                  context,
                  icon: '💬',
                  title: 'Crisis Text Line',
                  subtitle: 'Text HOME to 741741',
                  onTap: () => _launchSms('741741', 'HOME'),
                ),

                const SizedBox(height: 12),

                // Emergency Services
                _buildContactCard(
                  context,
                  icon: '🚨',
                  title: 'Emergency Services',
                  subtitle: 'Call 911 for immediate danger',
                  onTap: () => _launchPhone('911'),
                  isEmergency: true,
                ),

                const SizedBox(height: 24),

                // Immediate actions
                Text(
                  'What you can do now:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 12),

                ...crisis.immediateActions.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: const Center(
                            child: Text('✓',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            action,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Disclaimer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    'If you\'re in immediate danger, please call 911 or go to your nearest emergency room. '
                    'SOUL AI cannot replace emergency medical services.',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),

                const SizedBox(height: 24),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'I\'m Reaching Out for Help',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isEmergency = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEmergency ? Colors.red.shade50 : Colors.white,
          border: Border.all(
            color: isEmergency ? Colors.red.shade200 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhone(String number) async {
    final url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchSms(String number, String message) async {
    final url = Uri.parse('sms:$number?body=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
