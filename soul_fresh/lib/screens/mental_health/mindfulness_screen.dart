import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul/config/app_colors.dart';

// Providers
final meditationSessionsProvider =
    StateProvider<List<MeditationSession>>((ref) => []);

final mindfulnessStatsProvider =
    StateProvider<MindfulnessStats?>((ref) => null);

final achievementsProvider = StateProvider<List<Achievement>>((ref) => []);

class MeditationSession {
  final int id;
  final String name;
  final int durationMinutes;
  final DateTime date;
  final String category;
  final int focusRating;

  MeditationSession({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.date,
    required this.category,
    required this.focusRating,
  });
}

class MindfulnessStats {
  final int totalSessions;
  final int totalMinutes;
  final int currentStreak;
  final int longestStreak;
  final double averageFocusRating;

  MindfulnessStats({
    required this.totalSessions,
    required this.totalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageFocusRating,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.unlockedDate,
  });
}

class MindfulnessScreen extends ConsumerStatefulWidget {
  const MindfulnessScreen({super.key});

  @override
  ConsumerState<MindfulnessScreen> createState() => _MindfulnessScreenState();
}

class _MindfulnessScreenState extends ConsumerState<MindfulnessScreen>
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
          'Mindfulness & Meditation',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00B894),
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: const Color(0xFF00B894),
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'Sessions'),
            Tab(icon: Icon(Icons.library_books), text: 'Library'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSessions(),
          _buildLibrary(),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildSessions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Start Session Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Start Your Meditation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showMeditationOptions(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF00B894),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Choose Session'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Session History
          Text(
            'Recent Sessions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _SessionCard(
                title: [
                  'Guided Breathing',
                  'Body Scan',
                  'Loving Kindness',
                  'Mindful Walking',
                  'Sleep Meditation',
                ][index],
                duration: (5 + index * 5),
                focus: 4 - (index % 2),
                date: DateTime.now().subtract(Duration(days: index)),
                category: [
                  'Breathing',
                  'Body',
                  'Love',
                  'Movement',
                  'Sleep',
                ][index],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLibrary() {
    final categories = [
      {
        'name': 'Breathing',
        'icon': 'ðŸ’¨',
        'count': 8,
        'duration': '5-10 min',
      },
      {
        'name': 'Body Scan',
        'icon': 'ðŸ§˜',
        'count': 6,
        'duration': '10-20 min',
      },
      {
        'name': 'Loving Kindness',
        'icon': 'ðŸ’—',
        'count': 5,
        'duration': '15-30 min',
      },
      {
        'name': 'Sleep',
        'icon': 'ðŸŒ™',
        'count': 7,
        'duration': '20-45 min',
      },
      {
        'name': 'Mindful Movement',
        'icon': 'ðŸš¶',
        'count': 6,
        'duration': '10-15 min',
      },
      {
        'name': 'Focus',
        'icon': 'ðŸŽ¯',
        'count': 9,
        'duration': '5-15 min',
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
              childAspectRatio: 0.95,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () => _showCategoryMeditations(
                  context,
                  cat['name'] as String,
                ),
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
                        cat['icon'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${cat['count']} sessions',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat['duration'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF00B894),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  Widget _buildStats() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00B894).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00B894),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('ðŸ”¥', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      'Current Streak',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '12 days',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00B894),
                              ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 80,
                  color: AppColors.borderColor,
                ),
                Column(
                  children: [
                    const Text('â­', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      'Longest Streak',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '28 days',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00B894),
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: const [
              _StatCard(
                icon: 'ðŸ§˜',
                label: 'Total Sessions',
                value: '87',
                subtitle: 'meditations',
              ),
              _StatCard(
                icon: 'â±ï¸',
                label: 'Total Minutes',
                value: '562',
                subtitle: 'minutes',
              ),
              _StatCard(
                icon: 'â­',
                label: 'Average Focus',
                value: '4.2',
                subtitle: 'out of 5',
              ),
              _StatCard(
                icon: 'ðŸ“ˆ',
                label: 'This Week',
                value: '5',
                subtitle: 'sessions',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Achievements
          Text(
            'Achievements',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final achievements = [
                ('ðŸŽ¯', 'First Step', index < 1),
                ('ðŸ”¥', 'Week Warrior', index < 2),
                ('ðŸ‘‘', 'Month Master', index < 3),
                ('ðŸŒŸ', 'Focus Expert', index < 4),
                ('ðŸ’«', 'Calm Master', index < 5),
                ('ðŸ†', 'Streak King', index < 6),
                ('âœ¨', 'Zen Mode', index < 7),
                ('ðŸŒˆ', 'Loving Heart', index < 8),
                ('ðŸŽŠ', 'Perfect Week', index < 9),
              ];

              final (icon, name, unlocked) = achievements[index];
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: unlocked
                      ? AppColors.cardColor
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: unlocked ? const Color(0xFF00B894) : Colors.grey,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: unlocked ? 1 : 0.6,
                      child: Text(
                        icon,
                        style: const TextStyle(
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: unlocked ? AppColors.textColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showMeditationOptions(BuildContext context) {
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
            Text(
              'Choose Duration',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...[5, 10, 15, 20].map((duration) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('$duration minute session'),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showCategoryMeditations(BuildContext context, String category) {
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
            Text(
              '$category Meditations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('$category Session ${index + 1}'),
                      subtitle: Text('${5 + index * 5} minutes'),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () => Navigator.pop(context),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String title;
  final int duration;
  final int focus;
  final DateTime date;
  final String category;

  const _SessionCard({
    required this.title,
    required this.duration,
    required this.focus,
    required this.date,
    required this.category,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${duration}min',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                Icons.star,
                color: i < focus ? Colors.amber : Colors.grey,
                size: 14,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00B894),
            ),
          ),
          Text(
            subtitle,
            style:
                const TextStyle(fontSize: 10, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

