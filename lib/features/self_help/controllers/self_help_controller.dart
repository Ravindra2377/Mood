import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/self_help/self_help_models.dart';
import '../utils/self_help_algorithms.dart';
import '../services/self_help_storage_service.dart';

// ============================================
// STATE CLASSES
// ============================================

class SelfHelpState {
  final UserProgress progress;
  final List<UserAssessment> assessments;
  final PersonalizedPlan? currentPlan;
  final bool isLoading;
  final String? error;

  SelfHelpState({
    required this.progress,
    this.assessments = const [],
    this.currentPlan,
    this.isLoading = false,
    this.error,
  });

  SelfHelpState copyWith({
    UserProgress? progress,
    List<UserAssessment>? assessments,
    PersonalizedPlan? currentPlan,
    bool? isLoading,
    String? error,
  }) {
    return SelfHelpState(
      progress: progress ?? this.progress,
      assessments: assessments ?? this.assessments,
      currentPlan: currentPlan ?? this.currentPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ============================================
// MAIN CONTROLLER
// ============================================

class SelfHelpController extends StateNotifier<SelfHelpState> {
  final SelfHelpStorageService _storageService;

  SelfHelpController(this._storageService)
      : super(SelfHelpState(
          progress: UserProgress(userId: 'current_user'),
        )) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load progress
      final progress = await _storageService.getProgress();
      
      // Load recent assessments
      final assessments = await _storageService.getRecentAssessments(limit: 7);
      
      // Detect patterns and generate insights
      final insights = SelfHelpAlgorithms.detectPatterns(progress);
      final updatedProgress = UserProgress(
        userId: progress.userId,
        currentStreak: progress.currentStreak,
        longestStreak: progress.longestStreak,
        totalActivitiesCompleted: progress.totalActivitiesCompleted,
        totalTimeInvested: progress.totalTimeInvested,
        moodTrend: progress.moodTrend,
        insights: insights,
        dimensions: progress.dimensions,
      );

      state = state.copyWith(
        progress: updatedProgress,
        assessments: assessments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> saveAssessment(UserAssessment assessment) async {
    try {
      // Save to storage
      await _storageService.saveAssessment(assessment);

      // Update assessments list
      final updatedAssessments = [assessment, ...state.assessments];

      // Generate personalized plan
      final plan = SelfHelpAlgorithms.generatePlan(assessment);

      // Update progress (increment activities, update mood trend)
      final updatedProgress = _updateProgressFromAssessment(assessment);

      state = state.copyWith(
        assessments: updatedAssessments,
        currentPlan: plan,
        progress: updatedProgress,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  UserProgress _updateProgressFromAssessment(UserAssessment assessment) {
    final currentProgress = state.progress;
    
    // Add mood to trend
    final dateKey = assessment.timestamp.toIso8601String().split('T')[0];
    final moodScore = _moodToScore(assessment.mood);
    final updatedMoodTrend = {
      ...currentProgress.moodTrend,
      dateKey: moodScore,
    };

    // Update streak (check if logged today)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final assessmentDate = DateTime(
      assessment.timestamp.year,
      assessment.timestamp.month,
      assessment.timestamp.day,
    );
    
    int newStreak = currentProgress.currentStreak;
    if (assessmentDate == today) {
      newStreak = currentProgress.currentStreak + 1;
    }

    return UserProgress(
      userId: currentProgress.userId,
      currentStreak: newStreak,
      longestStreak: newStreak > currentProgress.longestStreak 
          ? newStreak 
          : currentProgress.longestStreak,
      totalActivitiesCompleted: currentProgress.totalActivitiesCompleted + 1,
      totalTimeInvested: currentProgress.totalTimeInvested,
      moodTrend: updatedMoodTrend,
      insights: currentProgress.insights,
      dimensions: currentProgress.dimensions,
    );
  }

  int _moodToScore(MoodType mood) {
    switch (mood) {
      case MoodType.great:
        return 10;
      case MoodType.good:
        return 8;
      case MoodType.okay:
        return 6;
      case MoodType.notGood:
        return 4;
      case MoodType.bad:
        return 2;
      case MoodType.crisis:
        return 1;
    }
  }

  Future<void> completeActivity(String activityId, Duration duration) async {
    try {
      final updatedProgress = UserProgress(
        userId: state.progress.userId,
        currentStreak: state.progress.currentStreak,
        longestStreak: state.progress.longestStreak,
        totalActivitiesCompleted: state.progress.totalActivitiesCompleted + 1,
        totalTimeInvested: state.progress.totalTimeInvested + duration,
        moodTrend: state.progress.moodTrend,
        insights: state.progress.insights,
        dimensions: state.progress.dimensions,
      );

      await _storageService.saveProgress(updatedProgress);
      
      state = state.copyWith(progress: updatedProgress);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateDimensions(Map<String, int> dimensions) async {
    try {
      final updatedProgress = UserProgress(
        userId: state.progress.userId,
        currentStreak: state.progress.currentStreak,
        longestStreak: state.progress.longestStreak,
        totalActivitiesCompleted: state.progress.totalActivitiesCompleted,
        totalTimeInvested: state.progress.totalTimeInvested,
        moodTrend: state.progress.moodTrend,
        insights: state.progress.insights,
        dimensions: dimensions,
      );

      await _storageService.saveProgress(updatedProgress);
      
      state = state.copyWith(progress: updatedProgress);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refresh() async {
    await _loadInitialData();
  }
}

// ============================================
// PROVIDERS
// ============================================

final selfHelpStorageServiceProvider = Provider<SelfHelpStorageService>((ref) {
  return SelfHelpStorageService();
});

final selfHelpControllerProvider =
    StateNotifierProvider<SelfHelpController, SelfHelpState>((ref) {
  final storageService = ref.watch(selfHelpStorageServiceProvider);
  return SelfHelpController(storageService);
});

// Convenience providers
final userProgressProvider = Provider<UserProgress>((ref) {
  return ref.watch(selfHelpControllerProvider).progress;
});

final personalizedPlanProvider = Provider<PersonalizedPlan?>((ref) {
  return ref.watch(selfHelpControllerProvider).currentPlan;
});

final recentAssessmentsProvider = Provider<List<UserAssessment>>((ref) {
  return ref.watch(selfHelpControllerProvider).assessments;
});

final latestAssessmentProvider = Provider<AsyncValue<UserAssessment?>>((ref) {
  final assessments = ref.watch(recentAssessmentsProvider);
  return AsyncValue.data(assessments.isNotEmpty ? assessments.first : null);
});