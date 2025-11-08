import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soul/features/theme/providers/theme_provider.dart';

class _ThemeHost extends ConsumerWidget {
  const _ThemeHost({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeProvider);
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: mode,
      home: child,
    );
  }
}

void main() {
  testWidgets('Theme provider switches light/dark in app', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: _ThemeHost(child: Scaffold(body: Text('X')))),
    );

    // Default is system; assume test platform = light for assertions
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      anyOf(ThemeMode.system, ThemeMode.light),
    );

    // Set to Dark and verify brightness is dark for a descendant
  final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
    container.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
    await tester.pump();
  // Check MaterialApp's effective theme via Theme widget in tree
  expect(Theme.of(tester.element(find.text('X'))).brightness, anyOf(Brightness.dark, Brightness.light));
  // Force a rebuild by pumping frames
  await tester.pumpAndSettle();
  expect(Theme.of(tester.element(find.text('X'))).brightness, Brightness.dark);

    // Switch back to Light
    container.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
  await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('X'))).brightness, Brightness.light);
  });
}
