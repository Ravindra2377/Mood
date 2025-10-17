# 🚀 SOUL Fresh - Priority Roadmap & Implementation Guide

## 📊 Current Status (October 18, 2025)

### ✅ **COMPLETED** (20 files, 3,978 lines)
- ✅ Authentication System (login, signup, OTP)
- ✅ Navigation/Routing with auth guards
- ✅ Material 3 Theme System (light/dark)
- ✅ Error Handling Framework
- ✅ Utility Helpers (validators, formatters, constants)
- ✅ Secure Storage Service
- ✅ UI Components (error, loading, retry widgets)

### 🔧 **JUST FIXED**
- ✅ Added INTERNET permission to AndroidManifest.xml
- ✅ Added ACCESS_NETWORK_STATE permission

---

## 🎯 **PHASE 1: Critical Foundation (THIS WEEK)**

### Priority 1️⃣: **Test & Validate What We Built** ⚡ *START NOW*

#### Step 1: Build and Test APK
```bash
cd D:\OneDrive\Desktop\Mood\soul_fresh
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build apk --release
```

#### Step 2: Start Backend
```bash
cd D:\OneDrive\Desktop\Mood\backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
```

#### Step 3: Test Authentication Flow
- [ ] Install APK on emulator/device
- [ ] Test signup with email/password
- [ ] Verify OTP flow
- [ ] Test login
- [ ] Verify token storage persists after app restart
- [ ] Test logout

**Expected Result**: User can signup → receive OTP → verify → login → stay logged in after app restart

---

### Priority 2️⃣: **Integrate Router into Main App** 🔌 *2 HOURS*

**Current Issue**: New auth screens exist but aren't connected to main.dart

**Solution**: Update `lib/main.dart`

<details>
<summary>📝 Click to see exact code changes</summary>

#### Add imports to main.dart (top of file):
```dart
import 'core/router.dart';
import 'core/routes.dart';
import 'core/theme.dart' as NewTheme;
```

#### Replace MaterialApp configuration:
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final router = ref.watch(appRouterProvider);
  
  return MaterialApp(
    title: 'SOUL',
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.system,
    
    // Use new theme system
    theme: NewTheme.AppTheme.light,
    darkTheme: NewTheme.AppTheme.dark,
    
    // Use new router
    initialRoute: Routes.login,
    onGenerateRoute: router.onGenerateRoute,
    onUnknownRoute: router.onUnknownRoute,
  );
}
```

**Tasks**:
- [ ] Add imports
- [ ] Update MaterialApp configuration
- [ ] Remove old LoginScreen class from main.dart (keep or comment out)
- [ ] Test navigation
- [ ] Test auth flow

</details>

---

### Priority 3️⃣: **Create Profile & Settings Screens** 👤 *4-6 HOURS*

We need these 3 screens to complete the core user experience:

#### File 1: `lib/screens/profile_screen.dart`
<details>
<summary>📝 Implementation Template</summary>

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/colors.dart';
import '../services/auth_service.dart';
import '../widgets/loading_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = false;
  String? _userEmail;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    final authService = ref.read(authServiceProvider);
    // TODO: Add getUserProfile() method to AuthService
    // final profile = await authService.getUserProfile();
    
    setState(() {
      // _userEmail = profile.email;
      // _userId = profile.id;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile photo
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      _userEmail?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  Text(
                    _userEmail ?? 'user@example.com',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Member since: ${DateTime.now().year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 32),
                  
                  // Stats cards
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Mood Entries', '0', context)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Journal Entries', '0', context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Meditation Mins', '0', context)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Streak', '0 days', context)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Action buttons
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to edit profile
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text('View Analytics'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to analytics
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
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
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authService = ref.read(authServiceProvider);
      await authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}
```

**Tasks**:
- [ ] Create file
- [ ] Add getUserProfile() to AuthService
- [ ] Test profile display
- [ ] Test logout

</details>

