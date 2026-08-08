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

  void _showCustomTextDialog(BuildContext context, GameState gameState) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final TextEditingController textController = TextEditingController(text: gameState.customText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: themeProvider.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: themeProvider.borderColor),
          ),
          title: Text(
            'PASTE CUSTOM TEXT',
            style: themeProvider.getHeadingStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: textController,
            maxLines: null,
            autofocus: true,
            style: themeProvider.getMonospaceTextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter paragraphs to practice...',
              hintStyle: TextStyle(color: themeProvider.subtextColor.withOpacity(0.5)),
              border: InputBorder.none,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: themeProvider.getMonospaceTextStyle(fontSize: 12, fontWeight: FontWeight.bold).copyWith(
                      color: themeProvider.subtextColor,
                    ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.accentColor,
                foregroundColor: themeProvider.isDark ? Colors.black87 : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                gameState.setCustomText(textController.text);
                Navigator.pop(context);
              },
              child: Text(
                'SAVE TEXT',
                style: themeProvider.getMonospaceTextStyle(fontSize: 12, fontWeight: FontWeight.bold).copyWith(
                      color: themeProvider.isDark ? Colors.black87 : Colors.white,
                    ),
              ),
            ),
          ],
        );
      },
    );
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

              // Main welcome contents
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: themeProvider.borderColor, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: themeProvider.accentColor.withOpacity(0.04),
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
                                color: themeProvider.accentColor.withOpacity(0.08),
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
                          const SizedBox(height: 32),

                          // Three-segment Monkeytype Header Ribbon Configuration Panel
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Block 1: Punctuation / Numbers Toggles
                                _buildPunctuationNumbersBlock(context, gameState),
                                const SizedBox(width: 14),
                                
                                // Block 2: Mode Selector
                                _buildModeSelectorBlock(context, gameState),
                                const SizedBox(width: 14),
                                
                                // Block 3: Dynamic Parameters
                                _buildParameterSelectorBlock(context, gameState),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Animated Difficulty Card
                          Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: _buildDifficultyCard(context, gameState),
                          ),
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
                                  constraints: const BoxConstraints(maxWidth: 400),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: themeProvider.accentColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: themeProvider.accentColor.withOpacity(0.2),
                                        blurRadius: 15,
                                        offset: const Offset(0, 4),
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

  // Segment 1: Punctuation & Numbers Block
  Widget _buildPunctuationNumbersBlock(BuildContext context, GameState state) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Punctuation toggle
          InkWell(
            onTap: () => state.togglePunctuation(),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '@',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: state.includePunctuation ? themeProvider.accentColor : themeProvider.subtextColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'punctuation',
                    style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(
                          color: state.includePunctuation ? themeProvider.accentColor : themeProvider.subtextColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Numbers toggle
          InkWell(
            onTap: () => state.toggleNumbers(),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '#',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: state.includeNumbers ? themeProvider.accentColor : themeProvider.subtextColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'numbers',
                    style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(
                          color: state.includeNumbers ? themeProvider.accentColor : themeProvider.subtextColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Segment 2: Center Mode Selector Block
  Widget _buildModeSelectorBlock(BuildContext context, GameState state) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final modesList = [
      {'mode': GameMode.timeAttack, 'label': 'time', 'icon': Icons.watch_later_outlined},
      {'mode': GameMode.wordLimit, 'label': 'words', 'icon': Icons.font_download_outlined},
      {'mode': GameMode.quote, 'label': 'quote', 'icon': Icons.format_quote_rounded},
      {'mode': GameMode.zen, 'label': 'zen', 'icon': Icons.terrain_rounded},
      {'mode': GameMode.custom, 'label': 'custom', 'icon': Icons.build_rounded},
    ];

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: modesList.map((item) {
          final mode = item['mode'] as GameMode;
          final isSelected = state.mode == mode;
          final label = item['label'] as String;
          final icon = item['icon'] as IconData;

          return InkWell(
            onTap: () => state.setMode(mode),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 11,
                    color: isSelected ? themeProvider.accentColor : themeProvider.subtextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(
                          color: isSelected ? themeProvider.accentColor : themeProvider.subtextColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Segment 3: Parameter Option Selector Block
  Widget _buildParameterSelectorBlock(BuildContext context, GameState state) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    if (state.mode == GameMode.zen) {
      return Container(
        decoration: BoxDecoration(
          color: themeProvider.backgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeProvider.borderColor.withOpacity(0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          'ENDLESS TYPING MODE',
          style: themeProvider.getMonospaceTextStyle(fontSize: 10, fontWeight: FontWeight.bold).copyWith(
                color: themeProvider.accentColor,
              ),
        ),
      );
    }

    if (state.mode == GameMode.quote) {
      return Container(
        decoration: BoxDecoration(
          color: themeProvider.backgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeProvider.borderColor.withOpacity(0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          'FAMOUS QUOTES LOGS',
          style: themeProvider.getMonospaceTextStyle(fontSize: 10, fontWeight: FontWeight.bold).copyWith(
                color: themeProvider.accentColor,
              ),
        ),
      );
    }

    if (state.mode == GameMode.custom) {
      return Container(
        decoration: BoxDecoration(
          color: themeProvider.backgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeProvider.borderColor.withOpacity(0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: InkWell(
          onTap: () => _showCustomTextDialog(context, state),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.edit_note_rounded, size: 14, color: themeProvider.accentColor),
                const SizedBox(width: 4),
                Text(
                  'PASTE TEXT',
                  style: themeProvider.getMonospaceTextStyle(fontSize: 10, fontWeight: FontWeight.bold).copyWith(
                        color: themeProvider.accentColor,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final List<int> options = state.mode == GameMode.timeAttack
        ? [0, 15, 30, 60, 120]
        : [10, 25, 50, 100];

    final int currentValue = state.mode == GameMode.timeAttack
        ? state.timeLimitSec
        : state.wordLimitCount;

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: options.map((val) {
          final isSelected = val == currentValue;
          final String labelText = (state.mode == GameMode.timeAttack && val == 0) ? '∞' : '$val';

          return InkWell(
            onTap: () {
              if (state.mode == GameMode.timeAttack) {
                state.setTimeLimit(val);
              } else {
                state.setWordLimit(val);
              }
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              alignment: Alignment.center,
              child: Text(
                labelText,
                style: themeProvider.getMonospaceTextStyle(fontSize: 10, fontWeight: FontWeight.bold).copyWith(
                      color: isSelected ? themeProvider.accentColor : themeProvider.subtextColor,
                    ),
              ),
            ),
          );
        }).toList(),
      ),
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
