import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ai/panda_ai.dart';
import '../core/ai/panda_preferences.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/animated_panda_companion.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../widgets/loading_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static const String route = '/profile';
  
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _userEmail;
  String? _userId;
  String _displayName = 'SOUL User';
  final String _bio = 'On a journey to better mental health 🌸';
  final int _currentStreak = 14;
  final int _moodEntries = 42;
  final int _journalEntries = 15;
  final int _meditationMinutes = 128;
  final int _wellnessScore = 78;
  late TabController _tabController;
  final PandaAI _pandaAI = PandaAI();
  PandaMood _pandaMood = PandaMood.welcome;
  late String _pandaMessage;
  Timer? _pandaTimer;
  PandaPreferences? _pandaPreferences;
  PandaPersona _pandaPersona = PandaPersona.gentleGuide;
  String _pandaCompanionName = 'Mochi';
  
  // Settings state
  bool _notificationsEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pandaMessage = _pandaAI.personalizedMessage(
      _pandaMood,
      persona: _pandaPersona,
      name: _pandaCompanionName,
    );
    _initializePandaPreferences();
    _startPandaRotation();
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pandaTimer?.cancel();
    _pandaPreferences?.removeListener(_handlePandaPreferencesChanged);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final storage = ref.read(secureStorageServiceProvider);
      final email = await storage.getUserEmail();
      final id = await storage.getUserId();
      
      setState(() {
        _userEmail = email;
        _userId = id;
        _displayName = email?.split('@').first.toUpperCase() ?? 'SOUL User';
        _isLoading = false;
      });
      _updatePandaMood(PandaMood.happy);
    } catch (e) {
      setState(() => _isLoading = false);
      _updatePandaMood(PandaMood.lonely);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header with gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade300,
                          Colors.teal.shade300,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                    child: Column(
                      children: [
                        // Profile Avatar with wellness aura
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.green.shade400,
                                    Colors.blue.shade400,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              width: 100,
                              height: 100,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.transparent,
                                child: Text(
                                  _userEmail?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Streak badge
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$_currentStreak',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // User Info
                        Text(
                          _displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _bio,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _userEmail ?? 'user@example.com',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Member since ${DateTime.now().year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPandaCompanionStrip(),
                  ),
                  const SizedBox(height: 20),

                  // Tab navigation
                  Container(
                    color: Colors.grey.shade50,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: const [
                        Tab(text: 'Stats'),
                        Tab(text: 'Goals'),
                        Tab(text: 'Settings'),
                      ],
                    ),
                  ),

                  // Tab content
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Stats Tab
                        _buildStatsTab(context),
                        // Goals Tab
                        _buildGoalsTab(context),
                        // Settings Tab
                        _buildSettingsTab(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wellness Score
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.amber.shade200, Colors.orange.shade300],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Wellness Score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_wellnessScore',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _wellnessScore / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Grid
          const Text(
            'Activity Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Mood Entries',
                  _moodEntries.toString(),
                  Icons.mood,
                  Colors.blue,
                  context,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Journal',
                  _journalEntries.toString(),
                  Icons.book,
                  Colors.purple,
                  context,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Meditation',
                  '${_meditationMinutes}m',
                  Icons.self_improvement,
                  Colors.green,
                  context,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '$_currentStreak d',
                  Icons.local_fire_department,
                  Colors.red,
                  context,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Achievements
          const Text(
            'Achievements 🏆',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildAchievementBadge('🔥', '7-Day\nWarrior', true),
              _buildAchievementBadge('🧘', 'Mindful\nMaster', true),
              _buildAchievementBadge('😊', 'Mood\nTracker', true),
              _buildAchievementBadge('📓', 'Journal\nJourney', false),
              _buildAchievementBadge('💤', 'Sleep\nChampion', false),
              _buildAchievementBadge('⭐', 'Wellness\nStar', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Goals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildGoalCard(
            'Meditate 10 min daily',
            0.75,
            Icons.self_improvement,
            Colors.green,
          ),
          const SizedBox(height: 12),
          
          _buildGoalCard(
            'Journal 3x per week',
            1.0,
            Icons.book,
            Colors.purple,
          ),
          const SizedBox(height: 12),
          
          _buildGoalCard(
            'Reduce stress to level 3',
            0.5,
            Icons.psychology,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          
          _buildGoalCard(
            'Get 8 hours sleep',
            0.65,
            Icons.bedtime,
            Colors.blue,
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add New Goal'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add goal - Coming soon!'),
                  ),
                );
                _updatePandaMood(PandaMood.focus);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Appearance Section
          _buildMenuSection('Appearance', [
            _buildMenuItem(
              context,
              icon: Icons.palette,
              title: 'Theme',
              subtitle: _getThemeModeText(),
              onTap: () => _showThemeModeDialog(context),
            ),
          ]),
          const SizedBox(height: 24),
          
          // Notifications Section
          _buildMenuSection('Notifications', [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive reminders and updates'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                _updatePandaMood(value ? PandaMood.focus : PandaMood.calm);
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.schedule,
              title: 'Mood Check-in Time',
              subtitle: 'Daily at 9:00 AM',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Time picker - Coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                _updatePandaMood(PandaMood.focus);
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications,
              title: 'Meditation Reminder',
              subtitle: 'Daily at 7:00 AM',
              onTap: () {
                _updatePandaMood(PandaMood.focus);
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications,
              title: 'Weekly Insights',
              subtitle: 'Every Sunday',
              onTap: () {
                _updatePandaMood(PandaMood.focus);
              },
            ),
          ]),
          const SizedBox(height: 24),
          
          // Privacy Section
          _buildMenuSection('Privacy & Security', [
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip,
              title: 'Privacy Settings',
              onTap: () {
                Navigator.pushNamed(context, '/privacy-settings');
                _updatePandaMood(PandaMood.focus);
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Change password - Coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                _updatePandaMood(PandaMood.focus);
              },
            ),
          ]),
          const SizedBox(height: 24),
          
          // Data Section
          _buildMenuSection('Data & Storage', [
            _buildMenuItem(
              context,
              icon: Icons.download,
              title: 'Export My Data',
              subtitle: 'Download as PDF/JSON',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data export - Coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                _updatePandaMood(PandaMood.focus);
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.cleaning_services,
              title: 'Clear Cache',
              subtitle: 'Free up storage space',
              onTap: _clearCache,
            ),
          ]),
          const SizedBox(height: 24),
          
          // About Section
          _buildMenuSection('About', [
            _buildMenuItem(
              context,
              icon: Icons.description,
              title: 'Terms of Service',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terms of Service - Coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                _updatePandaMood(PandaMood.focus);
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy Policy - Coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                _updatePandaMood(PandaMood.focus);
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.info,
              title: 'About SOUL',
              subtitle: 'v1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'SOUL',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 SOUL Mental Health',
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'Your mental health companion for tracking moods, journaling, and meditation.',
                      ),
                    ),
                  ],
                );
                _updatePandaMood(PandaMood.happy);
              },
            ),
          ]),
          const SizedBox(height: 24),
          
          // Danger Zone
          _buildMenuSection('Danger Zone', [
            _buildMenuItem(
              context,
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanent action',
              onTap: _confirmDeleteAccount,
              color: Colors.red,
            ),
          ]),
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _handleLogout,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPandaCompanionStrip() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryPastel.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPastel.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_pandaDisplayName loves keeping you company on this journey',
            style: AppTypography.h4.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          AnimatedPandaCompanion(
            mood: _pandaMood,
            message: _pandaMessage,
            onTap: _refreshPandaMessage,
            persona: _pandaPersona,
            heroTag: 'panda-companion',
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: const Text('Cheer me up'),
                avatar: const Text('🌈'),
                onPressed: () => _updatePandaMood(PandaMood.happy),
              ),
              ActionChip(
                label: const Text('I need a hug'),
                avatar: const Text('🤗'),
                onPressed: () => _updatePandaMood(PandaMood.lonely),
              ),
              ActionChip(
                label: const Text('Keep me focused'),
                avatar: const Text('🎯'),
                onPressed: () => _updatePandaMood(PandaMood.focus),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(String title, double progress, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(String emoji, String label, bool unlocked) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(unlocked ? 'Achievement Unlocked: $label' : 'Keep working to unlock!'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? Colors.amber.shade100 : Colors.grey.shade300,
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            padding: const EdgeInsets.all(12),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: unlocked ? Colors.black : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? Colors.grey;
    
    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout() async {
    _updatePandaMood(PandaMood.lonely);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final authService = ref.read(authServiceProvider);
        await authService.logout();
        
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: $e')),
          );
        }
      }
    }
  }

  String _getThemeModeText() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      default:
        return 'System';
    }
  }

  Future<void> _showThemeModeDialog(BuildContext context) async {
    final selectedMode = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              subtitle: const Text('Follow system setting'),
              value: ThemeMode.system,
              groupValue: _themeMode,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              subtitle: const Text('Always light theme'),
              value: ThemeMode.light,
              groupValue: _themeMode,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              subtitle: const Text('Always dark theme'),
              value: ThemeMode.dark,
              groupValue: _themeMode,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedMode != null && mounted) {
      setState(() => _themeMode = selectedMode);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Theme updated - Coming soon!'),
          duration: Duration(seconds: 2),
        ),
      );
      _updatePandaMood(PandaMood.focus);
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove all cached data. Your journal entries and mood history will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully')),
      );
      _updatePandaMood(PandaMood.celebrate);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    _updatePandaMood(PandaMood.lonely);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deletion - Coming soon!'),
          duration: Duration(seconds: 2),
        ),
      );
      _updatePandaMood(PandaMood.lonely);
    }
  }

  Future<void> _initializePandaPreferences() async {
    final prefs = await PandaPreferences.instance();
    if (!mounted) return;

    _pandaPreferences?.removeListener(_handlePandaPreferencesChanged);
    _pandaPreferences = prefs;
    prefs.addListener(_handlePandaPreferencesChanged);

    setState(() {
      _pandaPersona = prefs.persona;
      _pandaCompanionName = prefs.displayName;
      _updatePandaMessage();
    });
  }

  void _handlePandaPreferencesChanged() {
    final prefs = _pandaPreferences;
    if (prefs == null || !mounted) return;
    setState(() {
      _pandaPersona = prefs.persona;
      _pandaCompanionName = prefs.displayName;
      _updatePandaMessage();
    });
  }

  String get _pandaDisplayName =>
      _pandaCompanionName.isEmpty ? 'Mochi' : _pandaCompanionName;

  void _updatePandaMessage([PandaMood? mood]) {
    final targetMood = mood ?? _pandaMood;
    _pandaMessage = _pandaAI.personalizedMessage(
      targetMood,
      persona: _pandaPersona,
      name: _pandaDisplayName,
    );
  }

  void _updatePandaMood(PandaMood mood) {
    setState(() {
      _pandaMood = mood;
      _updatePandaMessage(mood);
    });
  }

  void _refreshPandaMessage() {
    setState(_updatePandaMessage);
  }

  void _startPandaRotation() {
    _pandaTimer?.cancel();
    _pandaTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (!mounted) return;
      _refreshPandaMessage();
    });
  }
}
