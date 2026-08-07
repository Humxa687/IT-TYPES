import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings_drawer.dart';
import 'game_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animController;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const SettingsDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Quick Actions bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Moon / Sun Theme switcher
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          themeProvider.isDark ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                          key: ValueKey<bool>(themeProvider.isDark),
                          color: themeProvider.textColor,
                          size: 24,
                        ),
                      ),
                      onPressed: () => themeProvider.toggleTheme(),
                    ),
                    // Settings Drawer Trigger
                    IconButton(
                      icon: Icon(Icons.settings_outlined, color: themeProvider.textColor, size: 24),
                      onPressed: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                  ],
                ),
              ),

              // Main welcome contents
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 550),
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: themeProvider.borderColor, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: themeProvider.accentColor.withOpacity(0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Floating animated logo
                          ScaleTransition(
                            scale: _glowAnimation,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/logo.jpg'),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(color: themeProvider.accentColor, width: 2.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeProvider.accentColor.withOpacity(0.25),
                                    blurRadius: 20,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'IT TYPES 3.0',
                            style: themeProvider.getHeadingStyle(fontSize: 34, fontWeight: FontWeight.bold).copyWith(
                                  letterSpacing: 2.0,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Elevated Typing Experience',
                            style: themeProvider.getMonospaceTextStyle(fontSize: 13).copyWith(
                                  color: themeProvider.subtextColor,
                                  letterSpacing: 0.8,
                                ),
                          ),
                          const SizedBox(height: 32),

                          // Quick config stats preview
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: themeProvider.backgroundColor.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: themeProvider.borderColor.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _quickStatTile(
                                  context,
                                  'MODE',
                                  gameState.mode == GameMode.timeAttack
                                      ? 'Time Attack'
                                      : gameState.mode == GameMode.wordLimit
                                          ? 'Word Limit'
                                          : 'Sudden Death',
                                ),
                                Container(width: 1.5, height: 28, color: themeProvider.borderColor),
                                _quickStatTile(
                                  context,
                                  'DIFFICULTY',
                                  gameState.difficulty == GameDifficulty.easy
                                      ? 'Easy'
                                      : gameState.difficulty == GameDifficulty.medium
                                          ? 'Medium'
                                          : gameState.difficulty == GameDifficulty.hard
                                              ? 'Hard'
                                              : 'Code',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Animated Scale launcher button
                          MouseRegion(
                            onEnter: (_) => setState(() => _isHovered = true),
                            onExit: (_) => setState(() => _isHovered = false),
                            child: GestureDetector(
                              onTap: () {
                                gameState.initGame();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const GameScreen()),
                                );
                              },
                              child: AnimatedScale(
                                scale: _isHovered ? 1.04 : 1.0,
                                duration: const Duration(milliseconds: 150),
                                curve: Curves.easeOutBack,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  decoration: BoxDecoration(
                                    color: themeProvider.accentColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: themeProvider.accentColor.withOpacity(0.35),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'ENTER SIMULATOR',
                                        style: themeProvider.getHeadingStyle(fontSize: 16, fontWeight: FontWeight.bold).copyWith(
                                              color: themeProvider.isDark ? Colors.black87 : Colors.white,
                                              letterSpacing: 1.0,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: themeProvider.isDark ? Colors.black87 : Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickStatTile(BuildContext context, String label, String val) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Column(
      children: [
        Text(
          label,
          style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(color: themeProvider.subtextColor),
        ),
        const SizedBox(height: 4),
        Text(
          val.toUpperCase(),
          style: themeProvider.getHeadingStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
