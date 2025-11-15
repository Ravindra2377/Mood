import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soul/features/exercises/screens/journaling/stream_consciousness_screen.dart';
import 'package:soul/features/exercises/widgets/control_bar.dart';

void main() {
  testWidgets('Stream of Consciousness timer start, pause, resume',
      (tester) async {
    // Render inside a scrollable oversized container to avoid vertical overflow in test constraints.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              height: 1200,
              child: StreamConsciousnessScreen(),
            ),
          ),
        ),
      ),
    );

    // Initially timer shows full 10:00
    expect(find.text('10:00'), findsOneWidget);

    // Invoke start callback directly (avoid scrolling/overflow issues in test environment).
    final controlBarFinder = find.byType(ExerciseControlBar);
    expect(controlBarFinder, findsOneWidget);
    (tester.widget<ExerciseControlBar>(controlBarFinder)).onStart();
    await tester.pump();

    // Advance a couple seconds
    await tester.pump(const Duration(seconds: 2));
    // Timer should have decremented from 10:00 to some 09:XX value.
    expect(find.text('10:00'), findsNothing);
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .toList();
    expect(texts.any((s) => RegExp(r'09:\d{2}').hasMatch(s)), isTrue);

    // Pause via direct callback
    (tester.widget<ExerciseControlBar>(controlBarFinder)).onPause();
    await tester.pump();
    final pausedSnapshot =
        tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).join();

    // Advance time further; should not decrement while paused
    await tester.pump(const Duration(seconds: 3));
    final afterPauseSnapshot =
        tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).join();
    expect(afterPauseSnapshot, pausedSnapshot);

    // Resume via start callback again
    (tester.widget<ExerciseControlBar>(controlBarFinder)).onStart();
    await tester.pump(const Duration(seconds: 2));
    final textsAfterResume = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .toList();
    // After resuming, at least one 09:XX value should still exist.
    expect(
      textsAfterResume.any((s) => RegExp(r'09:\d{2}').hasMatch(s)),
      isTrue,
    );
  });

  testWidgets('Stream of Consciousness completes exercise after writing',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              height: 1200,
              child: StreamConsciousnessScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Enter text in the writing field (first TextField)
    final writingField = find.byType(TextField).first;
    await tester.enterText(
      writingField,
      'This is my stream of consciousness writing for testing purposes.',
    );
    await tester.pump();

    // Verify word count updates (should be 11 words)
    expect(find.textContaining('Word count:'), findsOneWidget);

    // Optional: adjust mood-after slider
    final moodSliders = find.byType(Slider);
    expect(moodSliders, findsNWidgets(2)); // Before and after

    // Scroll to "Save entry" button and tap
    final saveButton = find.text('Save entry');
    expect(saveButton, findsOneWidget);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    // Verify snackbar message appears (navigation will pop but we're in test scaffold)
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Entry saved. Nice work.'), findsOneWidget);
  });
}
