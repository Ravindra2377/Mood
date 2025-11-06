import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/routes.dart';
import '../../../state/app_state.dart';
import '../../../utils/constants.dart';
import '../../theme/providers/theme_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  bool _updatingPush = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Logout',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        await ref.read(authControllerProvider.notifier).logout();
        ref.invalidate(profileControllerProvider);
        if (!mounted) {
          return;
        }
        navigator.pushNamedAndRemoveUntil(Routes.login, (route) => false);
      } catch (e) {
        if (!mounted) {
          return;
        }
        messenger.showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  Future<void> _togglePush(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    if (_updatingPush) {
      return;
    }

    setState(() => _updatingPush = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(profileControllerProvider.notifier)
          .setPushNotifications(value);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Push notifications ${value ? 'enabled' : 'disabled'}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to update notifications: $e')),
      );
      ref.invalidate(profileControllerProvider);
    } finally {
      if (mounted) {
        setState(() => _updatingPush = false);
      }
    }
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: Constants.appName,
      applicationVersion: Constants.appVersion,
      applicationLegalese: 'Copyright ${DateTime.now().year} SOUL',
      children: const [
        SizedBox(height: 12),
        Text(Constants.appDescription),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentThemeMode = ref.watch(themeProvider);
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: profileAsync.when(
        data: (data) => _buildProfileContent(
          context,
          ref,
          data,
          currentThemeMode,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(context, ref, error),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    ProfileViewData data,
    ThemeMode currentThemeMode,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            data.avatarInitial,
            style: textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            data.displayName,
            style: textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            data.displayEmail,
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const _SectionHeader(title: 'Settings'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appearance', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_outlined),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto_outlined),
                    label: Text('System'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                    label: Text('Dark'),
                  ),
                ],
                selected: {currentThemeMode},
                onSelectionChanged: (newSelection) => ref
                    .read(themeProvider.notifier)
                    .setThemeMode(newSelection.first),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_none_outlined),
          title: const Text('Push Notifications'),
          trailing: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: _updatingPush
                ? const SizedBox(
                    key: ValueKey('push-progress'),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch.adaptive(
                    key: const ValueKey('push-switch'),
                    value: data.notifyPushEnabled,
                    onChanged: (value) => _togglePush(context, ref, value),
                  ),
          ),
        ),
        const Divider(),
        const _SectionHeader(title: 'Application'),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openLink(context, Constants.privacyPolicyUrl),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About This App'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showAbout(context),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.logout, color: theme.colorScheme.error),
          title: Text(
            'Logout',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          onTap: () => _confirmLogout(context, ref),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    Object error,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(
              'Unable to load profile',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  ref.read(profileControllerProvider.notifier).refresh(),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
