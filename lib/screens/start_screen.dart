import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings_drawer.dart';
import 'game_screen.dart';
import 'stats_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _logoAnimController;
  late Animation<double> _logoGlowAnimation;
  
  bool _isEnterHovered = false;
  double _difficultyScale = 1.0;

  @override
  void initState() {
    super.initState();
    _logoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _logoGlowAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _logoAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _logoAnimController.dispose();
    super.dispose();
  }

  void _cycleDifficulty(GameState state) {
    setState(() {
      _difficultyScale = 0.9;
    });
    
    final nextIndex = (state.difficulty.index + 1) % GameDifficulty.values.length;
    state.setDifficulty(GameDifficulty.values[nextIndex]);
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _difficultyScale = 1.05;
        });
        Future.delayed(const Duration(milliseconds: 80), () {
          if (mounted) {
            setState(() {
              _difficultyScale = 1.0;
            });
          }
        });
      }
    });
  }

  IconData _getDifficultyIcon(GameDifficulty diff) {
    switch (diff) {
      case GameDifficulty.easy:
        return Icons.child_care_rounded;
      case GameDifficulty.medium:
        return Icons.keyboard_alt_outlined;
      case GameDifficulty.hard:
        return Icons.psychology_rounded;
      case GameDifficulty.code:
        return Icons.code_rounded;
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          themeProvider.isDark ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                          key: ValueKey<bool>(themeProvider.isDark),
                          color: themeProvider.textColor,
                          size: 22,
                        ),
                      ),
                      onPressed: () => themeProvider.toggleTheme(),
                    ),
                    Row(
                      children: [
                        // Career Stats dashboard icon
                        IconButton(
                          icon: Icon(Icons.bar_chart_rounded, color: themeProvider.textColor, size: 24),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StatsScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.settings_outlined, color: themeProvider.textColor, size: 22),
                          onPressed: () {
                            _scaffoldKey.currentState?.openEndDrawer();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main welcome content container
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: themeProvider.borderColor, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: themeProvider.accentColor.withOpacity(0.06),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Breathing Vector Logo
                          ScaleTransition(
                            scale: _logoGlowAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: themeProvider.accentColor.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.keyboard_double_arrow_right_rounded,
                                size: 44,
                                color: themeProvider.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'IT TYPES',
                            style: themeProvider.getHeadingStyle(fontSize: 32, fontWeight: FontWeight.bold).copyWith(
                                  letterSpacing: 2.0,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Elevated Typing Experience',
                            style: themeProvider.getMonospaceTextStyle(fontSize: 12).copyWith(
                                  color: themeProvider.subtextColor,
                                  letterSpacing: 0.8,
                                ),
                          ),
                          const SizedBox(height: 28),

                          // Mode selection ribbon (Side-by-side)
                          _buildModeRibbon(context, gameState),
                          const SizedBox(height: 16),

                          // Dynamic Inline Parameter Selector (Time / Word options)
                          _buildParameterSelector(context, gameState),
                          const SizedBox(height: 24),

                          // Animated Difficulty Card (Normal Casing)
                          _buildDifficultyCard(context, gameState),
                          const SizedBox(height: 32),

                          // Interactive Launcher Button
                          MouseRegion(
                            onEnter: (_) => setState(() => _isEnterHovered = true),
                            onExit: (_) => setState(() => _isEnterHovered = false),
                            child: GestureDetector(
                              onTap: () {
                                gameState.initGame();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const GameScreen()),
                                );
                              },
                              child: AnimatedScale(
                                scale: _isEnterHovered ? 1.04 : 1.0,
                                duration: const Duration(milliseconds: 150),
                                curve: Curves.easeOutBack,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                                        style: themeProvider.getHeadingStyle(fontSize: 15, fontWeight: FontWeight.bold).copyWith(
                                              color: themeProvider.isDark ? Colors.black87 : Colors.white,
                                              letterSpacing: 1.0,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: themeProvider.isDark ? Colors.black87 : Colors.white,
                                        size: 16,
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

  Widget _buildModeRibbon(BuildContext context, GameState state) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: GameMode.values.map((mode) {
          final isSelected = state.mode == mode;
          final label = mode == GameMode.timeAttack
              ? 'TIME'
              : mode == GameMode.wordLimit
                  ? 'WORDS'
                  : 'SUDDEN';

          return Expanded(
            child: InkWell(
              onTap: () => state.setMode(mode),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? themeProvider.accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  style: themeProvider.getMonospaceTextStyle(fontSize: 10, fontWeight: FontWeight.bold).copyWith(
                        color: isSelected
                            ? (themeProvider.isDark ? Colors.black87 : Colors.white)
                            : themeProvider.textColor.withOpacity(0.7),
                        letterSpacing: 0.5,
                      ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildParameterSelector(BuildContext context, GameState state) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    if (state.mode == GameMode.suddenDeath) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'INSTANT FAILURE ON ERROR',
          style: themeProvider.getMonospaceTextStyle(fontSize: 10, fontWeight: FontWeight.bold).copyWith(
                color: themeProvider.incorrectCharColor.withOpacity(0.8),
                letterSpacing: 0.8,
              ),
        ),
      );
    }

    // 0 represents Unlimited (∞)
    final List<int> options = state.mode == GameMode.timeAttack
        ? [0, 15, 30, 60, 120]
        : [10, 25, 50, 100];

    final int currentValue = state.mode == GameMode.timeAttack
        ? state.timeLimitSec
        : state.wordLimitCount;

    final String suffix = state.mode == GameMode.timeAttack ? 's' : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: options.map((val) {
        final isSelected = val == currentValue;
        final labelText = (state.mode == GameMode.timeAttack && val == 0) ? '∞' : '$val$suffix';

        return ChoiceChip(
          label: Text(
            labelText,
            style: themeProvider.getMonospaceTextStyle(fontSize: 11, fontWeight: FontWeight.bold).copyWith(
                  color: isSelected
                      ? (themeProvider.isDark ? Colors.black87 : Colors.white)
                      : themeProvider.textColor.withOpacity(0.8),
                ),
          ),
          selected: isSelected,
          selectedColor: themeProvider.accentColor,
          backgroundColor: themeProvider.cardColor.withOpacity(0.5),
          onSelected: (selected) {
            if (selected) {
              if (state.mode == GameMode.timeAttack) {
                state.setTimeLimit(val);
              } else {
                state.setWordLimit(val);
              }
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildDifficultyCard(BuildContext context, GameState state) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final diffIcon = _getDifficultyIcon(state.difficulty);
    final diffLabel = state.difficulty == GameDifficulty.easy
        ? 'Easy'
        : state.difficulty == GameDifficulty.medium
            ? 'Medium'
            : state.difficulty == GameDifficulty.hard
                ? 'Hard'
                : 'Code';

    return GestureDetector(
      onTap: () => _cycleDifficulty(state),
      child: AnimatedScale(
        scale: _difficultyScale,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: themeProvider.accentColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: themeProvider.accentColor.withOpacity(0.04),
                blurRadius: 15,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Difficulty',
                    style: themeProvider.getMonospaceTextStyle(fontSize: 10, fontWeight: FontWeight.bold).copyWith(
                          color: themeProvider.subtextColor,
                          letterSpacing: 0.8,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    diffLabel,
                    style: themeProvider.getHeadingStyle(fontSize: 15, fontWeight: FontWeight.bold).copyWith(
                          letterSpacing: 0.5,
                        ),
                  ),
                ],
              ),
              Icon(
                diffIcon,
                color: themeProvider.accentColor,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
