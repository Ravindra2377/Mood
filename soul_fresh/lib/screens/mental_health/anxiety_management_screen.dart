import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul/config/app_colors.dart';

// Providers
final anxietyLogsProvider = StateProvider<List<AnxietyLog>>((ref) => []);

final copingStrategiesProvider =
    StateProvider<List<CopingStrategy>>((ref) => []);

final safetyPlanProvider = StateProvider<SafetyPlan?>((ref) => null);

class AnxietyLog {
  final int id;
  final int intensity;
  final String trigger;
  final String? copingTechnique;
  final DateTime date;
  final String? notes;

  AnxietyLog({
    required this.id,
    required this.intensity,
    required this.trigger,
    this.copingTechnique,
    required this.date,
    this.notes,
  });
}

class CopingStrategy {
  final int id;
  final String name;
  final String description;
  final String icon;
  final bool used;

  CopingStrategy({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.used,
  });
}

class SafetyPlan {
  final int id;
  final String warningSign;
  final List<String> copingSkills;
  final List<String> supportPeople;
  final String crisisNumber;
  final String crisisService;

  SafetyPlan({
    required this.id,
    required this.warningSign,
    required this.copingSkills,
    required this.supportPeople,
    required this.crisisNumber,
    required this.crisisService,
  });
}

class AnxietyManagementScreen extends ConsumerStatefulWidget {
  const AnxietyManagementScreen({super.key});

  @override
  ConsumerState<AnxietyManagementScreen> createState() =>
      _AnxietyManagementScreenState();
}

