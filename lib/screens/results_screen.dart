import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../providers/theme_provider.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top header bar (actions)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Title Header
                    Text(
                      'PERFORMANCE REPORT',
                      style: themeProvider.getHeadingStyle(fontSize: 28, fontWeight: FontWeight.bold).copyWith(
                            color: themeProvider.accentColor,
                            letterSpacing: 1.5,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Typing session metrics analyzed',
                      style: themeProvider.getMonospaceTextStyle(fontSize: 13).copyWith(
                            color: themeProvider.subtextColor,
                          ),
                    ),
                    const SizedBox(height: 40),

                    // Grid stats cards
                    GridView.count(
                      crossAxisCount: isMobile ? 2 : 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: isMobile ? 1.3 : 1.4,
                      children: [
                        _buildStatCard(
                          context,
                          'SPEED',
                          '${gameState.wpm.toStringAsFixed(1)} WPM',
                          Icons.speed_rounded,
                        ),
                        _buildStatCard(
                          context,
                          'ACCURACY',
                          '${gameState.accuracy.toStringAsFixed(1)}%',
                          Icons.insights_rounded,
                        ),
                        _buildStatCard(
                          context,
                          'TIME TAKEN',
                          '${gameState.elapsedTimeSec}s',
                          Icons.hourglass_bottom_rounded,
                        ),
                        _buildStatCard(
                          context,
                          'KEYSTROKES',
                          '${gameState.correctKeys}/${gameState.incorrectKeys}',
                          Icons.keyboard_alt_outlined,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Speed Timeline Painter
                    _buildSectionHeader(context, 'SPEED VELOCITY GRAPH'),
                    const SizedBox(height: 12),
                    Container(
                      height: 220,
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: themeProvider.borderColor),
                      ),
                      child: gameState.wpmHistory.length > 1
                          ? CustomPaint(
                              painter: WpmChartPainter(
                                history: gameState.wpmHistory,
                                accentColor: themeProvider.accentColor,
                                gridColor: themeProvider.subtextColor.withOpacity(0.15),
                                textColor: themeProvider.subtextColor,
                              ),
                            )
                          : Center(
                              child: Text(
                                'No timeline metrics available for short test runs.',
                                style: themeProvider.getMonospaceTextStyle(fontSize: 12).copyWith(
                                      color: themeProvider.subtextColor,
                                    ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 40),

                    // Button actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.accentColor,
                            foregroundColor: themeProvider.isDark ? Colors.black87 : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          onPressed: () {
                            gameState.initGame();
                            Navigator.pop(context); // Go back to GameScreen
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(
                            'REPLAY TEST',
                            style: themeProvider.getMonospaceTextStyle(fontSize: 13, fontWeight: FontWeight.bold).copyWith(
                                  color: themeProvider.isDark ? Colors.black87 : Colors.white,
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: themeProvider.borderColor),
                            foregroundColor: themeProvider.textColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          icon: const Icon(Icons.home_rounded),
                          label: Text(
                            'MAIN MENU',
                            style: themeProvider.getMonospaceTextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Row(
      children: [
        Container(
          width: 8,
          height: 18,
          decoration: BoxDecoration(
            color: themeProvider.accentColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: themeProvider.getMonospaceTextStyle(fontSize: 14, fontWeight: FontWeight.bold).copyWith(
                color: themeProvider.textColor,
                letterSpacing: 1.0,
              ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: themeProvider.accentColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: themeProvider.getMonospaceTextStyle(fontSize: 10, fontWeight: FontWeight.bold).copyWith(
                        color: themeProvider.subtextColor,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: themeProvider.getHeadingStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

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
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..color = accentColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final paintGrid = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    double maxWPM = history.reduce((curr, next) => curr > next ? curr : next);
    if (maxWPM < 40) maxWPM = 40;

    final gridCount = 4;
    final wpmStep = maxWPM / gridCount;
    for (int i = 0; i <= gridCount; i++) {
      final y = size.height - (i * (size.height / gridCount));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(wpmStep * i).toInt()}',
          style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 10, fontFamily: 'monospace'),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(4, y - 12));
    }

    final int points = history.length;
    final double dx = size.width / (points - 1);

    final path = Path();
    final fillPath = Path();

    final startY = size.height - (history[0] / maxWPM * size.height);
    path.moveTo(0, startY);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, startY);

    for (int i = 1; i < points; i++) {
      final x = i * dx;
      final y = size.height - (history[i] / maxWPM * size.height);
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant WpmChartPainter oldDelegate) {
    return oldDelegate.history != history ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.gridColor != gridColor;
  }
}
