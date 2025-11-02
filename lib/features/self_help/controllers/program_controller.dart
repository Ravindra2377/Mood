import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/self_help/self_help_models.dart';
import '../services/self_help_storage_service.dart';
import '../data/guided_programs_data.dart';
import 'self_help_controller.dart';

// ============================================
// STATE
// ============================================

class ProgramState {
  final List<GuidedProgram> availablePrograms;
  final List<UserProgramEnrollment> enrollments;
  final bool isLoading;
  final String? error;

  ProgramState({
    this.availablePrograms = const [],
    this.enrollments = const [],
    this.isLoading = false,
    this.error,
  });

  ProgramState copyWith({
    List<GuidedProgram>? availablePrograms,
    List<UserProgramEnrollment>? enrollments,
    bool? isLoading,
    String? error,
  }) {
    return ProgramState(
      availablePrograms: availablePrograms ?? this.availablePrograms,
      enrollments: enrollments ?? this.enrollments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserProgramEnrollment {
  final String programId;
  final DateTime enrolledAt;
  final int currentDay;
  final List<int> completedDays;
  final bool isCompleted;

  UserProgramEnrollment({
    required this.programId,
    required this.enrolledAt,
    this.currentDay = 1,
    this.completedDays = const [],
    this.isCompleted = false,
  });

  UserProgramEnrollment copyWith({
    int? currentDay,
    List<int>? completedDays,
    bool? isCompleted,
  }) {
    return UserProgramEnrollment(
      programId: programId,
      enrolledAt: enrolledAt,
      currentDay: currentDay ?? this.currentDay,
      completedDays: completedDays ?? this.completedDays,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// ============================================
// CONTROLLER
// ============================================

class ProgramController extends StateNotifier<ProgramState> {
  final SelfHelpStorageService _storageService;

  ProgramController(this._storageService) : super(ProgramState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load available programs
      final programs = GuidedProgramsData.getAllPrograms();
      
      // Load user enrollments
      final enrollments = await _storageService.getProgramEnrollments();

      state = state.copyWith(
        availablePrograms: programs,
        enrollments: enrollments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> enrollInProgram(String programId) async {
    try {
      final enrollment = UserProgramEnrollment(
        programId: programId,
        enrolledAt: DateTime.now(),
        currentDay: 1,
        completedDays: [],
      );

      await _storageService.saveProgramEnrollment(enrollment);

      final updatedEnrollments = [...state.enrollments, enrollment];
      state = state.copyWith(enrollments: updatedEnrollments);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> completeDa(String programId, int dayNumber) async {
    try {
      final enrollmentIndex =
          state.enrollments.indexWhere((e) => e.programId == programId);
      
      if (enrollmentIndex == -1) return;

      final enrollment = state.enrollments[enrollmentIndex];
      final updatedCompletedDays = [...enrollment.completedDays, dayNumber];
      
      // Check if program is complete
      final program =
          state.availablePrograms.firstWhere((p) => p.id == programId);
      final isComplete = updatedCompletedDays.length == program.durationDays;

      final updatedEnrollment = enrollment.copyWith(
        currentDay: isComplete ? enrollment.currentDay : dayNumber + 1,
        completedDays: updatedCompletedDays,
        isCompleted: isComplete,
      );

      await _storageService.updateProgramEnrollment(updatedEnrollment);

      final updatedEnrollments = List<UserProgramEnrollment>.from(state.enrollments);
      updatedEnrollments[enrollmentIndex] = updatedEnrollment;

      state = state.copyWith(enrollments: updatedEnrollments);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  UserProgramEnrollment? getEnrollment(String programId) {
    try {
      return state.enrollments.firstWhere((e) => e.programId == programId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================
// PROVIDER
// ============================================

final programControllerProvider =
    StateNotifierProvider<ProgramController, ProgramState>((ref) {
  final storageService = ref.watch(selfHelpStorageServiceProvider);
  return ProgramController(storageService);
});