import '../models/exercise_models.dart';

class ExerciseService {
  // Singleton pattern
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();

  final List<ExerciseSession> _sessions = [];

  Future<void> saveSession(ExerciseSession session) async {
    _sessions.add(session);
    // TODO: Persist session to backend API
  }

  List<ExerciseSession> getUserSessions() => List.unmodifiable(_sessions);

  int getStreakDays() {
    if (_sessions.isEmpty) return 0;
    final days = _sessions
        .map((s) =>
            DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 1;
    for (var i = 0; i < days.length - 1; i++) {
      if (days[i].difference(days[i + 1]).inDays == 1)
        streak++;
      else
        break;
    }
    return streak;
  }

  Duration getTotalExerciseTime() {
    return _sessions.fold(Duration.zero, (sum, s) => sum + s.duration);
  }
}
