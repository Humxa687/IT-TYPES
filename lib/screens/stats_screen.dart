import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/game_state.dart';
import '../providers/theme_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameState = Provider.of<GameState>(context, listen: false);
      _nameController.text = gameState.userName;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Calculate Summary stats
    final logs = gameState.gameLogs;
    final totalTests = logs.length;
    double highWpm = 0.0;
    double avgWpm = 0.0;
    double avgAcc = 0.0;

    if (logs.isNotEmpty) {
      highWpm = logs.map((l) => (l['wpm'] as num).toDouble()).reduce(max);
      double totalWpm = logs.map((l) => (l['wpm'] as num).toDouble()).reduce((a, b) => a + b);
      double totalAcc = logs.map((l) => (l['accuracy'] as num).toDouble()).reduce((a, b) => a + b);
      avgWpm = totalWpm / totalTests;
      avgAcc = totalAcc / totalTests;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: themeProvider.textColor, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'PERFORMANCE DASHBOARD',
                      style: themeProvider.getHeadingStyle(fontSize: 16, fontWeight: FontWeight.bold).copyWith(
                            letterSpacing: 1.0,
                          ),
                    ),
                    // Placeholder to keep spacing centered
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Profile Name Editor
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: themeProvider.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: themeProvider.borderColor),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: themeProvider.accentColor.withOpacity(0.12),
                                  child: Icon(Icons.person_outline_rounded, color: themeProvider.accentColor, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'TYPIST PROFILE NAME',
                                        style: themeProvider.getMonospaceTextStyle(fontSize: 9, fontWeight: FontWeight.bold).copyWith(
                                              color: themeProvider.subtextColor,
                                              letterSpacing: 0.8,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      TextField(
                                        controller: _nameController,
                                        style: themeProvider.getHeadingStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                          hintText: 'Enter name...',
                                          hintStyle: TextStyle(color: themeProvider.subtextColor.withOpacity(0.5)),
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (val) {
                                          gameState.setUserName(val);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Career Summary Statistics Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatSummaryCard(
                                  context,
                                  'HIGH SCORE',
                                  '${highWpm.toStringAsFixed(1)}',
                                  'WPM',
                                  themeProvider.accentColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatSummaryCard(
                                  context,
                                  'AVERAGE SPEED',
                                  '${avgWpm.toStringAsFixed(1)}',
                                  'WPM',
                                  themeProvider.textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatSummaryCard(
                                  context,
                                  'AVG ACCURACY',
                                  '${avgAcc.toStringAsFixed(1)}%',
                                  'ACC',
                                  themeProvider.correctCharColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatSummaryCard(
                                  context,
                                  'TOTAL RUNS',
                                  '$totalTests',
                                  'SESSIONS',
                                  themeProvider.subtextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Historical Score logs
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'RECENT TYPING SESSIONS',
                                style: themeProvider.getMonospaceTextStyle(fontSize: 10, fontWeight: FontWeight.bold).copyWith(
                                      color: themeProvider.subtextColor,
                                      letterSpacing: 0.8,
                                    ),
                              ),
                              if (logs.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    gameState.resetStatistics();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Career statistics history cleared.')),
                                    );
                                  },
                                  child: Text(
                                    'CLEAR LOGS',
                                    style: themeProvider.getMonospaceTextStyle(fontSize: 9, fontWeight: FontWeight.bold).copyWith(
                                          color: themeProvider.incorrectCharColor,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (logs.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(40),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: themeProvider.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: themeProvider.borderColor),
                              ),
                              child: Text(
                                'NO COMPLETED RUNS YET\nSTART A SESSION TO LOG SCORES',
                                textAlign: TextAlign.center,
                                style: themeProvider.getMonospaceTextStyle(fontSize: 11).copyWith(
                                      color: themeProvider.subtextColor,
                                      height: 1.5,
                                    ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: logs.length,
                              separatorBuilder: (c, i) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                // Display logs newest first
                                final logIndex = logs.length - 1 - index;
                                final log = logs[logIndex];
                                final date = DateTime.tryParse(log['date'] ?? '') ?? DateTime.now();
                                final dateStr = '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: themeProvider.cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: themeProvider.borderColor.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${log['mode']?.toString().toUpperCase()}',
                                                style: themeProvider.getMonospaceTextStyle(fontSize: 9, fontWeight: FontWeight.bold).copyWith(
                                                      color: themeProvider.accentColor,
                                                    ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${log['difficulty']?.toString().toUpperCase()}',
                                                style: themeProvider.getMonospaceTextStyle(fontSize: 9, fontWeight: FontWeight.bold).copyWith(
                                                      color: themeProvider.subtextColor,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            dateStr,
                                            style: TextStyle(color: themeProvider.subtextColor.withOpacity(0.6), fontSize: 10),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${(log['wpm'] as num).toStringAsFixed(1)}',
                                                style: TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: themeProvider.textColor,
                                                ),
                                              ),
                                              Text(
                                                'WPM',
                                                style: themeProvider.getMonospaceTextStyle(fontSize: 8).copyWith(color: themeProvider.subtextColor),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 18),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${(log['accuracy'] as num).toStringAsFixed(0)}%',
                                                style: TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: themeProvider.correctCharColor,
                                                ),
                                              ),
                                              Text(
                                                'ACC',
                                                style: themeProvider.getMonospaceTextStyle(fontSize: 8).copyWith(color: themeProvider.subtextColor),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 36),
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

  Widget _buildStatSummaryCard(
    BuildContext context,
    String label,
    String value,
    String suffix,
    Color color,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: themeProvider.getMonospaceTextStyle(fontSize: 9, fontWeight: FontWeight.bold).copyWith(
                  color: themeProvider.subtextColor,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                suffix,
                style: themeProvider.getMonospaceTextStyle(fontSize: 9).copyWith(color: themeProvider.subtextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