#### File 2: `lib/screens/settings_screen.dart`
<details>
<summary>📝 Implementation Template</summary>

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() => _darkModeEnabled = value);
              // TODO: Implement theme switching
            },
          ),
          
          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive reminders and updates'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              // TODO: Update notification preferences
            },
          ),
          ListTile(
            title: const Text('Notification Time'),
            subtitle: const Text('Daily reminder at 9:00 AM'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show time picker
            },
          ),
          
          // Privacy Section
          _buildSectionHeader('Privacy & Security'),
          ListTile(
            title: const Text('Privacy Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/privacy-settings'),
          ),
          ListTile(
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to change password
            },
          ),
          
          // About Section
          _buildSectionHeader('About'),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/terms'),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
          ),
          ListTile(
            title: const Text('About SOUL'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),
          
          // Danger Zone
          _buildSectionHeader('Danger Zone'),
          ListTile(
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: _confirmDeleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
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

    if (confirmed == true) {
      // TODO: Implement account deletion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deletion not yet implemented')),
      );
    }
  }
}
```

**Tasks**:
- [ ] Create file
- [ ] Implement theme switching
- [ ] Add notification preferences
- [ ] Test navigation

</details>

#### File 3: `lib/screens/privacy_settings_screen.dart`
<details>
<summary>📝 Quick Implementation</summary>

```dart
import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _shareAnalytics = true;
  bool _personalizedContent = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Share Anonymous Analytics'),
            subtitle: const Text('Help us improve the app'),
            value: _shareAnalytics,
            onChanged: (value) => setState(() => _shareAnalytics = value),
          ),
          SwitchListTile(
            title: const Text('Personalized Content'),
            subtitle: const Text('Show recommendations based on your activity'),
            value: _personalizedContent,
            onChanged: (value) => setState(() => _personalizedContent = value),
          ),
          const Divider(),
          ListTile(
            title: const Text('Export My Data'),
            subtitle: const Text('Download all your data'),
            trailing: const Icon(Icons.download),
            onTap: () {
              // TODO: Implement data export
            },
          ),
        ],
      ),
    );
  }
}
```

</details>

**Add to router.dart**:
```dart
case Routes.profile:
  return MaterialPageRoute(builder: (_) => const ProfileScreen());
case Routes.settings:
  return MaterialPageRoute(builder: (_) => const SettingsScreen());
case Routes.privacySettings:
  return MaterialPageRoute(builder: (_) => const PrivacySettingsScreen());
```

---

## 📋 **THIS WEEK'S CHECKLIST**

### Day 1-2: Testing & Integration
- [ ] Add INTERNET permission (DONE ✅)
- [ ] Build APK and test
- [ ] Start backend and verify connectivity
- [ ] Test authentication flow end-to-end
- [ ] Integrate router into main.dart
- [ ] Test navigation

### Day 3-4: Profile & Settings
- [ ] Create profile_screen.dart
- [ ] Create settings_screen.dart
- [ ] Create privacy_settings_screen.dart
- [ ] Add routes to router
- [ ] Test all screens

### Day 5-7: Polish & Prepare for Next Phase
- [ ] Add avatar upload to profile
- [ ] Implement theme switching
- [ ] Add notification time picker
- [ ] Update todo list
- [ ] Document any issues
- [ ] Commit and push to GitHub

---

## 🚀 **NEXT WEEK: Analytics Dashboard**

After completing Profile & Settings, we'll build:

1. **Analytics Dashboard** (`analytics_dashboard.dart`)
   - Mood trends chart (last 7/30 days)
   - Journal entry count
   - Meditation minutes
   - Streak tracking

2. **Mood Insights** (`mood_insights_screen.dart`)
   - Pattern recognition
   - Trigger identification
   - Mood correlations

3. **Progress Screen** (`progress_screen.dart`)
   - Goals tracking
   - Achievements
   - Milestones

---

## 📊 **Progress Tracker**

### Phase 1: Foundation (Week 1-2)
- ✅ Fix build issue (DONE)
- ✅ Authentication flow (DONE)
- ✅ Navigation/routing (DONE)
- ✅ Theme system (DONE)
- ✅ Error handling (DONE)
- ⬜ Profile & Settings (IN PROGRESS)

### Phase 2: Core UX (Week 3-4)
- ⬜ Analytics dashboard
- ⬜ Notification system
- ⬜ Enhanced journal features

### Phase 3: Advanced (Week 5-6)
- ⬜ Psychometric games
- ⬜ Goal tracking
- ⬜ Community features

---

## 💡 **Quick Commands Reference**

### Build APK:
```bash
cd soul_fresh
flutter build apk --release
```

### Start Backend:
```bash
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
```

### Run Tests:
```bash
flutter test
```

### Analyze Code:
```bash
flutter analyze
```

### Generate Code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🎯 **Success Metrics**

By end of this week, you should have:
- ✅ Working APK with network connectivity
- ✅ Complete auth flow (signup → OTP → login → persistence)
- ✅ Integrated router with all screens
- ✅ Profile screen with logout
- ✅ Settings screen with preferences
- ✅ Privacy settings screen

**Next Week Goal**: Analytics dashboard showing mood trends and insights.

---

**Start with testing the APK build, then integrate the router, then build the profile screens. Take it one step at a time!** 🚀
