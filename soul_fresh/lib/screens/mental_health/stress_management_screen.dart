import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul/config/app_colors.dart';
import 'package:soul/models/mental_health_models.dart';

// Provider for stress logs
final stressLogsProvider =
    StateProvider<List<StressLog>>((ref) => []);

final stressAnalyticsProvider =
    StateProvider<StressAnalytics?>((ref) => null);

class StressLog {
  final int id;
  final int level;
  final List<String> triggers;
  final String? notes;
  final DateTime timestamp;

  StressLog({
    required this.id,
    required this.level,
    required this.triggers,
    this.notes,
    required this.timestamp,
  });
}

class StressAnalytics {
  final double averageLevel;
  final String trend;
  final List<Map<String, dynamic>> topTriggers;
  final List<Map<String, dynamic>> effectiveExercises;

  StressAnalytics({
    required this.averageLevel,
    required this.trend,
    required this.topTriggers,
    required this.effectiveExercises,
  });
}

class StressManagementScreen extends ConsumerStatefulWidget {
  const StressManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StressManagementScreen> createState() =>
      _StressManagementScreenState();
}

class _StressManagementScreenState
    extends ConsumerState<StressManagementScreen>
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
          'Stress Management',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF6B6B),
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: const Color(0xFFFF6B6B),
          tabs: const [
            Tab(icon: Icon(Icons.trending_up), text: 'Track'),
            Tab(icon: Icon(Icons.spa), text: 'Exercises'),
            Tab(icon: Icon(Icons.insights), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStressTracker(),
          _buildExercises(),
          _buildAnalytics(),
        ],
      ),
    );
  }

  Widget _buildStressTracker() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stress Level Card
          _StressLevelCard(onLevelSelected: (level) {
            // Log stress
          }),
          const SizedBox(height: 20),
          
          // Recent Logs
          Text(
            'Recent Stress Logs',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _StressLogCard(
                level: 7 - index,
                triggers: ['work', 'family'],
                time: DateTime.now().subtract(Duration(hours: index)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExercises() {
    final exercises = [
      {
        'name': '4-7-8 Breathing',
        'description': 'Calm your nervous system with controlled breathing',
        'duration': '5 min',
        'icon': '🫁',
        'color': const Color(0xFFFF6B6B),
      },
      {
        'name': 'Progressive Muscle Relaxation',
        'description': 'Release tension by tensing and relaxing muscle groups',
        'duration': '10 min',
        'icon': '💪',
        'color': const Color(0xFFFF8C8C),
      },
      {
        'name': 'Box Breathing',
        'description': '4-4-4-4 pattern for immediate calm',
        'duration': '3 min',
        'icon': '📦',
        'color': const Color(0xFFFFA9A9),
      },
      {
        'name': 'Stress Relief Meditation',
        'description': 'Guided meditation for stress relief',
        'duration': '7 min',
        'icon': '🧘',
        'color': const Color(0xFFFFBFC0),
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: exercises.map((ex) {
          return _ExerciseCard(
            name: ex['name'] as String,
            description: ex['description'] as String,
            duration: ex['duration'] as String,
            icon: ex['icon'] as String,
            color: ex['color'] as Color,
            onTap: () {
              _showExerciseDetail(context, ex);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Average
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF6B6B),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Average',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '6.2',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: const Color(0xFFFF6B6B),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_down,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Decreasing',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Top Triggers
          Text(
            'Top Stress Triggers',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...[
            {'trigger': 'Work', 'count': 12},
            {'trigger': 'Family', 'count': 8},
            {'trigger': 'Sleep', 'count': 5},
          ].map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['trigger'] as String),
                  Chip(label: Text('${item['count']}x')),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 20),

          // Effective Exercises
          Text(
            'Most Effective Exercises',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...[
            {'exercise': '4-7-8 Breathing', 'score': 4.5},
            {'exercise': 'Box Breathing', 'score': 4.2},
            {'exercise': 'Progressive Relaxation', 'score': 4.0},
          ].map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['exercise'] as String),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          color: i < (item['score'] as double).toInt()
                              ? Colors.amber
                              : Colors.grey,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showExerciseDetail(BuildContext context, Map<String, dynamic> exercise) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  exercise['icon'] as String,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise['name'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${exercise['duration']} • Stress Relief',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              exercise['description'] as String,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Start exercise
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Exercise'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: exercise['color'] as Color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StressLevelCard extends StatefulWidget {
  final Function(int) onLevelSelected;

  const _StressLevelCard({required this.onLevelSelected});

  @override
  State<_StressLevelCard> createState() => _StressLevelCardState();
}

class _StressLevelCardState extends State<_StressLevelCard> {
  int? selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How stressed are you right now?',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (i) {
              final level = i + 1;
              final isSelected = selectedLevel == level;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedLevel = level);
                  widget.onLevelSelected(level);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30,
                  height: isSelected ? 40 : 30,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFFFF6B6B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '$level',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Calm', style: TextStyle(fontSize: 12)),
              Text('Very Stressed', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StressLogCard extends StatelessWidget {
  final int level;
  final List<String> triggers;
  final DateTime time;

  const _StressLogCard({
    required this.level,
    required this.triggers,
    required this.time,
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$level',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stress Level: $level/10',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: triggers.map((t) {
                    return Chip(
                      label: Text(t),
                      labelStyle: const TextStyle(fontSize: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String name;
  final String description;
  final String duration;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.name,
    required this.description,
    required this.duration,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1),
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
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: color),
          ],
        ),
      ),
    );
  }
}
