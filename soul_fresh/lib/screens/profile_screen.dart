import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String _bio = 'On a journey to better mental health 🌸';
  int _currentStreak = 14;
  int _moodEntries = 42;
  int _journalEntries = 15;
  int _meditationMinutes = 128;
  int _wellnessScore = 78;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
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
          _buildMenuSection('App Preferences', [
            _buildMenuItem(
              context,
              icon: Icons.palette,
              title: 'Theme',
              subtitle: 'Light / Dark / Auto',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.text_fields,
              title: 'Font Size',
              subtitle: 'Medium',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          
          _buildMenuSection('Notifications', [
            _buildMenuItem(
              context,
              icon: Icons.notifications,
              title: 'Mood Check-in',
              subtitle: 'Daily at 9:00 AM',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications,
              title: 'Meditation Reminder',
              subtitle: 'Daily at 7:00 AM',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications,
              title: 'Weekly Insights',
              subtitle: 'Every Sunday',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          
          _buildMenuSection('Account', [
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.description,
              title: 'Terms of Service',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.info,
              title: 'About SOUL',
              subtitle: 'v1.0.0',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          
          _buildMenuSection('Data', [
            _buildMenuItem(
              context,
              icon: Icons.download,
              title: 'Export My Data',
              subtitle: 'Download as PDF/JSON',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.delete,
              title: 'Delete Account',
              subtitle: 'Permanent action',
              onTap: () {},
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
}
