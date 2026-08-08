import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/game_state.dart';
import '../providers/theme_provider.dart';
import '../widgets/typing_text_display.dart';
import '../widgets/virtual_keyboard.dart';
import '../widgets/settings_drawer.dart';
import 'auth_screen.dart';
import 'results_screen.dart';
import 'stats_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final FocusNode _focusNode;
  final TextEditingController _textController = TextEditingController();
  late GameState _gameState;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(onKeyEvent: (node, event) {
      final eventStr = event.runtimeType.toString();
      if (eventStr.contains('Down')) {
        if (event.logicalKey == LogicalKeyboardKey.tab) {
          final state = Provider.of<GameState>(context, listen: false);
          state.initGame();
          _textController.clear();
          _focusNode.requestFocus();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.escape) {
          _scaffoldKey.currentState?.openEndDrawer();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _gameState = Provider.of<GameState>(context, listen: false);
      _textController.text = _gameState.typedText;
      _textController.addListener(_onTextChanged);
      _gameState.initGame();
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResultsScreen()),
      ).then((_) {
        // When coming back, re-initialize game
        state.initGame();
        _textController.clear();
        _focusNode.requestFocus();
      });
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
              hintText: 'Enter paragraph text...',
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
                gameState.initGame();
                _textController.clear();
                _focusNode.requestFocus();
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

  void _showProfileDialog(BuildContext context, GameState gameState) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

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
            'TYPIST ACCOUNT',
            style: themeProvider.getHeadingStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Username: ${gameState.userName}',
                style: themeProvider.getMonospaceTextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${gameState.userEmail}',
                style: themeProvider.getMonospaceTextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              Text(
                'Result metrics are being saved automatically to your career performance logs.',
                style: TextStyle(color: themeProvider.subtextColor, fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CLOSE',
                style: themeProvider.getMonospaceTextStyle(fontSize: 12).copyWith(
                      color: themeProvider.subtextColor,
                    ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.incorrectCharColor,
              ),
              onPressed: () {
                gameState.logout();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully.')),
                );
              },
              child: Text(
                'LOGOUT',
                style: themeProvider.getMonospaceTextStyle(fontSize: 12, fontWeight: FontWeight.bold).copyWith(
                      color: Colors.white,
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
          child: GestureDetector(
            onTap: () {
              _focusNode.requestFocus();
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1050),
                  child: Column(
                    children: [
                      // Header Navigation bar (Custom minimalist it types layout)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'it see',
                                    style: themeProvider.getMonospaceTextStyle(fontSize: 8).copyWith(
                                          color: themeProvider.subtextColor.withOpacity(0.5),
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.keyboard_alt_outlined, color: themeProvider.accentColor, size: 22),
                                      const SizedBox(width: 8),
                                      Text(
                                        'it types',
                                        style: themeProvider.getHeadingStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(width: 28),
                              // Tiny toolbar menu icons mapping
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.keyboard_outlined, color: themeProvider.subtextColor.withOpacity(0.7), size: 16),
                                    tooltip: 'Reset simulator',
                                    onPressed: () {
                                      gameState.initGame();
                                      _textController.clear();
                                      _focusNode.requestFocus();
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.leaderboard_outlined, color: themeProvider.subtextColor.withOpacity(0.7), size: 16),
                                    tooltip: 'Dashboard & Leaderboard',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const StatsScreen()),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.info_outline_rounded, color: themeProvider.subtextColor.withOpacity(0.7), size: 16),
                                    tooltip: 'Typist profile',
                                    onPressed: () {
                                      if (gameState.isLoggedIn) {
                                        _showProfileDialog(context, gameState);
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const AuthScreen()),
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.settings_outlined, color: themeProvider.subtextColor.withOpacity(0.7), size: 16),
                                    tooltip: 'App settings',
                                    onPressed: () {
                                      _scaffoldKey.currentState?.openEndDrawer();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.notifications_none_rounded, color: themeProvider.textColor.withOpacity(0.7), size: 20),
                                tooltip: 'Notifications',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Theme preset currently: ${themeProvider.currentTheme.name.toUpperCase()}'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: Icon(
                                  gameState.isLoggedIn ? Icons.account_circle_rounded : Icons.login_rounded,
                                  color: gameState.isLoggedIn ? themeProvider.accentColor : themeProvider.textColor.withOpacity(0.7),
                                  size: 20,
                                ),
                                tooltip: gameState.isLoggedIn ? 'Account: ${gameState.userName}' : 'Sign in',
                                onPressed: () {
                                  if (gameState.isLoggedIn) {
                                    _showProfileDialog(context, gameState);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Monkeytype Configuration Segment Ribbon
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildPunctuationNumbersBlock(context, gameState),
                            const SizedBox(width: 12),
                            _buildModeSelectorBlock(context, gameState),
                            const SizedBox(width: 12),
                            _buildDifficultySelectorBlock(context, gameState),
                            if (gameState.mode != GameMode.quote && gameState.mode != GameMode.custom)
                              const SizedBox(width: 12),
                            _buildParameterSelectorBlock(context, gameState),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Main centered typing container (Cardless, floating layout matching Monkeytype)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Sleek Minimalist Stats & Sizing Ribbon
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isMobileWidth = MediaQuery.of(context).size.width < 600;
                                  if (isMobileWidth) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildMinimalStatsRibbon(context),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: _buildFontSizeSelector(context),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: _buildMinimalStatsRibbon(context)),
                                        _buildFontSizeSelector(context),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 24),

                              // Center globe language selector matching Monkeytype screenshot
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.language_rounded, color: themeProvider.subtextColor.withOpacity(0.4), size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    'english',
                                    style: themeProvider.getMonospaceTextStyle(fontSize: 11).copyWith(
                                          color: themeProvider.subtextColor.withOpacity(0.5),
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Typing Area
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Center(
                                        child: SingleChildScrollView(
                                          physics: const BouncingScrollPhysics(),
                                          child: TypingTextDisplay(
                                            targetText: gameState.targetText,
                                            typedText: gameState.typedText,
                                            cursorIndex: gameState.typedText.length,
                                          ),
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
                                          color: themeProvider.backgroundColor.withOpacity(0.9),
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
                              const SizedBox(height: 16),

                              // Central Restart Button
                              Center(
                                child: IconButton(
                                  icon: Icon(Icons.refresh_rounded, color: themeProvider.subtextColor.withOpacity(0.7), size: 28),
                                  tooltip: 'Restart Test',
                                  onPressed: () {
                                    gameState.initGame();
                                    _textController.clear();
                                    _focusNode.requestFocus();
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),

                              // On-screen Virtual Keyboard Overlay (Only visible on non-mobile viewports)
                              const VirtualKeyboard(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Bottom keyboard shortcut guides (styled rounded container keycaps)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildKeyCap(context, 'tab'),
                          const SizedBox(width: 6),
                          Text(
                            ' - restart test',
                            style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(
                                  color: themeProvider.subtextColor.withOpacity(0.5),
                                  letterSpacing: 0.5,
                                ),
                          ),
                          const SizedBox(width: 24),
                          _buildKeyCap(context, 'esc'),
                          const SizedBox(width: 6),
                          Text(
                            ' - settings drawer',
                            style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(
                                  color: themeProvider.subtextColor.withOpacity(0.5),
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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

  // Segment 1: Toggles for punctuation & numbers
  Widget _buildPunctuationNumbersBlock(BuildContext context, GameState state) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Row(
        children: [
          HoverOptionText(
            prefix: '@',
            text: 'punctuation',
            isSelected: state.includePunctuation,
            onTap: () {
              state.togglePunctuation();
              state.initGame();
              _textController.clear();
              _focusNode.requestFocus();
            },
          ),
          const SizedBox(width: 4),
          HoverOptionText(
            prefix: '#',
            text: 'numbers',
            isSelected: state.includeNumbers,
            onTap: () {
              state.toggleNumbers();
              state.initGame();
              _textController.clear();
              _focusNode.requestFocus();
            },
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Row(
        children: modesList.map((item) {
          final mode = item['mode'] as GameMode;
          final isSelected = state.mode == mode;
          final label = item['label'] as String;
          final icon = item['icon'] as IconData;

          return HoverOptionText(
            icon: icon,
            text: label,
            isSelected: isSelected,
            onTap: () {
              state.setMode(mode);
              state.initGame();
              _textController.clear();
              _focusNode.requestFocus();
            },
          );
        }).toList(),
      ),
    );
  }

  // Segment 3: Togglable difficulty modes cycles Easy -> Medium -> Hard -> Code
  Widget _buildDifficultySelectorBlock(BuildContext context, GameState state) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    if (state.mode == GameMode.quote || state.mode == GameMode.custom) {
      return const SizedBox.shrink();
    }

    final label = state.difficulty == GameDifficulty.easy
        ? 'easy'
        : state.difficulty == GameDifficulty.medium
            ? 'medium'
            : state.difficulty == GameDifficulty.hard
                ? 'hard'
                : 'code';

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: HoverOptionText(
        icon: Icons.tune_rounded,
        text: 'diff: $label',
        isSelected: true,
        onTap: () {
          final nextIndex = (state.difficulty.index + 1) % GameDifficulty.values.length;
          state.setDifficulty(GameDifficulty.values[nextIndex]);
          state.initGame();
          _textController.clear();
          _focusNode.requestFocus();
        },
      ),
    );
  }

  // Segment 4: Parameter Selector Block
  Widget _buildParameterSelectorBlock(BuildContext context, GameState state) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    if (state.mode == GameMode.zen) {
      return Container(
        decoration: BoxDecoration(
          color: themeProvider.backgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeProvider.borderColor.withOpacity(0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          'ZEN MODE',
          style: themeProvider.getMonospaceTextStyle(fontSize: 12, fontWeight: FontWeight.bold).copyWith(color: themeProvider.accentColor),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          'FAMOUS QUOTES',
          style: themeProvider.getMonospaceTextStyle(fontSize: 12, fontWeight: FontWeight.bold).copyWith(color: themeProvider.accentColor),
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: HoverOptionText(
          icon: Icons.edit_note_rounded,
          text: 'PASTE TEXT',
          isSelected: true,
          onTap: () => _showCustomTextDialog(context, state),
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Row(
        children: options.map((val) {
          final isSelected = val == currentValue;
          final String labelText = (state.mode == GameMode.timeAttack && val == 0) ? '∞' : '$val';

          return HoverOptionText(
            text: labelText,
            isSelected: isSelected,
            onTap: () {
              if (state.mode == GameMode.timeAttack) {
                state.setTimeLimit(val);
              } else {
                state.setWordLimit(val);
              }
              state.initGame();
              _textController.clear();
              _focusNode.requestFocus();
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFontSizeSelector(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
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
    );
  }

  Widget _buildMinimalStatsRibbon(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 16 : 22,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label.toUpperCase(),
          style: themeProvider.getMonospaceTextStyle(fontSize: isMobile ? 8 : 10).copyWith(
                color: themeProvider.subtextColor,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }

  Widget _verticalDivider(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: 1.5,
      height: 20,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
      color: themeProvider.borderColor.withOpacity(0.3),
    );
  }

  Widget _buildKeyCap(BuildContext context, String label) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: themeProvider.borderColor.withOpacity(0.6)),
      ),
      child: Text(
        label,
        style: themeProvider.getMonospaceTextStyle(fontSize: 8, fontWeight: FontWeight.bold).copyWith(
              color: themeProvider.subtextColor,
            ),
      ),
    );
  }
}

// Reusable stateful widget to lighten configuration ribbon text options on mouse hover
class HoverOptionText extends StatefulWidget {
  final String text;
  final String? prefix;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const HoverOptionText({
    super.key,
    required this.text,
    this.prefix,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<HoverOptionText> createState() => _HoverOptionTextState();
}

class _HoverOptionTextState extends State<HoverOptionText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    Color color = widget.isSelected
        ? themeProvider.accentColor
        : _isHovered
            ? themeProvider.textColor
            : themeProvider.subtextColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon!,
                  size: 13,
                  color: color,
                ),
                const SizedBox(width: 4),
              ],
              if (widget.prefix != null) ...[
                Text(
                  widget.prefix!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 3),
              ],
              Text(
                widget.text,
                style: themeProvider.getMonospaceTextStyle(fontSize: 12).copyWith(
                      color: color,
                      fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
