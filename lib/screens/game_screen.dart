import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../providers/theme_provider.dart';
import '../widgets/typing_text_display.dart';
import '../widgets/virtual_keyboard.dart';
import '../widgets/settings_drawer.dart';
import 'results_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();
  late GameState _gameState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _gameState = Provider.of<GameState>(context, listen: false);
      _textController.text = _gameState.typedText;
      _textController.addListener(_onTextChanged);
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final state = Provider.of<GameState>(context, listen: false);
    final currentText = _textController.text;
    final stateText = state.typedText;

    if (currentText.length > stateText.length) {
      final newChar = currentText.substring(stateText.length);
      for (int i = 0; i < newChar.length; i++) {
        state.handleCharacterInput(newChar[i]);
      }
    } else if (currentText.length < stateText.length) {
      final diff = stateText.length - currentText.length;
      for (int i = 0; i < diff; i++) {
        state.handleBackspace();
      }
    }

    if (_textController.text != state.typedText) {
      _textController.text = state.typedText;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: state.typedText.length),
      );
    }

    // Skip results page push in Zen mode
    if (state.isFinished && state.mode != GameMode.zen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResultsScreen()),
      );
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
          child: GestureDetector(
            onTap: () {
              _focusNode.requestFocus();
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    children: [
                      // Header Navigation bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new, color: themeProvider.textColor, size: 20),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    themeProvider.isDark ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                                    key: ValueKey<bool>(themeProvider.isDark),
                                    color: themeProvider.textColor,
                                    size: 20,
                                  ),
                                ),
                                onPressed: () => themeProvider.toggleTheme(),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.settings_outlined, color: themeProvider.textColor, size: 20),
                                onPressed: () {
                                  _scaffoldKey.currentState?.openEndDrawer();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Main centered dashboard card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: themeProvider.cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: themeProvider.borderColor, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: themeProvider.accentColor.withOpacity(0.04),
                                blurRadius: 25,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Sleek Minimalist Stats & Sizing Ribbon
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: _buildMinimalStatsRibbon(context)),
                                  // Inline Font Size Adjustment (A- / A+)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: themeProvider.backgroundColor.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: themeProvider.borderColor.withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.text_decrease_rounded, color: themeProvider.subtextColor, size: 14),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                          onPressed: () {
                                            themeProvider.setFontSize(themeProvider.fontSize - 2);
                                          },
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${themeProvider.fontSize.toInt()}px',
                                          style: themeProvider.getMonospaceTextStyle(fontSize: 11, fontWeight: FontWeight.bold).copyWith(
                                                color: themeProvider.textColor,
                                              ),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: Icon(Icons.text_increase_rounded, color: themeProvider.subtextColor, size: 14),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                          onPressed: () {
                                            themeProvider.setFontSize(themeProvider.fontSize + 2);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(height: 1.0, color: themeProvider.borderColor.withOpacity(0.3)),
                              const SizedBox(height: 16),

                              // Typing Area
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: TypingTextDisplay(
                                          targetText: gameState.targetText,
                                          typedText: gameState.typedText,
                                          cursorIndex: gameState.typedText.length,
                                        ),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: 0.0,
                                      child: TextField(
                                        controller: _textController,
                                        focusNode: _focusNode,
                                        autocorrect: false,
                                        enableSuggestions: false,
                                        enableIMEPersonalizedLearning: false,
                                        keyboardType: TextInputType.visiblePassword,
                                        maxLines: null,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    if (!_focusNode.hasFocus)
                                      Positioned.fill(
                                        child: Container(
                                          color: themeProvider.backgroundColor.withOpacity(0.85),
                                          child: Center(
                                            child: Text(
                                              'CLICK OR TAP HERE TO START TYPING',
                                              textAlign: TextAlign.center,
                                              style: themeProvider.getMonospaceTextStyle(fontSize: 15, fontWeight: FontWeight.bold).copyWith(
                                                    color: themeProvider.accentColor,
                                                    letterSpacing: 1.2,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              Container(height: 1.0, color: themeProvider.borderColor.withOpacity(0.3)),
                              const SizedBox(height: 12),

                              // On-screen Virtual Keyboard Overlay
                              const VirtualKeyboard(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bottom actions
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: themeProvider.borderColor),
                          foregroundColor: themeProvider.textColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          gameState.initGame();
                          _textController.clear();
                          _focusNode.requestFocus();
                        },
                        icon: const Icon(Icons.replay_rounded),
                        label: Text(
                          'RESET SIMULATOR',
                          style: themeProvider.getMonospaceTextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalStatsRibbon(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Zen mode stopwatch shows count-up elapsed time
    final String timeLabel = gameState.mode == GameMode.zen
        ? '${gameState.elapsedTimeSec}s'
        : (gameState.mode == GameMode.timeAttack && gameState.timeLimitSec == 0)
            ? '${gameState.elapsedTimeSec}s'
            : gameState.mode == GameMode.timeAttack
                ? '${gameState.remainingSeconds}s'
                : '${gameState.typedText.length}/${gameState.targetText.length}';

    final String timeTitle = gameState.mode == GameMode.zen
        ? 'ELAPSED'
        : (gameState.mode == GameMode.timeAttack && gameState.timeLimitSec == 0)
            ? 'ELAPSED'
            : gameState.mode == GameMode.timeAttack
                ? 'TIME LEFT'
                : 'TYPED';

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _ribbonTile(
          context,
          '${gameState.wpm.toStringAsFixed(0)}',
          'WPM',
          themeProvider.accentColor,
        ),
        _verticalDivider(context),
        _ribbonTile(
          context,
          '${gameState.accuracy.toStringAsFixed(0)}%',
          'ACCURACY',
          themeProvider.correctCharColor,
        ),
        _verticalDivider(context),
        _ribbonTile(
          context,
          timeLabel,
          timeTitle,
          themeProvider.textColor,
        ),
      ],
    );
  }

  Widget _ribbonTile(BuildContext context, String value, String label, Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(
                color: themeProvider.subtextColor,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }

  Widget _verticalDivider(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      width: 1.5,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: themeProvider.borderColor.withOpacity(0.3),
    );
  }
}
