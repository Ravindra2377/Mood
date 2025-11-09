import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/journal_entry.dart';
import '../services/journals_service.dart';
import '../state/app_state.dart';
import '../state/ui_state.dart';

// Mood enum for journal entries
enum JournalMood { angry, sad, neutral, happy, excited }

// Mood intensity enum
enum MoodIntensity { slight, mild, moderate, strong, veryStrong }

// Trigger categories
enum MoodTrigger {
  work,
  relationships,
  health,
  money,
  sleep,
  weather,
  socialMedia,
  news,
  other
}

// Privacy levels
enum PrivacyLevel { private, anonymous, therapist }

class ExpressionScreen extends ConsumerStatefulWidget {
  static const route = '/expression';

  const ExpressionScreen({super.key});

  @override
  ConsumerState<ExpressionScreen> createState() => _ExpressionScreenState();
}

class _ExpressionScreenState extends ConsumerState<ExpressionScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxCharacters = 240;

  late final TextEditingController _textController;
  late AnimationController _animationController;
  late Future<JournalsService> _journalsService;
  JournalMood _selectedMood = JournalMood.neutral;
  MoodIntensity _moodIntensity = MoodIntensity.moderate;
  bool _isSaved = false;
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();
  final TimeOfDay _selectedTime = TimeOfDay.now();
  final Set<MoodTrigger> _selectedTriggers = {};
  final List<String> _tags = [];
  PrivacyLevel _privacyLevel = PrivacyLevel.private;
  final TextEditingController _tagController = TextEditingController();
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: ref.read(journalEntryProvider),
    );
    _journalsService =
        JournalsService.create(apiClient: ref.read(apiClientProvider));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _tagController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getMoodEmoji(JournalMood mood) {
    switch (mood) {
      case JournalMood.angry:
        return 'ðŸ˜ ';
      case JournalMood.sad:
        return 'ðŸ˜¢';
      case JournalMood.neutral:
        return 'ðŸ˜';
      case JournalMood.happy:
        return 'ðŸ˜Š';
      case JournalMood.excited:
        return 'ðŸ¤©';
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
    return _textController.text.length / _maxCharacters;
  }

  Color _getCharacterCountColor() {
    final percentage = _getCharacterPercentage();
    if (percentage < 0.5) return Colors.grey;
    if (percentage < 0.8) return Colors.blue;
    if (percentage < 0.95) return Colors.orange;
    return Colors.red;
  }

  String _createEntryTitle(JournalMood mood, DateTime timestamp) {
    final formatted = DateFormat('MMM d, yyyy â€¢ h:mm a').format(timestamp);
    return '${_getMoodLabel(mood)} â€¢ $formatted';
  }

  void _saveEntry() async {
    if (_isSaving) return;

    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a note before saving.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final DateTime entryTimestamp = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      final JournalsService service = await _journalsService;
      final entry = JournalEntry(
        id: '',
        title: _createEntryTitle(_selectedMood, entryTimestamp),
        content: text,
        mood: _selectedMood.name,
        createdAt: entryTimestamp,
        updatedAt: entryTimestamp,
      );

      await service.save(entry);

      ref.read(journalEntryProvider.notifier).state = '';
      _textController.clear();

      setState(() {
        _isSaving = false;
        _isSaved = true;
      });

      await _animationController.forward(from: 0);
      _animationController.reset();

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save entry. Please try again.'),
        ),
      );
    }
  }

  String _getMoodLabel(JournalMood mood) {
    switch (mood) {
      case JournalMood.angry:
        return 'Angry';
      case JournalMood.sad:
        return 'Sad';
      case JournalMood.neutral:
        return 'Neutral';
      case JournalMood.happy:
        return 'Happy';
      case JournalMood.excited:
        return 'Excited';
    }
  }

  String _getIntensityLabel(MoodIntensity intensity) {
    switch (intensity) {
      case MoodIntensity.slight:
        return 'Slight';
      case MoodIntensity.mild:
        return 'Mild';
      case MoodIntensity.moderate:
        return 'Moderate';
      case MoodIntensity.strong:
        return 'Strong';
      case MoodIntensity.veryStrong:
        return 'Very Strong';
    }
  }

  String _getTriggerLabel(MoodTrigger trigger) {
    switch (trigger) {
      case MoodTrigger.work:
        return 'Work/School';
      case MoodTrigger.relationships:
        return 'Relationships';
      case MoodTrigger.health:
        return 'Health';
      case MoodTrigger.money:
        return 'Money';
      case MoodTrigger.sleep:
        return 'Sleep';
      case MoodTrigger.weather:
        return 'Weather';
      case MoodTrigger.socialMedia:
        return 'Social Media';
      case MoodTrigger.news:
        return 'News';
      case MoodTrigger.other:
        return 'Other';
    }
  }

  String _getWritingPrompt(JournalMood mood) {
    switch (mood) {
      case JournalMood.angry:
        return 'What triggered this emotion?';
      case JournalMood.sad:
        return 'What\'s making you feel this way?';
      case JournalMood.neutral:
        return 'What would make today better?';
      case JournalMood.happy:
        return 'What made you smile today?';
      case JournalMood.excited:
        return 'What are you looking forward to?';
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(context).extension<SoulGradients>()?.pastel ??
        const LinearGradient(colors: [Colors.blue, Colors.teal]);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Title
                const Text(
                  'Your expression',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                const Text(
                  'Feel free to jot down whatever comes to mind. We\'ll go through it together.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // ===== DATE & TIME SELECTOR =====
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _getMoodColor(_selectedMood).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: _getMoodColor(_selectedMood),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)} â€¢ ${_selectedTime.format(context)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Icon(Icons.edit, size: 16, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ===== MOOD SELECTOR WITH LABELS & INTENSITY =====
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How are you feeling?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Mood emojis with labels
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: JournalMood.values.map((mood) {
                          final isSelected = mood == _selectedMood;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedMood = mood),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? _getMoodColor(mood)
                                            .withOpacity(0.2)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? _getMoodColor(mood)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    _getMoodEmoji(mood),
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                if (isSelected)
                                  Text(
                                    _getMoodLabel(mood),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _getMoodColor(mood),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      // Mood intensity slider
                      Text(
                        'Intensity: ${_getIntensityLabel(_moodIntensity)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Slider(
                        value: _moodIntensity.index.toDouble(),
                        max: 4,
                        divisions: 4,
                        activeColor: _getMoodColor(_selectedMood),
                        onChanged: (value) {
                          setState(() {
                            _moodIntensity =
                                MoodIntensity.values[value.toInt()];
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ===== WRITING PROMPT =====
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      const Text('ðŸ’¡', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getWritingPrompt(_selectedMood),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ===== TEXT AREA =====
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            _getMoodColor(_selectedMood).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _textController,
                        maxLines: 6,
                        maxLength: _maxCharacters,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Start writing...',
                          counterText: '',
                        ),
                        style: const TextStyle(fontSize: 14),
                        onChanged: (value) {
                          ref.read(journalEntryProvider.notifier).state = value;
                          setState(() => _isSaved = false);
                        },
                      ),
                      const SizedBox(height: 12),
                      // Character count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value:
                                    _getCharacterPercentage().clamp(0.0, 1.0),
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
                            '${_textController.text.length}/$_maxCharacters',
                            style: TextStyle(
                              color: _getCharacterCountColor(),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ===== TAGS SECTION =====
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'ðŸ·ï¸ Tags',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _addTag(_tagController.text),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getMoodColor(_selectedMood),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _tagController,
                        onSubmitted: _addTag,
                        decoration: InputDecoration(
                          hintText: 'e.g., Work, Health, Family',
                          contentPadding: const EdgeInsets.all(8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (_tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: _tags
                              .map(
                                (tag) => Chip(
                                  label: Text(
                                    tag,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  onDeleted: () => _removeTag(tag),
                                  backgroundColor: _getMoodColor(_selectedMood)
                                      .withOpacity(0.2),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ===== ADVANCED OPTIONS TOGGLE =====
                GestureDetector(
                  onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _showAdvanced ? Icons.expand_less : Icons.expand_more,
                          size: 20,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'More options',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showAdvanced) ...[
                  const SizedBox(height: 12),
                  // ===== MOOD TRIGGERS =====
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What influenced your mood?',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: MoodTrigger.values.map((trigger) {
                            final isSelected =
                                _selectedTriggers.contains(trigger);
                            return FilterChip(
                              label: Text(
                                _getTriggerLabel(trigger),
                                style: const TextStyle(fontSize: 10),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTriggers.add(trigger);
                                  } else {
                                    _selectedTriggers.remove(trigger);
                                  }
                                });
                              },
                              backgroundColor: Colors.transparent,
                              selectedColor: Colors.blue.shade200,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ===== PRIVACY LEVEL =====
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy level',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: PrivacyLevel.values.map((level) {
                            return RadioMenuButton<PrivacyLevel>(
                              value: level,
                              groupValue: _privacyLevel,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _privacyLevel = value);
                                }
                              },
                              child: Text(
                                level == PrivacyLevel.private
                                    ? 'Private (only you)'
                                    : level == PrivacyLevel.anonymous
                                        ? 'Share anonymously'
                                        : 'Share with therapist',
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // ===== VOICE BUTTON =====
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8B4F0),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: const Icon(Icons.mic, size: 18),
                    label: const Text(
                      'Use voice instead',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ===== SAVE BUTTON =====
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (_isSaved || _isSaving) ? null : _saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSaved ? Colors.green : Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        disabledBackgroundColor: _isSaved
                            ? Colors.green
                            : Colors.black.withOpacity(0.6),
                      ),
                      child: _isSaving
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Saving...',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _isSaved ? 'âœ“ Saved' : 'Save & Continue',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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

