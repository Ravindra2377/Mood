import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../features/analytics/screens/analytics_dashboard_screen.dart';
import '../../../features/exercises/screens/exercises_screen.dart';
import '../../../features/journal/screens/journal_screen.dart';
import '../../../features/mood/screens/mood_screen.dart';
import '../../../features/profile/screens/profile_screen.dart';
import '../../../features/self_help/screens/self_help_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBg,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          ExercisesScreen(),
          SelfHelpDashboardScreen(),
          AnalyticsDashboardScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _switchTab,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryPastel,
      unselectedItemColor: AppColors.mediumGrey,
      selectedLabelStyle: AppTypography.labelSmall,
      unselectedLabelStyle: AppTypography.labelSmall,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.self_improvement_outlined),
          label: 'Exercises',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology_outlined),
          label: 'Self-Help',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final List<_HighlightCardData> _highlights = [
    _HighlightCardData(
      title: 'How can we support you today?',
      subtitle: 'Check in with yourself, capture a thought, or try a quick reset.',
      emoji: '🌤️',
      colors: [AppColors.primaryPastel, AppColors.secondaryPastel],
    ),
    _HighlightCardData(
      title: 'Give your mind a soft landing',
      subtitle: 'A short journal entry can declutter your thoughts in minutes.',
      emoji: '📝',
      colors: [AppColors.calmPastel, AppColors.happyPastel],
    ),
    _HighlightCardData(
      title: 'Micro-moments add up',
      subtitle: 'Log a mood, stretch, breathe, or reflect—every pause matters.',
      emoji: '✨',
      colors: [AppColors.energyPastel, AppColors.coolPastel],
    ),
  ];

  int _activeHighlight = 0;
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    _startHighlightRotation();
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(context),
            const SizedBox(height: 28),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildMainActions(context),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final highlight = _highlights[_activeHighlight];
    final greeting = _greetingMessage();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: highlight.colors
              .map((color) => color.withOpacity(0.95))
              .toList(growable: false),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: highlight.colors.last.withOpacity(0.28),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
            Text(
              '$greeting',
              style: AppTypography.h4.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
              const Spacer(),
              IconButton(
                onPressed: _nextHighlight,
                icon: const Icon(Icons.refresh_rounded),
                color: AppColors.white,
                tooltip: 'Show another idea',
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Column(
              key: ValueKey(highlight.title),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${highlight.emoji} ${highlight.title}',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  highlight.subtitle,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _buildQuickActionChips(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This week at a glance',
          style: AppTypography.h4.copyWith(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildStatCard('7', 'Day streak', AppColors.happyPastel, '🔥'),
              const SizedBox(width: 12),
              _buildStatCard('18', 'Activities', AppColors.calmPastel, '✅'),
              const SizedBox(width: 12),
              _buildStatCard('76%', 'Wellness', AppColors.energyPastel, '⭐'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color, String emoji) {
    return CustomCard(
      backgroundColor: color.withOpacity(0.28),
      border: Border.all(color: color.withOpacity(0.75)),
      onTap: _nextHighlight,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          Column(
            children: [
              Text(
                value,
                style: AppTypography.h4.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What would you like to explore?',
          style: AppTypography.h4.copyWith(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ...[
          _MainActionCardData(
            title: 'Check in with your mood',
            subtitle: 'Log how you feel and surface trends over time.',
            icon: Icons.favorite_rounded,
            gradient: AppColors.lavenderGradient,
            accentColor: AppColors.primaryPastel,
            builder: (_) => const MoodScreen(),
          ),
          _MainActionCardData(
            title: 'Open your journal',
            subtitle: 'Free-write, respond to prompts, and revisit past entries.',
            icon: Icons.edit_rounded,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.warmPastel, AppColors.accentPastel],
            ),
            accentColor: AppColors.secondaryPastel,
            builder: (_) => const JournalScreen(),
          ),
          _MainActionCardData(
            title: 'Reset with a micro-practice',
            subtitle: 'Breathing, grounding, or gentle movement on demand.',
            icon: Icons.self_improvement,
            gradient: AppColors.mintGradient,
            accentColor: AppColors.coolPastel,
            builder: (_) => const ExercisesScreen(),
          ),
        ].map((data) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomCard(
              backgroundColor: data.accentColor.withOpacity(0.12),
              border: Border.all(color: data.accentColor.withOpacity(0.7)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: data.builder),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: data.gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: AppTypography.h4.copyWith(
                            color: AppColors.charcoal,
                          ),
                        ),
                        Text(
                          data.subtitle,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: data.accentColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final recentEntries = [
      {
        'title': 'Morning mood check',
        'duration': '1 min',
        'emoji': '🌞',
        'time': 'Today, 8:10 AM',
      },
      {
        'title': '3-minute grounding',
        'duration': '3 min',
        'emoji': '🌿',
        'time': 'Yesterday, 9:30 PM',
      },
      {
        'title': 'Gratitude journal',
        'duration': '5 min',
        'emoji': '📝',
        'time': '2 days ago',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent activity',
          style: AppTypography.h3.copyWith(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          padding: const EdgeInsets.all(12),
          border: Border.all(color: AppColors.mediumGrey.withOpacity(0.6)),
          child: Column(
            children: recentEntries.map((entry) {
              return Column(
                children: [
                  Row(
                    children: [
                      Text(entry['emoji']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry['title']!,
                              style: AppTypography.body1.copyWith(
                                color: AppColors.charcoal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              entry['time']!,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        entry['duration']!,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                  if (entry != recentEntries.last)
                    Divider(
                      height: 16,
                      color: AppColors.mediumGrey.withOpacity(0.4),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _startHighlightRotation() {
    _highlightTimer?.cancel();
    if (_highlights.length <= 1) return;
    _highlightTimer = Timer.periodic(const Duration(seconds: 16), (_) {
      if (!mounted) return;
      _nextHighlight();
    });
  }

  void _nextHighlight() {
    setState(() {
      _activeHighlight = (_activeHighlight + 1) % _highlights.length;
    });
  }

  List<Widget> _buildQuickActionChips(BuildContext context) {
    final chipData = [
      (
        label: 'Log a mood',
        icon: Icons.favorite_border,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const MoodScreen()),
        ),
      ),
      (
        label: 'Write a note',
        icon: Icons.edit_note,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const JournalScreen()),
        ),
      ),
      (
        label: 'Breathe for 3 min',
        icon: Icons.self_improvement,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ExercisesScreen()),
        ),
      ),
      (
        label: 'Self-care ideas',
        icon: Icons.lightbulb_outline,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SelfHelpDashboardScreen()),
        ),
      ),
    ];

    return chipData.map((entry) {
      return ActionChip(
        backgroundColor: AppColors.white.withOpacity(0.82),
        side: BorderSide(color: AppColors.white.withOpacity(0.4)),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        avatar: Icon(entry.icon, size: 18, color: AppColors.primaryPastel),
        label: Text(
          entry.label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: entry.onTap,
      );
    }).toList();
  }

  String _greetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }
}

class _HighlightCardData {
  const _HighlightCardData({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> colors;
}

class _MainActionCardData {
  const _MainActionCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final Color accentColor;
  final WidgetBuilder builder;
}