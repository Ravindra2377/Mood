import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../data/appMockData.dart';
import '../features/exercises/screens/exercises_main_screen.dart';
import '../features/self_help/data/self_help_data.dart';
import '../features/self_help/models/self_help_models.dart';
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
import '../widgets/enhanced_quote_card.dart';

class SelfHelpScreen extends ConsumerStatefulWidget {
  static const String route = '/self-help';

  const SelfHelpScreen({super.key});

  @override
  ConsumerState<SelfHelpScreen> createState() => _SelfHelpScreenState();
}

class _SelfHelpScreenState extends ConsumerState<SelfHelpScreen> {
  String? _selectedEmotion;
  double _intensity = 5;
  final Set<String> _selectedTriggers = <String>{};
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
    final ThemeData theme = Theme.of(context);
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
        border: Border.all(color: AppColors.secondaryPastel.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryPastel.withOpacity(0.22),
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
                color: AppColors.charcoal.withOpacity(0.85),
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

  Widget _buildHeader(ThemeData theme, MoodLevel? mood) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (mood != null) ...<Widget>[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.mood_outlined, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mood snapshot saved: ${mood.name.replaceAll('_', ' ')}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedEmotion = mood.name[0].toUpperCase() + mood.name.substring(1);
                    });
                  },
                  child: const Text('Use in plan'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickActions() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: quickActions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final QuickActionModel action = quickActions[index];
          return Container(
            width: 180,
            decoration: BoxDecoration(
              color: action.background,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(action.icon, color: Colors.black87),
                const Spacer(),
                Text(action.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(action.subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmotionCheckIn(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> emotions = emotionTriggerSuggestions.keys.toList();
    final List<String> triggers = _selectedEmotion == null
        ? <String>{}.toList()
        : emotionTriggerSuggestions[_selectedEmotion!] ?? <String>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.favorite_border),
                const SizedBox(width: 12),
                Text('How are you feeling right now?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final String emotion in emotions)
                  ChoiceChip(
                    label: Text(emotion),
                    selected: _selectedEmotion == emotion,
                    onSelected: (_) {
                      final bool selected = _selectedEmotion == emotion;
                      setState(() {
                        _selectedEmotion = selected ? null : emotion;
                        _selectedTriggers
                          ..clear()
                          ..addAll((emotionTriggerSuggestions[_selectedEmotion ?? ''] ?? <String>[]).take(1));
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Intensity (${_intensity.round()}/10)', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            Slider(
              value: _intensity,
              min: 1,
              max: 10,
              divisions: 9,
              label: _intensity.round().toString(),
              onChanged: (double value) => setState(() => _intensity = value),
            ),
            const SizedBox(height: 16),
            if (triggers.isNotEmpty) ...<Widget>[
              Text('What is triggering this?', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final String trigger in triggers)
                    FilterChip(
                      label: Text(trigger),
                      selected: _selectedTriggers.contains(trigger),
                      onSelected: (_) {
                        setState(() {
                          if (_selectedTriggers.contains(trigger)) {
                            _selectedTriggers.remove(trigger);
                          } else {
                            _selectedTriggers.add(trigger);
                          }
                        });
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _selectedEmotion == null ? null : () => setState(() {}),
              child: const Text('Generate personalized plan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPlanSection() {
    if (_selectedEmotion == null) {
      return const SizedBox.shrink();
    }
    final SelfHelpActionPlan? plan = emotionActionPlans[_selectedEmotion!];
    if (plan == null) {
      return const SizedBox.shrink();
    }

    Widget buildGroup(String label, List<ActionPlanStep> steps, IconData icon, Color color) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlphaFraction(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            ...steps.map(
              (ActionPlanStep step) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.check_circle_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(step.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(step.description),
                          Text('${step.minutes} min', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('📋 Personalized plan for ${plan.emotion}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(plan.context),
          const SizedBox(height: 16),
          buildGroup('Immediate relief', plan.immediate, Icons.flash_on, const Color(0xFFFFA726)),
          const SizedBox(height: 12),
          buildGroup('Process and reflect', plan.processing, Icons.psychology, const Color(0xFFAB47BC)),
          const SizedBox(height: 12),
          buildGroup('Build resilience', plan.building, Icons.fitness_center, const Color(0xFF26A69A)),
          const SizedBox(height: 12),
          buildGroup('Learn and grow', plan.learning, Icons.menu_book, const Color(0xFF29B6F6)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ExercisesMainScreen(),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start first exercise'),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, SelfHelpScreen.route),
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Save plan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedPathways() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionHeader(title: 'Guided pathways', emoji: '🗺️'),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: guidedPathways.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (BuildContext context, int index) {
                final GuidedPathway pathway = guidedPathways[index];
                return Container(
                  width: 260,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(pathway.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(pathway.focus, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: pathway.progress, minHeight: 6),
                      const SizedBox(height: 12),
                      Text('Day ${pathway.currentDay} of ${pathway.totalDays} • ${pathway.progress * 100 ~/ 1}% complete'),
                      const Spacer(),
                      FilledButton.tonal(
                        onPressed: () {},
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTherapyToolbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionHeader(title: 'Therapy toolbox', emoji: '🧰'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              for (final TherapyFramework framework in therapyFrameworks)
                Container(
                  width: 240,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: framework.color.withAlphaFraction(0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(framework.icon, color: framework.color.darken()),
                      const SizedBox(height: 8),
                      Text(framework.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(framework.description),
                      const SizedBox(height: 12),
                      ...framework.tools.map(
                        (TherapyTool tool) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.arrow_forward_ios, size: 12),
                              const SizedBox(width: 6),
                              Expanded(child: Text('${tool.title} • ${tool.subtitle}', style: const TextStyle(fontSize: 12))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Open tools'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssessments() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionHeader(title: 'Assessments', emoji: '📊'),
          const SizedBox(height: 12),
          ...assessmentCatalog.map(
            (AssessmentDescriptor descriptor) {
              final int delta = descriptor.latestScore - descriptor.previousScore;
              final String trend = delta == 0 ? 'No change' : delta < 0 ? '${delta.abs()} ↓' : '$delta ↑';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.assignment_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(descriptor.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(descriptor.subtitle),
                          const SizedBox(height: 6),
                          Text('Latest score: ${descriptor.latestScore} • $trend'),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () {},
                      child: const Text('Take'),
                    ),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Export results for therapist'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceLibrary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionHeader(title: 'Resource library', emoji: '📚'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search),
                hintText: 'Search resources, videos, podcasts',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const EnhancedQuoteCard(quote: AppMockData.quote),
          const SizedBox(height: 16),
          ...resourceHighlights.map(
            (ResourceHighlight item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(item.type.isNotEmpty ? item.type[0] : '?'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${item.type} • ${item.metadata}'),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              );
            },
          ),
          Wrap(
            spacing: 8,
            children: <Widget>[
              ActionChip(label: const Text('Anxiety'), onPressed: () {}),
              ActionChip(label: const Text('Sleep'), onPressed: () {}),
              ActionChip(label: const Text('Stress'), onPressed: () {}),
              ActionChip(label: const Text('Mindfulness'), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A237E),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('🌸 Weekly insights', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(weeklyInsight.headline, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(weeklyInsight.detail, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ...weeklyInsight.trends.map((InsightTrend trend) {
              final int delta = trend.current - trend.previous;
              final String sign = delta == 0 ? '↔' : delta < 0 ? '↓' : '↑';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text(trend.metric, style: const TextStyle(color: Colors.white70))),
                    Text('${trend.previous} → ${trend.current}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    Text(sign, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1A237E)),
              child: const Text('View detailed report'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionHeader(title: 'Community support', emoji: '👥'),
          const SizedBox(height: 12),
          ...supportCircles.map((SupportCircle circle) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(circle.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(circle.description),
                  const SizedBox(height: 8),
                  Text('${circle.members} members • Anonymous & moderated', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      FilledButton.tonal(onPressed: () {}, child: const Text('View posts')),
                      const SizedBox(width: 8),
                      TextButton(onPressed: () {}, child: const Text('Share story')),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCrisisSupport() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('🆘 Crisis support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('If you are in immediate danger, call emergency services.'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                for (final CrisisContact contact in crisisContacts)
                  Container(
                    width: 160,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: contact.color.withAlphaFraction(0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(contact.icon, color: contact.color.darken()),
                        const SizedBox(height: 8),
                        Text(contact.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(contact.description, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 12),
                        TextButton(onPressed: () {}, child: const Text('Open')),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Safety plan'),
                  const SizedBox(height: 6),
                  const Text('Warning signs • Coping strategies • People to contact'),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Review your plan'),
                  ),
                ],
              ),
            ),
          ],
        ),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String emoji;
  const _SectionHeader({required this.title, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text('$emoji $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const Spacer(),
        TextButton(onPressed: () {}, child: const Text('See all')),
      ],
    );
  }
}

extension _ColorShade on Color {
  Color darken([double amount = 0.2]) {
    final HSLColor hsl = HSLColor.fromColor(this);
    final double adjustedLightness = (hsl.lightness - amount).clamp(0.0, 1.0).toDouble();
    return hsl.withLightness(adjustedLightness).toColor();
  }

  Color withAlphaFraction(double opacity) {
    final double clamped = opacity.clamp(0.0, 1.0).toDouble();
    return withAlpha((clamped * 255).round());
  }
}
