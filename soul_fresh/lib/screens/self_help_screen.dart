import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../features/exercises/screens/exercises_main_screen.dart';
import '../features/self_help/widgets/assessments_card.dart';
import '../features/self_help/widgets/community_support_card.dart';
import '../features/self_help/widgets/crisis_support_card.dart';
import '../features/self_help/widgets/daily_wisdom_card.dart';
import '../features/self_help/widgets/guided_pathways_card.dart';
import '../features/self_help/widgets/progress_card.dart';
import '../features/self_help/widgets/quick_check_in_card.dart';
import '../features/self_help/widgets/resources_library_card.dart';
import '../features/self_help/widgets/therapy_toolbox_card.dart';
import '../models/app_models.dart';
import '../state/ui_state.dart';

class SelfHelpScreen extends ConsumerStatefulWidget {
  static const String route = '/self-help';

  const SelfHelpScreen({super.key});

  @override
  ConsumerState<SelfHelpScreen> createState() => _SelfHelpScreenState();
}

class _SelfHelpScreenState extends ConsumerState<SelfHelpScreen> {
  int _activePromptIndex = 0;

  static const List<_SupportPrompt> _supportPrompts = <_SupportPrompt>[
    _SupportPrompt(
      id: 'ground',
      title: 'Steady your breathing',
      message: 'Take a calm pause and settle your mind with a grounding exercise.',
      actions: <_SupportAction>[
        _SupportAction(
          id: 'just_listen',
          label: 'Just listen',
          emoji: '👂',
          description: 'Open a soothing audio exercise to anchor your breathing.',
        ),
        _SupportAction(
          id: 'boost_courage',
          label: 'Boost my courage',
          emoji: '💪',
          description: 'Write down one thing you handled well today.',
        ),
        _SupportAction(
          id: 'celebrate',
          label: 'Celebrate progress',
          emoji: '🎉',
          description: 'Take a moment to acknowledge a small win in your day.',
        ),
      ],
    ),
    _SupportPrompt(
      id: 'recharge',
      title: 'Reset your focus',
      message: 'Energize gently with a quick movement or mindful exercise.',
      actions: <_SupportAction>[
        _SupportAction(
          id: 'breathing',
          label: 'Try breathing',
          emoji: '🌬️',
          description: 'Start a calming breathwork session to reset your body.',
        ),
        _SupportAction(
          id: 'movement',
          label: 'Gentle movement',
          emoji: '🧘',
          description: 'Explore a short stretch to release stored tension.',
        ),
        _SupportAction(
          id: 'gratitude',
          label: 'Gratitude note',
          emoji: '📝',
          description: 'Jot down three things you appreciate in this moment.',
        ),
      ],
    ),
    _SupportPrompt(
      id: 'celebrate',
      title: 'Notice your progress',
      message: 'Capture what is working and keep your momentum going.',
      actions: <_SupportAction>[
        _SupportAction(
          id: 'reflect',
          label: 'Reflect now',
          emoji: '🪞',
          description: 'Capture what helped you feel this way so you can repeat it.',
        ),
        _SupportAction(
          id: 'share',
          label: 'Share with someone',
          emoji: '💬',
          description: 'Tell a friend or journal entry about the progress you notice.',
        ),
        _SupportAction(
          id: 'plan',
          label: 'Plan next step',
          emoji: '🗓️',
          description: 'Pick one small action to keep the positive momentum going.',
        ),
      ],
    ),
  ];

  String get _activePromptId => _supportPrompts[_activePromptIndex].id;

