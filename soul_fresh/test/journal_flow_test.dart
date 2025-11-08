import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul/screens/journal_list.dart';
import 'package:soul/screens/journal_edit.dart';
import 'package:soul/models/journal_entry.dart';
import 'package:soul/services/journals_service.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Journal list + edit saves and appears in list', (tester) async {
    final store = InMemoryJournalStore();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: JournalListScreen(overrideStore: store),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap new entry
    await tester.tap(find.text('New entry'));
    await tester.pumpAndSettle();

    // Enter title & content
    await tester.enterText(find.byType(TextField).at(0), 'My Title');
    await tester.enterText(find.byType(TextField).at(1), 'Body content goes here');

    // Change mood
    await tester.tap(find.byWidgetPredicate((w) => w is DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('😊 Happy').last);
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    // Entry should now be visible in list
    expect(find.text('My Title'), findsOneWidget);
  });
}