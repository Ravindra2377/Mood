import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul/config/app_colors.dart';

// Providers
final sleepLogsProvider =
    StateProvider<List<SleepLog>>((ref) => []);

final sleepAnalyticsProvider =
    StateProvider<SleepAnalytics?>((ref) => null);

class SleepLog {
  final int id;
  final DateTime bedtime;
  final DateTime wakeTime;
  final double durationHours;
  final int qualityRating;
  final String? notes;

  SleepLog({
    required this.id,
    required this.bedtime,
    required this.wakeTime,
    required this.durationHours,
    required this.qualityRating,
    this.notes,
  });
}

class SleepAnalytics {
  final double averageDuration;
  final double averageQuality;
  final String trend;
  final double sleepDebt;
  final List<Map<String, dynamic>> factors;

  SleepAnalytics({
    required this.averageDuration,
    required this.averageQuality,
    required this.trend,
    required this.sleepDebt,
    required this.factors,
  });
}

class SleepTrackingScreen extends ConsumerStatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  ConsumerState<SleepTrackingScreen> createState() =>
      _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends ConsumerState<SleepTrackingScreen>
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
          'Sleep Tracking',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6C5CE7),
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: const Color(0xFF6C5CE7),
          tabs: const [
            Tab(icon: Icon(Icons.bedtime), text: 'Log'),
            Tab(icon: Icon(Icons.show_chart), text: 'Analytics'),
            Tab(icon: Icon(Icons.tips_and_updates), text: 'Tips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSleepLog(),
          _buildAnalytics(),
          _buildTips(),
        ],
      ),
    );
  }

  Widget _buildSleepLog() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Sleep Logger
          _SleepLogCard(onLogSleep: (bedtime, wakeTime, quality) {
            // Log sleep
          },),
          const SizedBox(height: 24),

          // Recent Logs
          Text(
            'Sleep History',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = DateTime.now().subtract(Duration(days: index));
              return _SleepHistoryCard(
                date: date,
                bedtime: '${(22 + index % 2)}:30',
                wakeTime: '${(6 + index % 2)}:30',
                duration: 7.5 + (index % 2),
                quality: 4 - (index % 2),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sleep Score
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6C5CE7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average Sleep Duration',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '7.2',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: const Color(0xFF6C5CE7),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'hours/night',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 0.72 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recommended: 7-9 hrs',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'On Track',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sleep Quality
          Text(
            'Average Sleep Quality',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                Icons.star,
                color: i < 4 ? Colors.amber : Colors.grey,
                size: 24,
              );
            }),
          ),
          const SizedBox(height: 20),

          // Sleep Debt
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange,
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sleep Debt: 2 hours\nYou\'re sleeping less than recommended.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Factors Affecting Sleep
          Text(
            'Factors Affecting Sleep',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...[
            {
              'factor': 'Caffeine After 2 PM',
              'impact': 'Negative',
              'score': -0.65,
            },
            {
              'factor': 'Evening Exercise',
              'impact': 'Negative',
              'score': -0.45,
            },
            {'factor': 'Reading Before Bed', 'impact': 'Positive', 'score': 0.72},
            {'factor': 'Regular Bedtime', 'impact': 'Positive', 'score': 0.85},
          ].map((item) {
            final isPositive = item['impact'] == 'Positive';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPositive ? Icons.thumb_up : Icons.thumb_down,
                          color: isPositive ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(item['factor'] as String),
                      ],
                    ),
                    Text(
                      '${((item['score'] as double).abs() * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTips() {
    final tips = [
      {
        'title': 'Maintain Consistent Sleep Schedule',
        'description': 'Go to bed and wake up at the same time daily',
        'icon': '⏰',
      },
      {
        'title': 'Avoid Caffeine After 2 PM',
        'description': 'Caffeine stays in your system for 6-8 hours',
        'icon': '☕',
      },
      {
        'title': 'Create a Bedtime Routine',
        'description': 'Wind down 30 minutes before bed with relaxing activities',
        'icon': '🧘',
      },
      {
        'title': 'Keep Room Cool & Dark',
        'description': 'Ideal sleep temperature is 65-68°F (18-20°C)',
        'icon': '🌙',
      },
      {
        'title': 'Limit Screen Time',
        'description': 'Stop using devices 1 hour before bedtime',
        'icon': '📱',
      },
      {
        'title': 'Exercise Regularly',
        'description': 'Exercise improves sleep quality (avoid late evening)',
        'icon': '🏃',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: tips.map((tip) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip['icon'] as String,
                    style: const TextStyle(fontSize: 24),),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip['description'] as String,
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
          );
        }).toList(),
      ),
    );
  }
}

class _SleepLogCard extends StatefulWidget {
  final Function(DateTime, DateTime, int) onLogSleep;

  const _SleepLogCard({required this.onLogSleep});

  @override
  State<_SleepLogCard> createState() => _SleepLogCardState();
}

class _SleepLogCardState extends State<_SleepLogCard> {
  late TimeOfDay bedtime;
  late TimeOfDay wakeTime;
  int quality = 4;

  @override
  void initState() {
    super.initState();
    bedtime = const TimeOfDay(hour: 22, minute: 30);
    wakeTime = const TimeOfDay(hour: 6, minute: 30);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C5CE7).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6C5CE7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Log Last Night\'s Sleep',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),

          // Bedtime
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bedtime',
                      style: Theme.of(context).textTheme.bodySmall,),
                  const SizedBox(height: 4),
                  Text(
                    bedtime.format(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: bedtime,
                  );
                  if (time != null) {
                    setState(() => bedtime = time);
                  }
                },
                child: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Wake Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wake Time',
                      style: Theme.of(context).textTheme.bodySmall,),
                  const SizedBox(height: 4),
                  Text(
                    wakeTime.format(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: wakeTime,
                  );
                  if (time != null) {
                    setState(() => wakeTime = time);
                  }
                },
                child: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quality Rating
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sleep Quality',
                  style: Theme.of(context).textTheme.bodySmall,),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => quality = i + 1),
                    child: Icon(
                      Icons.star,
                      color: i < quality ? Colors.amber : Colors.grey,
                      size: 24,
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Convert TimeOfDay to DateTime
                final now = DateTime.now();
                final bedtimeDateTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  bedtime.hour,
                  bedtime.minute,
                );
                final wakeTimeDateTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  wakeTime.hour,
                  wakeTime.minute,
                );

                widget.onLogSleep(bedtimeDateTime, wakeTimeDateTime, quality);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Log Sleep'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepHistoryCard extends StatelessWidget {
  final DateTime date;
  final String bedtime;
  final String wakeTime;
  final double duration;
  final int quality;

  const _SleepHistoryCard({
    required this.date,
    required this.bedtime,
    required this.wakeTime,
    required this.duration,
    required this.quality,
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
                '${date.month}/${date.day}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    Icons.star,
                    color: i < quality ? Colors.amber : Colors.grey,
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$bedtime - $wakeTime',
                  style: const TextStyle(fontSize: 12),),
              Text(
                '${duration.toStringAsFixed(1)} hrs',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C5CE7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
