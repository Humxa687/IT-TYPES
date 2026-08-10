import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_state.dart';
import 'providers/theme_provider.dart';
import 'screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GameState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    // Return the child directly without wrapping in a scrollbar, hiding all scrollbars globally
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We don't use standard MaterialApp theme for background and text,
    // instead, our screens listen to ThemeProvider directly for colors & fonts.
    return MaterialApp(
      title: 'IT TYPES',
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark, // Default base brightness
      ),
      home: const GameScreen(),
    );
  }
}
