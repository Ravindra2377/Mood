import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul/config/app_colors.dart';

// Providers
final dailyCheckinProvider = StateProvider<List<DailyCheckin>>((ref) => []);

final wellnessScoreProvider = StateProvider<WellnessScore?>((ref) => null);

final goalsProvider = StateProvider<List<WellnessGoal>>((ref) => []);

class DailyCheckin {
  final int id;
  final int mood;
  final int energy;
  final int stress;
  final String sleep;
  final List<String> activities;
  final String? notes;
  final DateTime date;

  DailyCheckin({
    required this.id,
    required this.mood,
    required this.energy,
    required this.stress,
    required this.sleep,
    required this.activities,
    this.notes,
    required this.date,
  });
}

class WellnessScore {
  final double overallScore;
  final double moodScore;
  final double energyScore;
  final double stressScore;
  final double sleepScore;
  final String trend;

  WellnessScore({
    required this.overallScore,
    required this.moodScore,
    required this.energyScore,
    required this.stressScore,
    required this.sleepScore,
    required this.trend,
  });
}

class WellnessGoal {
  final int id;
  final String title;
  final String category;
  final int progressPercent;
  final String frequency;
  final bool completed;

  WellnessGoal({
    required this.id,
    required this.title,
    required this.category,
    required this.progressPercent,
    required this.frequency,
    required this.completed,
  });
}

class WellnessScreen extends ConsumerStatefulWidget {
  const WellnessScreen({super.key});

