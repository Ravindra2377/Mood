import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/activities/data/activities_data.dart';
import '../features/activities/models/activity_view_model.dart';
import '../features/activities/search/activity_search_delegate.dart';
import '../features/activities/widgets/activity_list_card.dart';
import '../features/activities/widgets/recommended_activity_card.dart';
import '../features/exercises/widgets/exercise_info_dialog.dart';
import '../models/app_models.dart';
import '../state/ui_state.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  static const String route = '/activities';

  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  String _selectedCategory = 'All';
  String _selectedSort = 'Popular';
  String? _selectedTag;

  static const List<String> _sortOptions = <String>[
    'Popular',
    'Highest Rated',
    'Shortest Duration',
    'Alphabetical',
  ];

  static const Map<String, String> _activityRoutes = <String, String>{
    'box_breathing': '/exercises/box-breathing',
    '4_7_8_breathing': '/exercises/4-7-8-breathing',
    'resonant_breathing': '/exercises/resonant-breathing',
    'alternate_nostril': '/exercises/alternate-nostril',
    'full_body_pmr': '/exercises/full-body-pmr',
    'quick_pmr': '/exercises/quick-pmr',
    '5_4_3_2_1_sensory': '/exercises/5-4-3-2-1-grounding',
    'thought_challenging': '/exercises/thought-challenging',
    'worry_time': '/exercises/worry-time',
    'stream_consciousness': '/exercises/stream-consciousness',
    'gratitude_journal': '/exercises/gratitude-journal',
    'safe_place': '/exercises/safe-place',
    'success_visualization': '/exercises/success-visualization',
    'yoga_flow': '/exercises/yoga-flow',
    'desk_stretches': '/exercises/desk-stretches',
    'tipp_skills': '/exercises/tipp-skills',
    'stop_technique': '/exercises/stop-technique',
    'sleep_meditation': '/exercises/sleep-meditation',
    'emotion_wheel': '/exercises/emotion-wheel',
    'butterfly_hug': '/exercises/butterfly-hug',
    'hand_warming': '/exercises/hand-warming',
  };

  List<String> get _categories => <String>['All', ...primaryActivityCategories];

  @override
  Widget build(BuildContext context) {
    final MoodLevel? recentMood = ref.watch(selectedMoodProvider);
    final List<String> trendingTags = _computeTrendingTags();
    final List<WellnessActivity> recommendations =
        _buildRecommendations(recentMood);
    final List<Widget> activitySlivers = _buildActivitySections();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Search activities',
            icon: const Icon(Icons.search),
            onPressed: () async {
              final WellnessActivity? selection =
                  await showSearch<WellnessActivity?>(
                context: context,
                delegate: ActivitySearchDelegate(
                  activities: allActivities,
                  trendingTags: trendingTags,
                ),
              );
              if (selection != null) {
                _openActivityDetails(selection);
              }
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'Sort options',
            initialValue: _selectedSort,
            icon: const Icon(Icons.sort),
            onSelected: (String value) {
              setState(() => _selectedSort = value);
            },
            itemBuilder: (BuildContext context) {
              return _sortOptions
                  .map(
                    (String option) => PopupMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ),
                  )
                  .toList();
            },
          ),
          IconButton(
            tooltip: 'Activity settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(child: _buildStatsCard(context)),
            if (recommendations.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildRecommendationSection(recommendations),
              ),
            SliverToBoxAdapter(child: _buildCategoryFilters()),
            if (trendingTags.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildTagFilters(trendingTags),
              ),
            ...activitySlivers,
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    const ActivityStats stats = defaultActivityStats;
    final double weeklyProgress = (stats.minutesToday / stats.weeklyGoalMinutes)
        .clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF7E57C2), Color(0xFF26A69A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _buildStatColumn('🔥', '${stats.streakDays} days', 'Streak'),
                const SizedBox(width: 16),
                _buildStatColumn('⏱️', '${stats.minutesToday} min', 'Today'),
                const SizedBox(width: 16),
                _buildStatColumn('✅', '${stats.totalCompleted}', 'Completed'),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Weekly goal: ${stats.weeklyGoalMinutes} min',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: weeklyProgress,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFFFF59D)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationSection(List<WellnessActivity> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Row(
            children: <Widget>[
              Text(
                'Recommended for you',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 8),
              Text('💡', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recommendations.length,
            itemBuilder: (BuildContext context, int index) {
              final WellnessActivity activity = recommendations[index];
              return RecommendedActivityCard(
                activity: activity,
                onTap: () => _openActivityDetails(activity),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (BuildContext context, int index) {
          final String category = _categories[index];
          final bool isSelected = _selectedCategory == category;
          final int count = _countForCategory(category);
          final String label = count > 0 ? '$category ($count)' : category;
          return Padding(
            padding: EdgeInsets.only(
              right: index == _categories.length - 1 ? 0 : 8,
            ),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = category),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTagFilters(List<String> tags) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Trending tags',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              if (_selectedTag != null)
                TextButton(
                  onPressed: () => setState(() => _selectedTag = null),
                  child: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: tags.map((String tag) {
              final bool isSelected = _selectedTag == tag;
              return ChoiceChip(
                label: Text('#$tag'),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedTag = isSelected ? null : tag;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActivitySections() {
    if (_selectedCategory == 'All') {
      final List<Widget> slivers = <Widget>[];
      for (final String category in primaryActivityCategories) {
        final List<WellnessActivity> activities =
            _activitiesForCategory(category);
        if (activities.isEmpty) {
          continue;
        }
        slivers
          ..add(_buildSectionHeader(category, activities.length))
          ..add(_buildActivityList(activities));
      }
      if (slivers.isEmpty) {
        return <Widget>[_buildEmptyState()];
      }
      return slivers;
    }

    final List<WellnessActivity> selectedActivities =
        _activitiesForCategory(_selectedCategory);
    if (selectedActivities.isEmpty) {
      return <Widget>[_buildEmptyState()];
    }

    return <Widget>[
      _buildSectionHeader(_selectedCategory, selectedActivities.length),
      _buildActivityList(selectedActivities),
    ];
  }

  SliverToBoxAdapter _buildSectionHeader(String category, int count) {
    final Color color = categoryColors[category] ?? Colors.blueGrey;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Row(
          children: <Widget>[
            Icon(_categoryIcon(category), color: color),
            const SizedBox(width: 8),
            Text(
              '$category ($count)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverList _buildActivityList(List<WellnessActivity> activities) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final WellnessActivity activity = activities[index];
          return ActivityListCard(
            activity: activity,
            onTap: () => _openActivityDetails(activity),
          );
        },
        childCount: activities.length,
      ),
    );
  }

  SliverFillRemaining _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.sentiment_satisfied_alt,
                  size: 56, color: Colors.grey,),
              const SizedBox(height: 16),
              Text(
                'No activities match your filters yet.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Try adjusting the tag or category filters to explore more exercises.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openActivityDetails(WellnessActivity activity) {
    showExerciseInfoDialog(
      context,
      exerciseId: activity.id,
      onStartExercise: () {
        final String? route = _activityRoutes[activity.id];
        if (route != null) {
          Navigator.of(context).pushNamed(route);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Guided session coming soon for this activity.'),
            ),
          );
        }
      },
    );
  }

  List<WellnessActivity> _activitiesForCategory(String category) {
    final Iterable<WellnessActivity> source = allActivities.where(
      (WellnessActivity activity) => activity.category == category,
    );
    final List<WellnessActivity> filtered = _applyTagFilter(source);
    return _sortActivities(filtered);
  }

  List<WellnessActivity> _sortActivities(List<WellnessActivity> activities) {
    final List<WellnessActivity> sorted = List<WellnessActivity>.from(activities);
    switch (_selectedSort) {
      case 'Popular':
        sorted.sort((WellnessActivity a, WellnessActivity b) {
          final int scoreA = (a.isPopular ? 2 : 0) + (a.isRecommended ? 1 : 0);
          final int scoreB = (b.isPopular ? 2 : 0) + (b.isRecommended ? 1 : 0);
          if (scoreA != scoreB) {
            return scoreB.compareTo(scoreA);
          }
          return b.rating.compareTo(a.rating);
        });
        break;
      case 'Highest Rated':
        sorted.sort((WellnessActivity a, WellnessActivity b) {
          final int ratingCompare = b.rating.compareTo(a.rating);
          if (ratingCompare != 0) {
            return ratingCompare;
          }
          return b.ratingCount.compareTo(a.ratingCount);
        });
        break;
      case 'Shortest Duration':
        sorted.sort(
          (WellnessActivity a, WellnessActivity b) =>
              a.durationMinutes.compareTo(b.durationMinutes),
        );
        break;
      case 'Alphabetical':
        sorted.sort(
          (WellnessActivity a, WellnessActivity b) =>
              a.name.compareTo(b.name),
        );
        break;
    }
    return sorted;
  }

  List<WellnessActivity> _applyTagFilter(Iterable<WellnessActivity> source) {
    if (_selectedTag == null) {
      return List<WellnessActivity>.from(source);
    }
    return source
        .where((WellnessActivity activity) =>
            activity.tags.contains(_selectedTag!),)
        .toList();
  }

  int _countForCategory(String category) {
    if (category == 'All') {
      return _applyTagFilter(allActivities).length;
    }
    return _activitiesForCategory(category).length;
  }

  List<WellnessActivity> _buildRecommendations(MoodLevel? mood) {
    final LinkedHashSet<WellnessActivity> picks = LinkedHashSet<WellnessActivity>();
    picks.addAll(allActivities.where((WellnessActivity activity) => activity.isRecommended));

    final int hour = TimeOfDay.now().hour;

    if (mood == MoodLevel.angry || mood == MoodLevel.sad) {
      picks.addAll(_activitiesByIds(<String>[
        'box_breathing',
        '5_4_3_2_1_sensory',
        'quick_pmr',
      ]),);
    }
    if (mood == MoodLevel.neutral || mood == MoodLevel.happy) {
      picks.addAll(_activitiesByIds(<String>[
        'gratitude_journal',
        'success_visualization',
      ]),);
    }
    if (mood == MoodLevel.veryHappy) {
      picks.addAll(_activitiesByIds(<String>[
        'opposite_action',
        'yoga_flow',
      ]),);
    }
    if (hour >= 20) {
      picks.addAll(_activitiesByIds(<String>[
        'sleep_meditation',
        'body_scan_sleep',
        '4_7_8_breathing',
      ]),);
    } else if (hour < 12) {
      picks.addAll(_activitiesByIds(<String>[
        'gratitude_journal',
        'yoga_flow',
      ]),);
    }
    if (_selectedTag != null) {
      picks.addAll(allActivities.where(
        (WellnessActivity activity) => activity.tags.contains(_selectedTag!),
      ),);
    }
    if (_selectedCategory != 'All') {
      picks.addAll(_activitiesForCategory(_selectedCategory));
    }

    return picks.take(6).toList();
  }

  List<WellnessActivity> _activitiesByIds(List<String> ids) {
    return allActivities
        .where((WellnessActivity activity) => ids.contains(activity.id))
        .toList();
  }

  List<String> _computeTrendingTags() {
    final Map<String, int> counts = <String, int>{};
    for (final WellnessActivity activity in allActivities) {
      for (final String tag in activity.tags) {
        counts[tag] = (counts[tag] ?? 0) + (activity.isPopular ? 3 : 1);
      }
    }
    final List<MapEntry<String, int>> entries = counts.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) =>
          b.value.compareTo(a.value),);
    return entries.map((MapEntry<String, int> e) => e.key).take(8).toList();
  }

  Widget _buildStatColumn(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Breathing':
        return Icons.air;
      case 'Muscle Relaxation':
        return Icons.self_improvement;
      case 'Mindfulness':
        return Icons.spa;
      case 'Cognitive Tools':
        return Icons.psychology_alt;
      case 'Journaling':
        return Icons.menu_book;
      case 'Crisis Support':
        return Icons.health_and_safety;
      case 'Sleep':
        return Icons.nightlight_round;
      case 'Quick Relief':
        return Icons.flash_on;
      default:
        return Icons.circle;
    }
  }
}

