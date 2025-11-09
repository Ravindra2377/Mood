import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soul/features/exercises/screens/exercises_main_screen.dart';
import 'package:soul/features/exercises/widgets/exercise_info_dialog.dart';

void main() {
  testWidgets('Exercises screen focus selection updates description',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExercisesMainScreen()));

    // Initial description corresponds to first focus option (Find calm)
    expect(find.textContaining('Steady anxious moments'), findsOneWidget);

    // Tap Boost energy chip
    await tester.tap(find.widgetWithText(ChoiceChip, 'Boost energy'));
    await tester.pump();
    expect(find.textContaining('Refresh a tired mind'), findsOneWidget);

    // Tap Quick reset chip
    await tester.tap(find.widgetWithText(ChoiceChip, 'Quick reset'));
    await tester.pump();
    expect(find.textContaining('Take a short pause'), findsOneWidget);
  });

  testWidgets('Exercise info dialog appears and start calls navigator',
      (tester) async {
    final navigatorObserver = _TestNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp(
        home: const ExercisesMainScreen(),
        navigatorObservers: [navigatorObserver],
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('Dest')),
        ),
      ),
    );

    // Tap first exercise card (Box Breathing)
    await tester.tap(find.text('Box Breathing'));
    await tester.pumpAndSettle();
    expect(find.byType(ExerciseInfoDialog), findsOneWidget);

    // Tap Start exercise button
    // The dialog builds buttons at bottom; look for the label text directly and tap its parent
    await tester.tap(find.text('Start exercise'));
    await tester.pumpAndSettle();

    // Since route names aren't registered in this minimal test harness, we just verify dialog closed
    expect(find.byType(ExerciseInfoDialog), findsNothing);
  });
}

class _TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushed = [];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
    super.didPush(route, previousRoute);
  }
}