  @override
  ConsumerState<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends ConsumerState<WellnessScreen>
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
          'Wellness Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFFB347),
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: const Color(0xFFFFB347),
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Today'),
            Tab(icon: Icon(Icons.trending_up), text: 'Scores'),
            Tab(icon: Icon(Icons.flag), text: 'Goals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildToday(),
          _buildScores(),
          _buildGoals(),
        ],
      ),
    );
  }

  Widget _buildToday() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Check-in Card
          _DailyCheckinCard(
            onSubmit: (mood, energy, stress, sleep, activities) {
              // Submit check-in
            },
          ),
          const SizedBox(height: 24),

          // Today's Wellness Summary
          Text(
            'Today\'s Wellness',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: const [
              _WellnessMetricCard(
                icon: 'ðŸ˜Š',
                label: 'Mood',
                value: '7/10',
                color: Colors.yellow,
              ),
              _WellnessMetricCard(
                icon: 'âš¡',
                label: 'Energy',
                value: '6/10',
                color: Color(0xFFFFB347),
              ),
              _WellnessMetricCard(
                icon: 'ðŸ˜°',
                label: 'Stress',
                value: '4/10',
                color: Colors.blue,
              ),
              _WellnessMetricCard(
                icon: 'ðŸ˜´',
                label: 'Sleep',
                value: '7.5h',
                color: Color(0xFF6C5CE7),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Activities Today
          Text(
            'Activities Completed',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'ðŸ§˜ Meditation',
              'ðŸš´ Exercise',
              'ðŸ’§ Hydration',
              'ðŸ“š Reading',
              'ðŸ‘¥ Social Time',
            ].map((activity) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB347).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFB347)),
                ),
                child: Text(
                  activity,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScores() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Wellness Score
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFB347), Color(0xFFFFA94D)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Overall Wellness Score',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '78',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/100',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 0.78,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ðŸ“ˆ Up 5 points',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'vs last week',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Individual Scores
          Text(
            'Category Scores',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...[
            {'label': 'Mood', 'score': 8, 'icon': 'ðŸ˜Š'},
            {'label': 'Energy', 'score': 7, 'icon': 'âš¡'},
            {'label': 'Stress', 'score': 6, 'icon': 'ðŸ˜°'},
            {'label': 'Sleep', 'score': 8, 'icon': 'ðŸ˜´'},
            {'label': 'Social', 'score': 7, 'icon': 'ðŸ‘¥'},
          ].map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                    Row(
                      children: [
                        Text(
                          item['icon'] as String,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['label'] as String,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: 100,
                              child: LinearProgressIndicator(
                                value: (item['score'] as int) / 10,
                                backgroundColor: AppColors.borderColor,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFFB347),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '${item['score']}/10',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB347),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // Weekly Trend
          Text(
            'Weekly Trend',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .asMap()
                      .entries
                      .map((e) {
                    final scores = [75, 72, 78, 76, 79, 80, 78];
                    return Column(
                      children: [
                        Text(
                          e.value,
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 12,
                          height: 60,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFFB347).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 12,
                              height: (scores[e.key] / 100) * 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB347),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoals() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal Progress Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('ðŸ“Š', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 8),
                    Text(
                      '7 goals',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'this month',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: AppColors.borderColor,
                ),
                Column(
                  children: [
                    const Text('âœ…', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 8),
                    Text(
                      '5 completed',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Text(
                      '71% complete',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFB347),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Active Goals
          Text(
            'Active Goals',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...[
            {
              'title': 'Meditate Daily',
              'category': 'Mindfulness',
              'progress': 85,
              'frequency': '7/7 days',
              'icon': 'ðŸ§˜',
            },
            {
              'title': 'Exercise 30 mins',
              'category': 'Fitness',
              'progress': 60,
              'frequency': '3/5 times',
              'icon': 'ðŸƒ',
            },
            {
              'title': 'Sleep 7+ hours',
              'category': 'Sleep',
              'progress': 71,
              'frequency': '5/7 nights',
              'icon': 'ðŸ˜´',
            },
            {
              'title': 'Stress Check-in',
              'category': 'Mental Health',
              'progress': 100,
              'frequency': '7/7 days',
              'icon': 'âœ¨',
            },
            {
              'title': 'Hydration Goal',
              'category': 'Wellness',
              'progress': 65,
              'frequency': '4/7 days',
              'icon': 'ðŸ’§',
            },
          ].map((goal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
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
                        Row(
                          children: [
                            Text(
                              goal['icon'] as String,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal['title'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  goal['category'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '${goal['progress']}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFB347),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (goal['progress'] as int) / 100,
                      backgroundColor: AppColors.borderColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFB347),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      goal['frequency'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // Add Goal Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFFFFB347),
                  width: 2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('+ Add New Goal'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyCheckinCard extends StatefulWidget {
  final Function(int, int, int, String, List<String>) onSubmit;

  const _DailyCheckinCard({required this.onSubmit});

  @override
  State<_DailyCheckinCard> createState() => _DailyCheckinCardState();
}

class _DailyCheckinCardState extends State<_DailyCheckinCard> {
  int mood = 5;
  int energy = 5;
  int stress = 5;
  String sleep = '';
  Set<String> selectedActivities = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB347).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB347),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Check-in',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),

          // Mood
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'How\'s your mood?',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '$mood/10',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: mood.toDouble(),
            max: 10,
            divisions: 10,
            onChanged: (value) => setState(() => mood = value.toInt()),
            activeColor: const Color(0xFFFFB347),
          ),
          const SizedBox(height: 16),

          // Energy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Energy level?',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '$energy/10',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: energy.toDouble(),
            max: 10,
            divisions: 10,
            onChanged: (value) => setState(() => energy = value.toInt()),
            activeColor: const Color(0xFFFFB347),
          ),
          const SizedBox(height: 16),

          // Stress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stress level?',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '$stress/10',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: stress.toDouble(),
            max: 10,
            divisions: 10,
            onChanged: (value) => setState(() => stress = value.toInt()),
            activeColor: const Color(0xFFFFB347),
          ),
          const SizedBox(height: 16),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSubmit(
                mood,
                energy,
                stress,
                sleep,
                selectedActivities.toList(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB347),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Submit Check-in'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WellnessMetricCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _WellnessMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