  @override
  Widget build(BuildContext context) {
    final MoodLevel? mood = ref.watch(selectedMoodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Self Help'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Personalize support',
            icon: const Icon(Icons.tune),
            onPressed: _openSupportShortcuts,
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 400));
          _advancePrompt();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildSupportBanner(mood),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // 1. NEW: Progress Card (replaces AI greeting)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ProgressCard(),
              ),
            ),

            // 2. NEW: Daily Wisdom (replaces AI chat intro)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: DailyWisdomCard(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 3. NEW: Quick Check-In (replaces AI suggestions)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: QuickCheckInCard(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 4. KEEP: Therapy Toolbox (but add header)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🧰 Therapy Toolbox',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const TherapyToolboxCard(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 5. KEEP: Guided Pathways (but add header)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🗺️ Guided Pathways',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const GuidedPathwaysCard(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 6. KEEP: Assessments (but add header)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📊 Assessments',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const AssessmentsCard(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 7. KEEP: Community Support
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '👥 Community Support',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const CommunitySupportCard(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 8. KEEP: Resources Library
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📚 Resource Library',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const ResourcesLibraryCard(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 9. KEEP: Crisis Support
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CrisisSupportCard(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportBanner(MoodLevel? mood) {
    if (mood != null) {
      final String mappedId = _promptIdFromMood(mood);
      if (mappedId != _activePromptId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _setPromptById(mappedId);
        });
      }
    }

    final _SupportPrompt prompt = _supportPrompts[_activePromptIndex];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondaryPastel.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryPastel.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            prompt.title,
            style: AppTypography.h4.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.lavenderGradient,
            ),
            child: const Icon(
              Icons.self_improvement,
              size: 72,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              prompt.message,
              key: ValueKey<String>(prompt.id),
              style: AppTypography.body1.copyWith(
                color: AppColors.charcoal.withValues(alpha: 0.85),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final _SupportAction action in prompt.actions)
                ActionChip(
                  label: Text(action.label),
                  avatar: Text(action.emoji),
                  onPressed: () => _handleSupportAction(action.id),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _advancePrompt() {
    setState(() {
      _activePromptIndex = (_activePromptIndex + 1) % _supportPrompts.length;
    });
  }

  void _setPromptById(String id) {
    final int index = _supportPrompts.indexWhere((prompt) => prompt.id == id);
    if (index == -1 || index == _activePromptIndex) {
      return;
    }
    setState(() {
      _activePromptIndex = index;
    });
  }

  void _handleSupportAction(String id) {
    final _SupportAction? action = _findSupportAction(id);
    if (action == null) {
      return;
    }

    if (id == 'just_listen' || id == 'breathing' || id == 'movement') {
      Navigator.of(context).pushNamed(ExercisesMainScreen.route);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(action.description),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  _SupportAction? _findSupportAction(String id) {
    for (final _SupportPrompt prompt in _supportPrompts) {
      for (final _SupportAction action in prompt.actions) {
        if (action.id == id) {
          return action;
        }
      }
    }
    return null;
  }

  String _promptIdFromMood(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.angry:
      case MoodLevel.sad:
        return 'ground';
      case MoodLevel.neutral:
        return 'recharge';
      case MoodLevel.happy:
      case MoodLevel.veryHappy:
        return 'celebrate';
    }
  }

  Future<void> _openSupportShortcuts() async {
    final String? selection = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.mediumGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose your focus',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (int index = 0; index < _supportPrompts.length; index++) ...[
                  Builder(
                    builder: (BuildContext context) {
                      final _SupportPrompt prompt = _supportPrompts[index];
                      final bool isActive = prompt.id == _activePromptId;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(prompt.title),
                        subtitle: Text(prompt.message),
                        trailing: isActive
                            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () => Navigator.of(context).pop(prompt.id),
                      );
                    },
                  ),
                  if (index < _supportPrompts.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        );
      },
    );

    if (selection != null) {
      _setPromptById(selection);
    }
  }
}

class _SupportPrompt {
  const _SupportPrompt({
    required this.id,
    required this.title,
    required this.message,
    required this.actions,
  });

  final String id;
  final String title;
  final String message;
  final List<_SupportAction> actions;
}

class _SupportAction {
  const _SupportAction({
    required this.id,
    required this.label,
    required this.emoji,
    required this.description,
  });

  final String id;
  final String label;
  final String emoji;
  final String description;
}
