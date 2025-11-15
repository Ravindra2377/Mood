import 'package:flutter/material.dart';

class TherapyToolboxCard extends StatelessWidget {
  const TherapyToolboxCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ToolboxSection(
          title: 'CBT Tools',
          subtitle: 'Challenge thoughts and build helpful habits.',
          color: Colors.blue,
          icon: '✍️',
          tools: [
            'Thought Record • Capture and reframe anxious thinking.',
            'Behavioral Experiments • Test beliefs with real-world actions.',
            'Mood Chart • Spot your emotional patterns quickly.',
          ],
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ToolboxSection(
          title: 'DBT Skills',
          subtitle: 'Regulate emotions and navigate crises.',
          color: Colors.orange,
          icon: '∞',
          tools: [
            'TIPP Skills • Cool your body to calm your mind fast.',
            'Opposite Action • Shift your behavior to move emotions.',
            'Wise Mind • Find balance between logic and emotion.',
          ],
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ToolboxSection(
          title: 'ACT Guide',
          subtitle: 'Live by your values with acceptance.',
          color: Colors.teal,
          icon: '✨',
          tools: [
            'Values Map • Name what matters most right now.',
            'Defusion Practices • Unhook from intrusive thoughts.',
            'Committed Action • Plan one value-based action today.',
          ],
          onTap: () {},
        ),
      ],
    );
  }
}

class _ToolboxSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final String icon;
  final List<String> tools;
  final VoidCallback onTap;

  const _ToolboxSection({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.tools,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tools.map((tool) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: color.withOpacity(0.6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tool,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
              ),
              child: Text(
                'Open tools',
                style: TextStyle(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}