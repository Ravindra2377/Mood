import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/self_help/self_help_models.dart';
import '../utils/self_help_algorithms.dart';
import '../services/self_help_storage_service.dart';

// ============================================
// STATE
// ============================================

class ThoughtRecordState {
  final int currentStep;
  final String situation;
  final String automaticThought;
  final int beliefRating;
  final Map<String, int> emotions;
  final List<String> evidenceFor;
  final List<String> evidenceAgainst;
  final List<CognitiveDistortion> detectedDistortions;
  final String alternativeThought;
  final int newBeliefRating;
  final Map<String, int> newEmotions;
  final bool isComplete;
  final List<ThoughtRecord> savedRecords;

  ThoughtRecordState({
    this.currentStep = 1,
    this.situation = '',
    this.automaticThought = '',
    this.beliefRating = 50,
    this.emotions = const {},
    this.evidenceFor = const [],
    this.evidenceAgainst = const [],
    this.detectedDistortions = const [],
    this.alternativeThought = '',
    this.newBeliefRating = 50,
    this.newEmotions = const {},
    this.isComplete = false,
    this.savedRecords = const [],
  });

  ThoughtRecordState copyWith({
    int? currentStep,
    String? situation,
    String? automaticThought,
    int? beliefRating,
    Map<String, int>? emotions,
    List<String>? evidenceFor,
    List<String>? evidenceAgainst,
    List<CognitiveDistortion>? detectedDistortions,
    String? alternativeThought,
    int? newBeliefRating,
    Map<String, int>? newEmotions,
    bool? isComplete,
    List<ThoughtRecord>? savedRecords,
  }) {
    return ThoughtRecordState(
      currentStep: currentStep ?? this.currentStep,
      situation: situation ?? this.situation,
      automaticThought: automaticThought ?? this.automaticThought,
      beliefRating: beliefRating ?? this.beliefRating,
      emotions: emotions ?? this.emotions,
      evidenceFor: evidenceFor ?? this.evidenceFor,
      evidenceAgainst: evidenceAgainst ?? this.evidenceAgainst,
      detectedDistortions: detectedDistortions ?? this.detectedDistortions,
      alternativeThought: alternativeThought ?? this.alternativeThought,
      newBeliefRating: newBeliefRating ?? this.newBeliefRating,
      newEmotions: newEmotions ?? this.newEmotions,
      isComplete: isComplete ?? this.isComplete,
      savedRecords: savedRecords ?? this.savedRecords,
    );
  }
}

// ============================================
// CONTROLLER
// ============================================

class ThoughtRecordController extends StateNotifier<ThoughtRecordState> {
  final SelfHelpStorageService _storageService;

  ThoughtRecordController(this._storageService)
      : super(ThoughtRecordState()) {
    _loadSavedRecords();
  }

  Future<void> _loadSavedRecords() async {
    final records = await _storageService.getThoughtRecords();
    state = state.copyWith(savedRecords: records);
  }

  void updateSituation(String situation) {
    state = state.copyWith(situation: situation);
  }

  void updateAutomaticThought(String thought) {
    state = state.copyWith(automaticThought: thought);
    
    // Auto-detect cognitive distortions
    final distortions = SelfHelpAlgorithms.detectDistortions(thought);
    state = state.copyWith(detectedDistortions: distortions);
  }

  void updateBeliefRating(int rating) {
    state = state.copyWith(beliefRating: rating);
  }

  void addEmotion(String emotion, int intensity) {
    final updatedEmotions = Map<String, int>.from(state.emotions);
    updatedEmotions[emotion] = intensity;
    state = state.copyWith(emotions: updatedEmotions);
  }

  void removeEmotion(String emotion) {
    final updatedEmotions = Map<String, int>.from(state.emotions);
    updatedEmotions.remove(emotion);
    state = state.copyWith(emotions: updatedEmotions);
  }

  void addEvidenceFor(String evidence) {
    final updated = [...state.evidenceFor, evidence];
    state = state.copyWith(evidenceFor: updated);
  }

  void removeEvidenceFor(int index) {
    final updated = List<String>.from(state.evidenceFor);
    updated.removeAt(index);
    state = state.copyWith(evidenceFor: updated);
  }

  void addEvidenceAgainst(String evidence) {
    final updated = [...state.evidenceAgainst, evidence];
    state = state.copyWith(evidenceAgainst: updated);
  }

  void removeEvidenceAgainst(int index) {
    final updated = List<String>.from(state.evidenceAgainst);
    updated.removeAt(index);
    state = state.copyWith(evidenceAgainst: updated);
  }

  void updateAlternativeThought(String thought) {
    state = state.copyWith(alternativeThought: thought);
  }

  void updateNewBeliefRating(int rating) {
    state = state.copyWith(newBeliefRating: rating);
  }

  void updateNewEmotions(Map<String, int> emotions) {
    state = state.copyWith(newEmotions: emotions);
  }

  void nextStep() {
    if (state.currentStep < 7) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 1 && step <= 7) {
      state = state.copyWith(currentStep: step);
    }
  }

  Future<void> saveRecord() async {
    final record = ThoughtRecord(
      situation: state.situation,
      automaticThought: state.automaticThought,
      beliefRating: state.beliefRating,
      emotions: state.emotions,
      evidenceFor: state.evidenceFor,
      evidenceAgainst: state.evidenceAgainst,
      distortions: state.detectedDistortions,
      alternativeThought: state.alternativeThought,
      newBeliefRating: state.newBeliefRating,
      newEmotions: state.newEmotions,
    );

    await _storageService.saveThoughtRecord(record);

    final updatedRecords = [record, ...state.savedRecords];
    
    state = state.copyWith(
      savedRecords: updatedRecords,
      isComplete: true,
    );
  }

  void reset() {
    state = ThoughtRecordState(savedRecords: state.savedRecords);
  }

  int get improvement => state.beliefRating - state.newBeliefRating;
}

// ============================================
// PROVIDER
// ============================================

final thoughtRecordControllerProvider =
    StateNotifierProvider<ThoughtRecordController, ThoughtRecordState>((ref) {
  final storageService = ref.watch(selfHelpStorageServiceProvider);
  return ThoughtRecordController(storageService);
});