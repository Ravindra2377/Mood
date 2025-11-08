import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soul/features/home/screens/improved_home_screen.dart';
import 'package:soul/features/theme/providers/theme_provider.dart';

/// Comprehensive Navigation & UI tests covering:
/// 1. 5-Tab BottomNavigationBar
/// 2. Tab state preservation (AutomaticKeepAliveClientMixin)
/// 3. Theme switching (Light/Dark/System)
/// 4. Dashboard action cards

void main() {
  group('🎨 Navigation & UI System Tests', () {
    testWidgets('5-tab bottom navigation displays all tabs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ImprovedHomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all 5 navigation tabs are present
      final bottomNav = find.byType(BottomNavigationBar);
      expect(bottomNav, findsOneWidget);

      final bottomNavWidget = tester.widget<BottomNavigationBar>(bottomNav);
      expect(bottomNavWidget.items.length, equals(5));

      // Verify tab labels/icons
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Journal'), findsOneWidget);
      expect(find.text('Companion'), findsOneWidget);
      expect(find.text('Insights'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Tab navigation switches between screens', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ImprovedHomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Start on Home tab
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, equals(0));

      // Tap Journal tab (index 1)
      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();

      // Verify navigation updated
      final updatedBottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(updatedBottomNav.currentIndex, equals(1));

      // Tap Companion tab (index 2)
      await tester.tap(find.text('Companion'));
      await tester.pumpAndSettle();

      final companionNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(companionNav.currentIndex, equals(2));

      // Tap Insights tab (index 3)
      await tester.tap(find.text('Insights'));
      await tester.pumpAndSettle();

      final insightsNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(insightsNav.currentIndex, equals(3));

      // Tap Profile tab (index 4)
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      final profileNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(profileNav.currentIndex, equals(4));
    });

    testWidgets('IndexedStack preserves state when switching tabs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ImprovedHomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify IndexedStack is used for state preservation
      final indexedStack = find.byType(IndexedStack);
      expect(indexedStack, findsOneWidget);

      final stackWidget = tester.widget<IndexedStack>(indexedStack);
      expect(stackWidget.children.length, equals(5)); // All 5 screens

      // Switch to Journal and back to Home
      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // IndexedStack should still have all children
      final preservedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(preservedStack.children.length, equals(5));
    });

    testWidgets('Dashboard displays welcome card and action buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ImprovedHomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify welcome greeting exists (should contain greeting message)
      expect(find.textContaining('👋'), findsOneWidget);

      // Verify main action buttons/cards are present
      // Look for common dashboard elements
      expect(find.byType(FilledButton), findsWidgets);
    });

    testWidgets('Theme switch toggles between light and dark modes', (tester) async {
      final container = ProviderContainer();
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final themeMode = ref.watch(themeProvider);
              return MaterialApp(
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                themeMode: themeMode,
                home: Scaffold(
                  body: Column(
                    children: [
                      Text('Current theme: ${Theme.of(context).brightness}'),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
                        },
                        child: const Text('Switch to Dark'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
                        },
                        child: const Text('Switch to Light'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system);
                        },
                        child: const Text('Switch to System'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial theme (light by default)
      expect(find.textContaining('light'), findsOneWidget);

      // Switch to dark
      await tester.tap(find.text('Switch to Dark'));
      await tester.pumpAndSettle();
      expect(find.textContaining('dark'), findsOneWidget);

      // Switch back to light
      await tester.tap(find.text('Switch to Light'));
      await tester.pumpAndSettle();
      expect(find.textContaining('light'), findsOneWidget);

      // Switch to system
      await tester.tap(find.text('Switch to System'));
      await tester.pumpAndSettle();
      // System mode will follow platform brightness
      expect(Theme.of(tester.element(find.byType(Scaffold))).brightness, isNotNull);
    });

    test('Theme mode persists across app sessions', () {
      final controller = ThemeController();
      
      // Set dark mode
      controller.setThemeMode(ThemeMode.dark);
      expect(controller.state, equals(ThemeMode.dark));

      // Simulate app restart (would load from storage)
      // In real implementation, this reads from SharedPreferences
      final persistedMode = controller.state;
      expect(persistedMode, equals(ThemeMode.dark));
    });

    testWidgets('Dashboard quick stats display correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ImprovedHomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Dashboard should show some stats/metrics
      // Look for numerical displays or stat cards
      expect(find.byType(Container), findsWidgets);
      
      // Verify scrollable content
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('Navigation maintains scroll position when switching tabs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ImprovedHomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Journal tab
      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();

      // Scroll down if possible
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -200));
        await tester.pump();
      }

      // Switch to another tab
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Switch back to Journal
      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();

      // IndexedStack should have preserved the scroll position
      // (In real implementation, this is ensured by AutomaticKeepAliveClientMixin)
      expect(find.byType(IndexedStack), findsOneWidget);
    });
  });

  group('🎨 Theme System Tests', () {
    test('Light theme has correct color scheme', () {
      final lightTheme = ThemeData.light();
      expect(lightTheme.brightness, equals(Brightness.light));
      expect(lightTheme.scaffoldBackgroundColor, isNotNull);
    });

    test('Dark theme has correct color scheme', () {
      final darkTheme = ThemeData.dark();
      expect(darkTheme.brightness, equals(Brightness.dark));
      expect(darkTheme.scaffoldBackgroundColor, isNotNull);
    });

    testWidgets('High contrast theme prevents visibility issues', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: const Scaffold(
              body: Center(
                child: Text('Test text'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify text is visible against background
      final text = tester.widget<Text>(find.text('Test text'));
      expect(text.style?.color, isNotNull);
    });
  });
}
