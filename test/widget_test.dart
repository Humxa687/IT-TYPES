import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:it_types/main.dart';
import 'package:it_types/providers/game_state.dart';
import 'package:it_types/providers/theme_provider.dart';

void main() {
  testWidgets('Typing Game initial screen loads test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => GameState()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the Reset Simulator button exists.
    expect(find.text('RESET SIMULATOR'), findsOneWidget);
  });
}
