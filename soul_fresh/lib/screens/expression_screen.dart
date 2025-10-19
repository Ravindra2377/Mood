import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/ui_state.dart';
import '../data/appMockData.dart';

// Mood enum for journal entries
enum JournalMood { angry, sad, neutral, happy, excited }

class ExpressionScreen extends ConsumerStatefulWidget {
  static const route = '/expression';

  const ExpressionScreen({super.key});

  @override
  ConsumerState<ExpressionScreen> createState() => _ExpressionScreenState();
}

class _ExpressionScreenState extends ConsumerState<ExpressionScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _textController;
  late AnimationController _animationController;
  JournalMood _selectedMood = JournalMood.neutral;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: AppMockData.journalEntryText);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getMoodEmoji(JournalMood mood) {
    switch (mood) {
      case JournalMood.angry:
        return '😠';
      case JournalMood.sad:
        return '😢';
      case JournalMood.neutral:
        return '😐';
      case JournalMood.happy:
        return '😊';
      case JournalMood.excited:
        return '🤩';
    }
  }

  Color _getMoodColor(JournalMood mood) {
    switch (mood) {
      case JournalMood.angry:
        return const Color(0xFFFF5252);
      case JournalMood.sad:
        return const Color(0xFF5C6BC0);
      case JournalMood.neutral:
        return const Color(0xFFFFCA28);
      case JournalMood.happy:
        return const Color(0xFF66BB6A);
      case JournalMood.excited:
        return const Color(0xFF26A69A);
    }
  }

  double _getCharacterPercentage() {
    return _textController.text.length / AppMockData.journalMaxCharacters;
  }

  Color _getCharacterCountColor() {
    final percentage = _getCharacterPercentage();
    if (percentage < 0.5) return Colors.grey;
    if (percentage < 0.8) return Colors.blue;
    if (percentage < 0.95) return Colors.orange;
    return Colors.red;
  }

  void _saveEntry() {
    _animationController.forward().then((_) {
      setState(() => _isSaved = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(context).extension<SoulGradients>()?.pastel ??
        const LinearGradient(colors: [Colors.blue, Colors.teal]);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  'Your expression',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                const Text(
                  'Feel free to jot down whatever comes to mind. We\'ll go through it together.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                // Mood selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'How are you feeling?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      ...JournalMood.values.map((mood) {
                        final isSelected = mood == _selectedMood;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMood = mood),
                          child: AnimatedScale(
                            scale: isSelected ? 1.3 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: isSelected
                                  ? BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _getMoodColor(mood).withOpacity(0.2),
                                      border: Border.all(
                                        color: _getMoodColor(mood),
                                        width: 2,
                                      ),
                                    )
                                  : null,
                              child: Text(
                                _getMoodEmoji(mood),
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Text area
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _getMoodColor(_selectedMood).withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            maxLines: null,
                            maxLength: AppMockData.journalMaxCharacters,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Start writing...',
                              counterText: '',
                            ),
                            style: const TextStyle(fontSize: 16),
                            onChanged: (value) {
                              ref.read(journalEntryProvider.notifier).state = value;
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Character count with progress
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: _getCharacterPercentage().clamp(0.0, 1.0),
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation(
                                    _getCharacterCountColor(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_textController.text.length}/${AppMockData.journalMaxCharacters}',
                              style: TextStyle(
                                color: _getCharacterCountColor(),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Voice button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Voice input functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8B4F0),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    icon: const Icon(Icons.mic),
                    label: const Text(
                      'Use voice instead',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Continue/Save button
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                    CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaved ? null : _saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSaved ? Colors.green : Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        disabledBackgroundColor: Colors.green,
                      ),
                      child: Text(
                        _isSaved ? '✓ Saved' : 'Save & Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SoulGradients extends ThemeExtension<SoulGradients> {
  final LinearGradient pastel;
  const SoulGradients({required this.pastel});

  @override
  SoulGradients copyWith({LinearGradient? pastel}) =>
      SoulGradients(pastel: pastel ?? this.pastel);

  @override
  ThemeExtension<SoulGradients> lerp(
    covariant ThemeExtension<SoulGradients>? other,
    double t,
  ) {
    if (other is! SoulGradients) return this;
    return t < .5 ? this : other;
  }
}