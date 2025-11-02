import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/self_help/self_help_models.dart';
import '../services/self_help_storage_service.dart';

// ============================================
// STATE
// ============================================

class BehavioralActivationState {
  final BehavioralActivation? activation;
  final bool isLoading;
  final String? error;

  BehavioralActivationState({
    this.activation,
    this.isLoading = false,
    this.error,
  });

  BehavioralActivationState copyWith({
    BehavioralActivation? activation,
    bool? isLoading,
    String? error,
  }) {
    return BehavioralActivationState(
      activation: activation ?? this.activation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ============================================
// CONTROLLER
// ============================================

class BehavioralActivationController
    extends StateNotifier<BehavioralActivationState> {
  final SelfHelpStorageService _storageService;

  BehavioralActivationController(this._storageService)
      : super(BehavioralActivationState()) {
    _loadActivation();
  }

  Future<void> _loadActivation() async {
    state = state.copyWith(isLoading: true);

    try {
      final activation = await _storageService.getBehavioralActivation();
      state = state.copyWith(
        activation: activation,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void updateValues(Map<String, int> values) {
    if (state.activation == null) return;

    final updated = BehavioralActivation(
      id: state.activation!.id,
      values: values,
      activities: state.activation!.activities,
      weeklyGoal: state.activation!.weeklyGoal,
    );

    _saveActivation(updated);
  }

  void addActivity(PlannedActivity activity) {
    if (state.activation == null) {
      // Create new activation
      final activation = BehavioralActivation(
        values: {},
        activities: [activity],
        weeklyGoal: 7,
      );
      _saveActivation(activation);
      return;
    }

    final updated = BehavioralActivation(
      id: state.activation!.id,
      values: state.activation!.values,
      activities: [...state.activation!.activities, activity],
      weeklyGoal: state.activation!.weeklyGoal,
    );

    _saveActivation(updated);
  }

  void removeActivity(String activityId) {
    if (state.activation == null) return;

    final updated = BehavioralActivation(
      id: state.activation!.id,
      values: state.activation!.values,
      activities: state.activation!.activities
          .where((a) => a.id != activityId)
          .toList(),
      weeklyGoal: state.activation!.weeklyGoal,
    );

    _saveActivation(updated);
  }

  void completeActivity(String activityId, int actualMoodBoost) {
    if (state.activation == null) return;

    final updatedActivities = state.activation!.activities.map((activity) {
      if (activity.id == activityId) {
        return PlannedActivity(
          id: activity.id,
          name: activity.name,
          scheduledTime: activity.scheduledTime,
          duration: activity.duration,
          value: activity.value,
          expectedMoodBoost: activity.expectedMoodBoost,
          isCompleted: true,
          actualMoodBoost: actualMoodBoost,
        );
      }
      return activity;
    }).toList();

    final updated = BehavioralActivation(
      id: state.activation!.id,
      values: state.activation!.values,
      activities: updatedActivities,
      weeklyGoal: state.activation!.weeklyGoal,
    );

    _saveActivation(updated);
  }

  void updateWeeklyGoal(int goal) {
    if (state.activation == null) return;

    final updated = BehavioralActivation(
      id: state.activation!.id,
      values: state.activation!.values,
      activities: state.activation!.activities,
      weeklyGoal: goal,
    );

    _saveActivation(updated);
  }

  Future<void> _saveActivation(BehavioralActivation activation) async {
    try {
      await _storageService.saveBehavioralActivation(activation);
      state = state.copyWith(activation: activation);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================
// PROVIDER
// ============================================

final behavioralActivationControllerProvider = StateNotifierProvider<
    BehavioralActivationController, BehavioralActivationState>((ref) {
  final storageService = ref.watch(selfHelpStorageServiceProvider);
  return BehavioralActivationController(storageService);
});