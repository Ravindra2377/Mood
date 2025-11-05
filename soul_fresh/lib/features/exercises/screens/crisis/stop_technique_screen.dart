import 'package:flutter/material.dart';
import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/exercise_scaffold.dart';

class StopTechniqueScreen extends StatefulWidget {
  static const route = '/stop_technique';

  const StopTechniqueScreen({super.key});
  @override
  State<StopTechniqueScreen> createState() => _StopTechniqueScreenState();
}

class _StopTechniqueScreenState extends State<StopTechniqueScreen> {
  late ExerciseSession session;
  final phases = ['Stop', 'Take a step back', 'Observe', 'Proceed mindfully'];
  int idx = 0;

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
        exerciseId: 'stop_technique', startTime: DateTime.now(),);
  }

  void _next() {
    if (idx < phases.length - 1) {
      setState(() => idx++);
    } else {
      _complete();
    }
  }

  void _complete() async {
    session.endTime = DateTime.now();
    await ExerciseService().saveSession(session);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseScaffold(
      title: 'STOP Technique',
      subtitle: phases[idx],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            phases[idx],
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _next,
            child: Text(idx < phases.length - 1 ? 'Next' : 'Finish'),
          ),
        ],
      ),
    );
  }
}
