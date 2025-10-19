import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul_fresh/config/app_colors.dart';

// Providers
final moodEntriesProvider =
    StateProvider<List<MoodEntry>>((ref) => []);

final moodInsightsProvider =
    StateProvider<MoodInsights?>((ref) => null);

class MoodEntry {
  final int id;
  final int mood;
  final String? activity;
  final DateTime timestamp;
  final String? notes;

  MoodEntry({
    required this.id,
    required this.mood,
    this.activity,
    required this.timestamp,
    this.notes,
  });
}

class MoodInsights {
  final double averageMood;
  final String trend;
  final List<Map<String, dynamic>> topActivities;
  final List<Map<String, dynamic>> triggers;

  MoodInsights({
    required this.averageMood,
    required this.trend,
    required this.topActivities,
    required this.triggers,
  });
}

class MoodTrackingScreen extends ConsumerStatefulWidget {
  const MoodTrackingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MoodTrackingScreen> createState() =>
      _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends ConsumerState<MoodTrackingScreen>
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
          'Mood Tracking',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFFD93D),
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: const Color(0xFFFFD93D),
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Today'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendar'),
            Tab(icon: Icon(Icons.analytics), text: 'Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayView(),
          _buildCalendarView(),
          _buildInsightsView(),
        ],
      ),
    );
  }

  Widget _buildTodayView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Mood Selector
          _MoodSelector(onMoodSelected: (mood) {
            // Save mood
          }),
          const SizedBox(height: 24),

          // Activities
          Text(
            'Mood Boosting Activities',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _ActivityGrid(),
          const SizedBox(height: 24),

          // Gratitude
          Text(
            'Today\'s Gratitude',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'What are you grateful for today?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.cardColor,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD93D),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Save Gratitude Entry',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Entries
          Text(
            'Today\'s Mood History',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return _MoodEntryCard(
                mood: 7 + (index % 2),
                time: DateTime.now().subtract(Duration(hours: index * 2)),
                activity: index == 0 ? 'Exercise' : 'Reading',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('October 2025',
                        style: Theme.of(context).textTheme.titleSmall),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.chevron_left),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Day headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                      .map((day) => Text(
                            day,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                // Calendar days
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: 35,
                  itemBuilder: (context, index) {
                    final day = index + 1 - 2; // Adjust for week start
                    final isCurrentMonth = day > 0 && day <= 31;

                    return Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isCurrentMonth
                            ? (day % 3 == 0
                                ? const Color(0xFFFFD93D).withOpacity(0.3)
                                : AppColors.backgroundColor)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: isCurrentMonth && day % 3 == 0
                            ? Border.all(
                                color: const Color(0xFFFFD93D),
                                width: 1,
                              )
                            : null,
                      ),
                      child: isCurrentMonth
                          ? Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: day % 3 == 0
                                      ? const Color(0xFFFFD93D)
                                      : AppColors.textColor,
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CalendarLegend(
                color: const Color(0xFFFFD93D),
                label: 'Tracked',
              ),
              _CalendarLegend(
                color: AppColors.backgroundColor,
                label: 'Not Tracked',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mood Trend
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD93D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD93D),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Average Mood',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '7.3',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: const Color(0xFFFFD93D),
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
                          const Icon(Icons.trending_up,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Improving',
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

          // Top Activities
          Text(
            'Top Mood Boosters',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...[
            {'activity': 'Exercise', 'score': 4.8, 'uses': 12},
            {'activity': 'Time with Friends', 'score': 4.6, 'uses': 8},
            {'activity': 'Reading', 'score': 4.3, 'uses': 6},
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['activity'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Used ${item['uses']} times',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          color: i <
                                  (item['score'] as double).toStringAsFixed(1)[0]
                                      .codeUnitAt(0) -
                                      48
                              ? const Color(0xFFFFD93D)
                              : Colors.grey,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 20),

          // Mood Factors
          Text(
            'What Affects Your Mood',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...[
            {'factor': 'Good Sleep', 'impact': 'Positive', 'score': 0.85},
            {'factor': 'Exercise', 'impact': 'Positive', 'score': 0.78},
            {'factor': 'Stress', 'impact': 'Negative', 'score': -0.92},
          ].map((item) {
            final isPositive = item['impact'] == 'Positive';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _MoodSelector extends StatefulWidget {
  final Function(int) onMoodSelected;

  const _MoodSelector({required this.onMoodSelected});

  @override
  State<_MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<_MoodSelector> {
  int? selectedMood;

  @override
  Widget build(BuildContext context) {
    final moods = [
      {'emoji': '😢', 'label': 'Terrible', 'value': 1},
      {'emoji': '😞', 'label': 'Bad', 'value': 2},
      {'emoji': '😐', 'label': 'Okay', 'value': 3},
      {'emoji': '🙂', 'label': 'Good', 'value': 4},
      {'emoji': '😄', 'label': 'Great', 'value': 5},
      {'emoji': '😄', 'label': 'Amazing', 'value': 6},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD93D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD93D),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today?',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: moods.map((mood) {
              final isSelected = selectedMood == mood['value'];
              return GestureDetector(
                onTap: () {
                  setState(() => selectedMood = mood['value'] as int);
                  widget.onMoodSelected(mood['value'] as int);
                },
                child: AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Text(
                        mood['emoji'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFFFFD93D)
                              : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ActivityGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activities = [
      {'name': 'Exercise', 'emoji': '🏃', 'color': Color(0xFF00B894)},
      {'name': 'Time Out', 'emoji': '🌳', 'color': Color(0xFF00B894)},
      {'name': 'Social', 'emoji': '👥', 'color': Color(0xFF00B894)},
      {'name': 'Reading', 'emoji': '📚', 'color': Color(0xFF00B894)},
      {'name': 'Music', 'emoji': '🎵', 'color': Color(0xFF00B894)},
      {'name': 'Creative', 'emoji': '🎨', 'color': Color(0xFF00B894)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return GestureDetector(
          onTap: () {
            // Log activity
          },
          child: Container(
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: activity['color'] as Color,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(activity['emoji'] as String,
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  activity['name'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MoodEntryCard extends StatelessWidget {
  final int mood;
  final DateTime time;
  final String? activity;

  const _MoodEntryCard({
    required this.mood,
    required this.time,
    this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final moodEmoji =
        ['😢', '😞', '😐', '🙂', '😄', '😄'][(mood - 1).clamp(0, 5)];

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
          Text(moodEmoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mood: $mood/10',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (activity != null)
                  Text(
                    'Activity: $activity',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _CalendarLegend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
