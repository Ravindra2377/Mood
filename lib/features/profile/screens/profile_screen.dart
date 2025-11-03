import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/auth_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isLoggingOut = authState.operation == AuthOperation.loggingOut;
    final emailAddress =
        authState.user?.email ?? authState.email ?? 'you@soul.app';
    final displayName = authState.user?.email?.split('@').first ??
        authState.email?.split('@').first ??
        'Soul member';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Lavender Gradient Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                    AppColors.secondary.withOpacity(0.6),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    // Header content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            'My Profile',
                            style: AppTypography.h1.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your wellness journey',
                            style: AppTypography.body2.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar Section
                  _buildAvatarSection(displayName, emailAddress),
                  const SizedBox(height: 24),

                  // Personal Stats
                  _buildPersonalStats(),
                  const SizedBox(height: 24),

                  // Wellness Summary
                  _buildWellnessSummary(),
                  const SizedBox(height: 24),

                  // Settings Options
                  _buildSettingsOptions(),
                  const SizedBox(height: 24),

                  // Achievement Badges
                  _buildAchievementBadges(),
                  const SizedBox(height: 24),

                  // Account Actions
                  _buildAccountActions(ref, isLoggingOut),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(String displayName, String emailAddress) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // User Info
            Text(
              displayName,
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              emailAddress,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Premium Member',
                style: AppTypography.label.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: '🔥',
            value: '47',
            label: 'Day Streak',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: '⭐',
            value: '4.8',
            label: 'Avg Mood',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: '⏱️',
            value: '127',
            label: 'Minutes',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.h3.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessSummary() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wellness Summary',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildWellnessMetric('Overall Wellness', 78, AppColors.primary),
            const SizedBox(height: 12),
            _buildWellnessMetric('Sleep Quality', 82, AppColors.secondary),
            const SizedBox(height: 12),
            _buildWellnessMetric('Stress Management', 65, AppColors.warning),
            const SizedBox(height: 12),
            _buildWellnessMetric('Social Connection', 71, AppColors.accent),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessMetric(String label, int value, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.body1.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            '$value%',
            style: AppTypography.body2.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsOptions() {
    return CustomCard(
      child: Column(
        children: [
          _buildSettingOption(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update personal information',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingOption(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingOption(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy & Security',
            subtitle: 'Control your data and privacy',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingOption(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Theme and display settings',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingOption(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingOption(
            icon: Icons.info_outline,
            title: 'About Soul',
            subtitle: 'App version and information',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.textSecondary.withOpacity(0.1),
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildAchievementBadges() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildBadge('🏆', 'First Week', 'Completed 7 days', true),
                const SizedBox(width: 12),
                _buildBadge('🔥', 'Streak Master', '30 day streak', true),
                const SizedBox(width: 12),
                _buildBadge('🧘', 'Mindful', '100 sessions', false),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildBadge('😊', 'Mood Tracker', '50 entries', true),
                const SizedBox(width: 12),
                _buildBadge(
                    '🌙', 'Sleep Champion', 'Good sleep 30 days', false),
                const SizedBox(width: 12),
                _buildBadge('💪', 'Exercise Pro', '200 minutes', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(
      String emoji, String title, String description, bool unlocked) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: unlocked
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.textSecondary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unlocked
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.textSecondary.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: 24,
                color: unlocked
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.label.copyWith(
                color: unlocked
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions(WidgetRef ref, bool isLoggingOut) {
    return Column(
      children: [
        CustomButton(
          text: 'Export My Data',
          isOutlined: true,
          backgroundColor: AppColors.primaryPastel,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Sign out',
          isOutlined: true,
          backgroundColor: AppColors.error,
          textColor: AppColors.error,
          isLoading: isLoggingOut,
          onPressed: isLoggingOut
              ? null
              : () => ref.read(authControllerProvider.notifier).logout(),
        ),
      ],
    );
  }
}
