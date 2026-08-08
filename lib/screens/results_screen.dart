import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/game_state.dart';
import '../providers/theme_provider.dart';
import 'stats_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  double _calculateRawWpm(GameState state) {
    if (state.elapsedTimeSec <= 0) return 0.0;
    double totalKeystrokes = (state.correctKeys + state.incorrectKeys) / 5.0;
    double minutes = state.elapsedTimeSec / 60.0;
    return (totalKeystrokes / minutes).clamp(0.0, 300.0);
  }

  double _calculateConsistency(List<double> history) {
    if (history.isEmpty || history.length < 2) return 92.0; // Realistic default
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

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final rawWpm = _calculateRawWpm(gameState);
    final consistency = _calculateConsistency(gameState.wpmHistory);
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      body: Container(
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
                    const SizedBox(height: 36),

                    // Main Scoreboard: Split columns (large metrics on left, chart on right)
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
                    _buildDetailsRibbon(context, rawWpm, consistency),
                    const SizedBox(height: 48),

                    // Bottom Navigation Shortcuts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Repeat Test
                        IconButton(
                          icon: Icon(Icons.replay_rounded, color: themeProvider.subtextColor, size: 24),
                          tooltip: 'Repeat Test',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 24),
                        // Return Home
                        IconButton(
                          icon: Icon(Icons.arrow_forward_rounded, color: themeProvider.accentColor, size: 28),
                          tooltip: 'Next Test',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 24),
                        // Career Stats Screen
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

  Widget _buildDetailsRibbon(BuildContext context, double rawWpm, double consistency) {
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
          _ribbonTile(context, 'time', '${gameState.elapsedTimeSec}s'),
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