class _AnxietyManagementScreenState
    extends ConsumerState<AnxietyManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: const Text(
          'Anxiety Management',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00D2D3),
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: const Color(0xFF00D2D3),
          tabs: const [
            Tab(icon: Icon(Icons.track_changes), text: 'Track'),
            Tab(icon: Icon(Icons.psychology), text: 'Coping'),
            Tab(icon: Icon(Icons.security), text: 'Safety'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrack(),
          _buildCoping(),
          _buildSafetyPlan(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00D2D3),
        onPressed: () => _showSOS(context),
        tooltip: 'Emergency SOS',
        child: const Icon(Icons.emergency),
      ),
    );
  }

  Widget _buildTrack() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Anxiety Intensity Logger
          _AnxietyIntensityCard(
            onLog: (intensity, trigger, coping) {
              // Log anxiety
            },
          ),
          const SizedBox(height: 24),

          // Recent Logs
          Text(
            'Recent Episodes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            itemBuilder: (context, index) {
              final intensities = [8, 6, 4, 7, 5, 3];
              final triggers = [
                'Work deadline',
                'Social gathering',
                'Financial worries',
                'Health concern',
                'Traffic',
                'Crowded place',
              ];
              final copingUsed = [
                'Deep breathing',
                'Exercise',
                'Journaling',
                'Meditation',
                'Music',
                'None',
              ];

              return _AnxietyLogCard(
                intensity: intensities[index],
                trigger: triggers[index],
                copingUsed: copingUsed[index],
                date: DateTime.now().subtract(Duration(hours: index * 4)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCoping() {
    final strategies = [
      {
        'name': '4-7-8 Breathing',
        'description': 'Breathe in for 4, hold for 7, exhale for 8',
        'icon': 'ðŸ’¨',
      },
      {
        'name': 'Progressive Relaxation',
        'description': 'Tense and release each muscle group',
        'icon': 'ðŸ§˜',
      },
      {
        'name': 'Grounding (5-4-3-2-1)',
        'description': 'Notice 5 sights, 4 sounds, 3 touches...',
        'icon': 'ðŸŒ',
      },
      {
        'name': 'Cold Water',
        'description': 'Splash cold water on face to activate calm',
        'icon': 'ðŸ’§',
      },
      {
        'name': 'Physical Activity',
        'description': 'Walk, run, or exercise to burn adrenaline',
        'icon': 'ðŸƒ',
      },
      {
        'name': 'Journaling',
        'description': 'Write down thoughts and feelings',
        'icon': 'ðŸ“',
      },
      {
        'name': 'Positive Affirmations',
        'description': 'Remind yourself of your strength',
        'icon': 'âœ¨',
      },
      {
        'name': 'Self-Compassion',
        'description': 'Treat yourself with kindness',
        'icon': 'ðŸ’—',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: strategies.length,
            itemBuilder: (context, index) {
              final strategy = strategies[index];
              return GestureDetector(
                onTap: () => _showStrategyDetail(context, strategy),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strategy['icon'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strategy['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            strategy['description'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.secondaryText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF00D2D3).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Try Now',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00D2D3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyPlan() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency Contacts
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emergency, color: Colors.red),
                    const SizedBox(width: 12),
                    Text(
                      'Emergency Contacts',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _ContactTile(
                  label: 'Crisis Text Line',
                  value: 'Text HOME to 741741',
                  icon: 'ðŸ’¬',
                ),
                const SizedBox(height: 12),
                const _ContactTile(
                  label: 'National Suicide Prevention',
                  value: '988 (call or text)',
                  icon: 'ðŸ“ž',
                ),
                const SizedBox(height: 12),
                const _ContactTile(
                  label: 'Emergency Services',
                  value: '911',
                  icon: 'ðŸš‘',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Warning Signs
          Text(
            'My Warning Signs',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: const Text(
              'I notice my anxiety is escalating when:\n'
              'â€¢ I start avoiding situations\n'
              'â€¢ My sleep becomes irregular\n'
              'â€¢ I feel tension in my chest\n'
              'â€¢ I catastrophize about the future',
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
          ),
          const SizedBox(height: 24),

          // Coping Skills
          Text(
            'My Coping Skills',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...[
            'âœ“ Deep breathing exercises',
            'âœ“ Go for a walk in nature',
            'âœ“ Call a trusted friend',
            'âœ“ Practice grounding techniques',
            'âœ“ Listen to calming music',
          ].map((skill) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // Support People
          Text(
            'People I Can Reach Out To',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...[
            {'name': 'Mom', 'number': '555-0101'},
            {'name': 'Best Friend Sarah', 'number': '555-0102'},
            {'name': 'Therapist', 'number': '555-0103'},
          ].map((person) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          person['number'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.call),
                          onPressed: () {},
                          iconSize: 20,
                        ),
                        IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {},
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // Edit Safety Plan Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFF00D2D3),
                  width: 2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Edit Safety Plan'),
            ),
          ),
        ],
      ),
    );
  }

  void _showStrategyDetail(
    BuildContext context,
    Map<String, dynamic> strategy,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  strategy['icon'] as String,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strategy['name'] as String,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              strategy['description'] as String,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D2D3),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Start Practice Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSOS(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.emergency, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Emergency Support',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Call 911',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Text Crisis Line (741741)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D2D3),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Use Grounding Technique',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnxietyIntensityCard extends StatefulWidget {
  final Function(int, String, String) onLog;

  const _AnxietyIntensityCard({required this.onLog});

  @override
  State<_AnxietyIntensityCard> createState() => _AnxietyIntensityCardState();
}

class _AnxietyIntensityCardState extends State<_AnxietyIntensityCard> {
  int intensity = 5;
  String trigger = '';
  String copingTechnique = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00D2D3).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00D2D3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Log Anxiety Episode',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),

          // Intensity Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Intensity Level',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '$intensity/10',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00D2D3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: intensity.toDouble(),
                max: 10,
                divisions: 10,
                onChanged: (value) => setState(() => intensity = value.toInt()),
                activeColor: const Color(0xFF00D2D3),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Trigger Input
          TextField(
            decoration: InputDecoration(
              hintText: 'What triggered this?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => setState(() => trigger = value),
          ),
          const SizedBox(height: 12),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  widget.onLog(intensity, trigger, copingTechnique),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D2D3),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Log Episode'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnxietyLogCard extends StatelessWidget {
  final int intensity;
  final String trigger;
  final String copingUsed;
  final DateTime date;

  const _AnxietyLogCard({
    required this.intensity,
    required this.trigger,
    required this.copingUsed,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trigger,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: intensity > 6
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$intensity/10',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: intensity > 6 ? Colors.red : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                copingUsed,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF00D2D3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _ContactTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$icon $label',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
        const Icon(Icons.arrow_forward, size: 18),
      ],
    );
  }
}
