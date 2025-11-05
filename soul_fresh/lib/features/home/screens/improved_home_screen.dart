import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../screens/journal_list.dart';
import '../../../screens/profile_screen.dart';
import '../../../screens/self_help_screen.dart';
import '../../analytics/screens/unified_analytics_screen.dart';
import '../../exercises/screens/exercises_main_screen.dart';
import '../../insights/screens/insights_screen.dart';

class ImprovedHomeScreen extends StatefulWidget {
  const ImprovedHomeScreen({Key? key}) : super(key: key);

  @override
  State<ImprovedHomeScreen> createState() => _ImprovedHomeScreenState();
}

class _ImprovedHomeScreenState extends State<ImprovedHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBg,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const JournalListScreen(),
          const ExercisesMainScreen(),
          const SelfHelpScreen(),
          const UnifiedAnalyticsScreen(),
          const InsightsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 28),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildMainActions(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final greeting = _greetingMessage();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.peacePastelGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.coolPastel.withOpacity(0.25),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting 👋',
            style: AppTypography.h3.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You are in control of your wellness journey. Explore today\'s tools whenever you are ready.',
            style: AppTypography.body2.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/mood-entry'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryPastel,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.bubble_chart_outlined),
            label: const Text('Log today\'s mood'),
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
              _buildStatCard('7', 'Day Streak', AppColors.happyPastel, '🔥'),
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

  Widget _buildStatCard(
    String value,
    String label,
    Color color,
    String emoji, {
    VoidCallback? onTap,
  }) {
    return CustomCard(
      backgroundColor: color.withOpacity(0.28),
      borderColor: color.withOpacity(0.75),
      onTap: onTap,
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

  Widget _buildMainActions() {
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
        CustomCard(
          backgroundColor: AppColors.primaryPastel.withOpacity(0.15),
          borderColor: AppColors.primaryPastel,
          onTap: () => Navigator.of(context).pushNamed('/mood-entry'),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.lavenderGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mood, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you feeling?',
                      style: AppTypography.h4.copyWith(
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      'Log your mood and get gentle insights in seconds.',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primaryPastel,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          backgroundColor: AppColors.secondaryPastel.withOpacity(0.18),
          borderColor: AppColors.secondaryPastel,
          onTap: () => _switchTab(1),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.peacePastelGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.book_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Open your journal',
                      style: AppTypography.h4.copyWith(
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      'Review past reflections or start a fresh entry.',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.secondaryPastel,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          backgroundColor: AppColors.secondaryPastel.withOpacity(0.15),
          borderColor: AppColors.secondaryPastel,
          onTap: () => _switchTab(2),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.mintGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.self_improvement,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start an Exercise',
                      style: AppTypography.h4.copyWith(
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      'Breathing, meditation, grounding, journaling—choose your reset.',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.secondaryPastel,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: AppTypography.h3.copyWith(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          padding: const EdgeInsets.all(12),
          borderColor: AppColors.mediumGrey.withOpacity(0.6),
          child: Column(
            children: [
              _buildActivityItem('Box Breathing', '5 min', '😊', '8:00 AM'),
              const Divider(height: 12),
              _buildActivityItem('Mood Check', '1 min', '👍', '10:30 AM'),
              const Divider(height: 12),
              _buildActivityItem('Gratitude Journal', '3 min', '✨', '3:45 PM'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String duration,
    String emoji,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            duration,
            style: AppTypography.body2.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Material(
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.mediumGrey, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _switchTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.book_outlined, 'Journal', 1),
            _buildNavItem(Icons.self_improvement_outlined, 'Exercises', 2),
            _buildNavItem(Icons.psychology_outlined, 'Self-Help', 3),
            _buildNavItem(Icons.analytics_outlined, 'Analytics', 4),
            _buildNavItem(Icons.bar_chart_outlined, 'Insights', 5),
            _buildNavItem(Icons.person_outline, 'Profile', 6),
          ],
        ),
      ),
    );
  }

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primaryPastel.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? AppColors.primaryPastel : AppColors.darkGrey,
        ),
      ),
      label: label,
    );
  }

  String _greetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }
}
