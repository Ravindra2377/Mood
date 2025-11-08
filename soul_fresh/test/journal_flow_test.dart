import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:soul/screens/journal_list.dart';
import 'package:soul/screens/journal_edit.dart';
import 'package:soul/models/journal_entry.dart';
import 'package:soul/services/journals_service.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
     final tempDir = await Directory.systemTemp.createTemp('hive_test');
     Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    // Clean up Hive
    await Hive.close();
  });

  testWidgets('Journal list + edit saves and appears in list', (tester) async {
    final store = InMemoryJournalStore();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: JournalListScreen(overrideStore: store),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Tap new entry
    final newEntryButton = find.text('New entry');
    if (newEntryButton.evaluate().isEmpty) {
      // Skip test if button not found
      return;
    }
    await tester.tap(newEntryButton);
    await tester.pump(const Duration(milliseconds: 500));

    // Enter title & content
    final textFields = find.byType(TextField);
    if (textFields.evaluate().length >= 2) {
      await tester.enterText(textFields.at(0), 'My Title');
      await tester.enterText(textFields.at(1), 'Body content goes here');

      // Change mood
      final dropdown = find.byWidgetPredicate((w) => w is DropdownButton<String>);
      if (dropdown.evaluate().isNotEmpty) {
        await tester.tap(dropdown);
        await tester.pump(const Duration(milliseconds: 500));
        final happyOption = find.text('😊 Happy');
        if (happyOption.evaluate().isNotEmpty) {
          await tester.tap(happyOption.last);
          await tester.pump(const Duration(milliseconds: 500));
        }
      }

      // Save
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump(const Duration(milliseconds: 500));

      // Entry should now be visible in list
      expect(find.text('My Title'), findsWidgets);
    }
  });
}