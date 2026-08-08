import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/game_state.dart';
import '../providers/theme_provider.dart';
import 'auth_screen.dart';
import 'stats_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _badgeAnimController;
  late Animation<double> _badgeScaleAnim;
  late Animation<double> _badgeSlideAnim;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _badgeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _badgeScaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _badgeAnimController, curve: Curves.elasticOut),
    );

    _badgeSlideAnim = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(parent: _badgeAnimController, curve: Curves.easeOutBack),
    );

    _badgeAnimController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _badgeAnimController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double _calculateRawWpm(GameState state) {
    if (state.elapsedTimeSec <= 0) return 0.0;
    double totalKeystrokes = (state.correctKeys + state.incorrectKeys) / 5.0;
    double minutes = state.elapsedTimeSec / 60.0;
    return (totalKeystrokes / minutes).clamp(0.0, 300.0);
  }

  double _calculateConsistency(List<double> history) {
    if (history.isEmpty || history.length < 2) return 92.0;
    final clean = history.where((v) => v > 0.0).toList();
    if (clean.length < 2) return 95.0;

    double sum = clean.reduce((a, b) => a + b);
    double mean = sum / clean.length;
    double sumOfSquaredDiffs = clean.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b);
    double variance = sumOfSquaredDiffs / clean.length;
    double stdDev = sqrt(variance);

    if (mean == 0) return 0.0;
    double consistency = (1.0 - (stdDev / mean)) * 100.0;
    return consistency.clamp(10.0, 100.0);
  }

  String _calculateRank(GameDifficulty difficulty, int elapsedSec) {
    if (difficulty == GameDifficulty.easy) {
      if (elapsedSec < 6) return 'Diamond';
      if (elapsedSec < 12) return 'Gold';
      if (elapsedSec < 18) return 'Silver';
      if (elapsedSec < 24) return 'Bronze';
    } else if (difficulty == GameDifficulty.medium) {
      if (elapsedSec < 10) return 'Diamond';
      if (elapsedSec < 18) return 'Gold';
      if (elapsedSec < 26) return 'Silver';
      if (elapsedSec < 34) return 'Bronze';
    } else {
      // Hard or Code
      if (elapsedSec < 15) return 'Diamond';
      if (elapsedSec < 28) return 'Gold';
      if (elapsedSec < 40) return 'Silver';
      if (elapsedSec < 52) return 'Bronze';
    }
    return 'Unranked';
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final rawWpm = _calculateRawWpm(gameState);
    final consistency = _calculateConsistency(gameState.wpmHistory);
    final isMobile = MediaQuery.of(context).size.width < 700;
    
    final rank = (gameState.mode == GameMode.timeAttack && (gameState.timeLimitSec == 15 || gameState.timeLimitSec == 30))
        ? 'Unranked'
        : _calculateRank(gameState.difficulty, gameState.elapsedTimeSec);

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        final eventStr = event.runtimeType.toString();
        if (eventStr.contains('Down')) {
          final key = event.logicalKey.keyLabel.toLowerCase();
          if (key == 'r') {
            Navigator.pop(context);
            return KeyEventResult.handled;
          } else if (key == 'n') {
            Navigator.pop(context);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Scoreboard layout content
            Container(
              decoration: BoxDecoration(
                gradient: themeProvider.backgroundGradient,
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 850),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top navigation action row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'IT TYPES REPORT',
                                style: themeProvider.getHeadingStyle(fontSize: 16, fontWeight: FontWeight.bold).copyWith(
                                      letterSpacing: 1.0,
                                    ),
                              ),
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
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Glowing Animated Rank Badge Celebration Card
                          if (rank != 'Unranked')
                            AnimatedBuilder(
                              animation: _badgeAnimController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _badgeSlideAnim.value),
                                  child: Transform.scale(
                                    scale: _badgeScaleAnim.value,
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildRankBadgeCard(context, rank),
                            ),
                          const SizedBox(height: 24),

                          // Main Scoreboard: Split columns
                          isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildBigStatsColumn(context),
                                    const SizedBox(height: 28),
                                    _buildChartCard(context),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: _buildBigStatsColumn(context),
                                    ),
                                    const SizedBox(width: 32),
                                    Expanded(
                                      child: _buildChartCard(context),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 40),

                          // Details Ribbon (test type, raw, characters, consistency, time)
                          _buildDetailsRibbon(context, rawWpm, consistency, rank),
                          const SizedBox(height: 32),

                          // Interactive Sign In / Session Save Status Banner
                          Center(
                            child: InkWell(
                              onTap: gameState.isLoggedIn
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AuthScreen()),
                                      );
                                    },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: Text(
                                  gameState.isLoggedIn
                                      ? 'Logged in as ${gameState.userName} (Result saved to dashboard)'
                                      : 'Sign in to save your result',
                                  style: themeProvider.getMonospaceTextStyle(fontSize: 11).copyWith(
                                        color: themeProvider.subtextColor,
                                        decoration: gameState.isLoggedIn ? TextDecoration.none : TextDecoration.underline,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Bottom Navigation Shortcuts
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Repeat Test
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.replay_rounded, color: themeProvider.subtextColor, size: 24),
                                    tooltip: 'Repeat Test',
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  Text(
                                    'restart [R]',
                                    style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(
                                          color: themeProvider.subtextColor,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 32),
                              // Return Home / Next Test
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward_rounded, color: themeProvider.accentColor, size: 28),
                                    tooltip: 'Next Test',
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  Text(
                                    'next test [N]',
                                    style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(
                                          color: themeProvider.accentColor,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 32),
                              // Career Stats Screen
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.bar_chart_rounded, color: themeProvider.subtextColor, size: 24),
                                    tooltip: 'Career Performance logs',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const StatsScreen()),
                                      );
                                    },
                                  ),
                                  Text(
                                    'dashboard',
                                    style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(
                                          color: themeProvider.subtextColor,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Particle Confetti overlay
            if (rank != 'Unranked')
              const IgnorePointer(
                child: ConfettiCelebration(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigStatsColumn(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // WPM Metric
        Text(
          'wpm',
          style: themeProvider.getMonospaceTextStyle(fontSize: 14).copyWith(
                color: themeProvider.subtextColor,
                letterSpacing: 0.5,
              ),
        ),
        Text(
          '${gameState.wpm.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: themeProvider.accentColor,
            fontFamily: 'monospace',
            height: 1.1,
          ),
        ),
        const SizedBox(height: 24),
        // Accuracy Metric
        Text(
          'acc',
          style: themeProvider.getMonospaceTextStyle(fontSize: 14).copyWith(
                color: themeProvider.subtextColor,
                letterSpacing: 0.5,
              ),
        ),
        Text(
          '${gameState.accuracy.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: themeProvider.correctCharColor,
            fontFamily: 'monospace',
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SPEED HISTOGRAM OVER TIME',
                style: themeProvider.getMonospaceTextStyle(fontSize: 9, fontWeight: FontWeight.bold).copyWith(
                      color: themeProvider.subtextColor,
                      letterSpacing: 0.8,
                    ),
              ),
              Text(
                'wpm/sec',
                style: themeProvider.getMonospaceTextStyle(fontSize: 9).copyWith(
                      color: themeProvider.subtextColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: WpmChartPainter(
                history: gameState.wpmHistory,
                accentColor: themeProvider.accentColor,
                gridColor: themeProvider.borderColor.withOpacity(0.5),
                textColor: themeProvider.subtextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadgeCard(BuildContext context, String rank) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    Color glowColor;
    String badgeEmoji;
    String rankName;

    if (rank == 'Diamond') {
      glowColor = const Color(0xFF00E5FF);
      badgeEmoji = '💎';
      rankName = 'DIAMOND RANK';
    } else if (rank == 'Gold') {
      glowColor = const Color(0xFFFFC107);
      badgeEmoji = '🥇';
      rankName = 'GOLD RANK';
    } else if (rank == 'Silver') {
      glowColor = const Color(0xFF90A4AE);
      badgeEmoji = '🥈';
      rankName = 'SILVER RANK';
    } else {
      glowColor = const Color(0xFFFF7043);
      badgeEmoji = '🥉';
      rankName = 'BRONZE RANK';
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: glowColor, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.2),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(badgeEmoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ACHIEVEMENT UNLOCKED',
                  style: themeProvider.getMonospaceTextStyle(fontSize: 9, fontWeight: FontWeight.bold).copyWith(
                        color: themeProvider.subtextColor,
                        letterSpacing: 1.0,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  rankName,
                  style: themeProvider.getHeadingStyle(fontSize: 26, fontWeight: FontWeight.bold).copyWith(
                        color: glowColor,
                        letterSpacing: 0.8,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsRibbon(BuildContext context, double rawWpm, double consistency, String rank) {
    final gameState = Provider.of<GameState>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final modeLabel = gameState.mode.name.toLowerCase();
    final diffLabel = gameState.difficulty.name.toLowerCase();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runSpacing: 20,
        spacing: 20,
        children: [
          _ribbonTile(context, 'test type', '$modeLabel\n$diffLabel'),
          _ribbonTile(context, 'raw wpm', rawWpm.toStringAsFixed(0)),
          _ribbonTile(context, 'characters', '${gameState.correctKeys}/${gameState.incorrectKeys}/0/0'),
          _ribbonTile(context, 'consistency', '${consistency.toStringAsFixed(0)}%'),
          _ribbonTile(context, 'rank badge', rank),
        ],
      ),
    );
  }

  Widget _ribbonTile(BuildContext context, String label, String value) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: themeProvider.getMonospaceTextStyle(fontSize: 9, fontWeight: FontWeight.bold).copyWith(
                color: themeProvider.subtextColor,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
            fontFamily: 'monospace',
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

// Particle details model
class ConfettiParticle {
  double x, y, size, vx, vy, rotation, vr;
  Color color;
  bool isSquare;
  double opacity = 1.0;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.vr,
    required this.isSquare,
  });

  void update() {
    double wind = sin(y / 40.0) * 0.35;
    x += vx + wind;
    vy += 0.06; // gravity speed
    y += vy;
    rotation += vr;
    opacity = (opacity - 0.0045).clamp(0.0, 1.0);
  }
}

// Stateful high-performance particle confetti overlays
class ConfettiCelebration extends StatefulWidget {
  const ConfettiCelebration({super.key});

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration> with SingleTickerProviderStateMixin {
  late AnimationController _particleController;
  final List<ConfettiParticle> _particles = [];
  final Random _rand = Random();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {
          for (var p in _particles) {
            p.update();
          }
        });
      });
    _particleController.forward();
  }

  void _initializeParticles(double width, double height) {
    if (_initialized) return;
    _initialized = true;

    final colors = [
      const Color(0xFF00E5FF),
      const Color(0xFFFFC107),
      const Color(0xFFEF5350),
      const Color(0xFF66BB6A),
      const Color(0xFFAB47BC),
      const Color(0xFF29B6F6),
    ];

    // Spawn 100 particles falling from top
    for (int i = 0; i < 100; i++) {
      _particles.add(ConfettiParticle(
        x: _rand.nextDouble() * width,
        y: -30.0 - _rand.nextDouble() * 350.0,
        size: 5.0 + _rand.nextDouble() * 8.0,
        color: colors[_rand.nextInt(colors.length)],
        vx: -2.0 + _rand.nextDouble() * 4.0,
        vy: 1.0 + _rand.nextDouble() * 4.0,
        rotation: _rand.nextDouble() * pi,
        vr: -0.06 + _rand.nextDouble() * 0.12,
        isSquare: _rand.nextBool(),
      ));
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _initializeParticles(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(
          size: Size.infinite,
          painter: ConfettiPainter(particles: _particles),
        );
      },
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      if (p.x < -20 || p.x > size.width + 20 || p.y > size.height || p.opacity <= 0.0) continue;

      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity)
        ..style = PaintingStyle.fill;

      // 3D paper tumbling calculation: width scales down to 0 and back as it flips
      double scaleX = cos(p.rotation);

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      if (p.isSquare) {
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size * scaleX, height: p.size), paint);
      } else {
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: p.size * scaleX, height: p.size), paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}

// Custom Painter to render a smooth line chart showing typing progress over time
class WpmChartPainter extends CustomPainter {
  final List<double> history;
  final Color accentColor;
  final Color gridColor;
  final Color textColor;

  WpmChartPainter({
    required this.history,
    required this.accentColor,
    required this.gridColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final paintLine = Paint()
      ..color = accentColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..color = accentColor.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // 4 horizontal grid lines
    const int gridRows = 4;
    for (int i = 0; i <= gridRows; i++) {
      double y = size.height * i / gridRows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Determine max speed boundaries
    double maxWpm = history.reduce(max);
    if (maxWpm < 40) maxWpm = 40;

    double dx = size.width / (history.length > 1 ? history.length - 1 : 1);

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < history.length; i++) {
      double x = i * dx;
      double y = size.height - (history[i] / maxWpm * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw paths
    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Draw simple text boundaries
    final textPainterMax = TextPainter(
      text: TextSpan(
        text: '${maxWpm.toInt()}',
        style: TextStyle(color: textColor, fontSize: 8, fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterMax.layout();
    textPainterMax.paint(canvas, const Offset(4, 2));

    final textPainterMin = TextPainter(
      text: TextSpan(
        text: '0',
        style: TextStyle(color: textColor, fontSize: 8, fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterMin.layout();
    textPainterMin.paint(canvas, Offset(4, size.height - 12));
  }

  @override
  bool shouldRepaint(covariant WpmChartPainter oldDelegate) => true;
}
