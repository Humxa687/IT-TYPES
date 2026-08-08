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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: themeProvider.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // Tabs
                TabBar(
                  labelColor: themeProvider.accentColor,
                  unselectedLabelColor: themeProvider.subtextColor,
                  indicatorColor: themeProvider.accentColor,
                  labelStyle: themeProvider.getMonospaceTextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(icon: Icon(Icons.person_rounded, size: 18), text: 'MY PERFORMANCE'),
                    Tab(icon: Icon(Icons.leaderboard_rounded, size: 18), text: 'LEADERBOARD'),
                  ],
                ),
                const Divider(height: 1),

                Expanded(
                  child: TabBarView(
                    children: [
                      // TAB 1: User personal logs
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                                    Text(
                                      '$totalTests sessions recorded',
                                      style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(
                                            color: themeProvider.subtextColor,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (logs.isEmpty)
                                  _buildEmptyLogsCard(context)
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: logs.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final item = logs[logs.length - 1 - index];
                                      final double wpm = (item['wpm'] as num).toDouble();
                                      final double acc = (item['accuracy'] as num).toDouble();
                                      final String mode = item['mode'] ?? 'time';
                                      final String date = item['date'] ?? '';

                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: themeProvider.cardColor,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: themeProvider.borderColor),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: themeProvider.backgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Icon(Icons.keyboard_alt_outlined, color: themeProvider.accentColor, size: 18),
                                                ),
                                                const SizedBox(width: 12),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Mode: ${mode.toUpperCase()}',
                                                      style: themeProvider.getMonospaceTextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      date,
                                                      style: themeProvider.getMonospaceTextStyle(fontSize: 9).copyWith(
                                                            color: themeProvider.subtextColor,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '${wpm.toStringAsFixed(0)} WPM',
                                                      style: themeProvider.getMonospaceTextStyle(fontSize: 13, fontWeight: FontWeight.bold).copyWith(
                                                            color: themeProvider.accentColor,
                                                          ),
                                                    ),
                                                    Text(
                                                      '${acc.toStringAsFixed(0)}% acc',
                                                      style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(
                                                            color: themeProvider.correctCharColor,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // TAB 2: Global Leaderboard
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 650),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'GLOBAL LEADERBOARD',
                                  style: themeProvider.getMonospaceTextStyle(fontSize: 11, fontWeight: FontWeight.bold).copyWith(
                                        color: themeProvider.subtextColor,
                                        letterSpacing: 0.8,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                _buildLeaderboardList(context, highWpm, avgAcc),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatSummaryCard(BuildContext context, String label, String value, String unit, Color valColor) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: valColor,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 6),
              Text(
                unit,
                style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(
                      color: themeProvider.subtextColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLogsCard(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.keyboard_outlined, size: 40, color: themeProvider.subtextColor.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            'NO COMPLETED RUNS YET',
            style: themeProvider.getMonospaceTextStyle(fontSize: 11, fontWeight: FontWeight.bold).copyWith(
                  color: themeProvider.textColor,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Finish a typing speed run to log your score here.',
            textAlign: TextAlign.center,
            style: themeProvider.getMonospaceTextStyle(fontSize: 9).copyWith(
                  color: themeProvider.subtextColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(BuildContext context, double userHighWpm, double userAvgAcc) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final gameState = Provider.of<GameState>(context, listen: false);

    // Mock Masters list
    final List<Map<String, dynamic>> masters = [
      {'name': 'speed_demon 👑', 'wpm': 152.4, 'acc': 99.8, 'rank': 'Diamond Rank 💎', 'isUser': false},
      {'name': 'finger_fire 🥇', 'wpm': 138.1, 'acc': 99.4, 'rank': 'Diamond Rank 💎', 'isUser': false},
      {'name': 'keyboard_cat 🥈', 'wpm': 124.7, 'acc': 98.9, 'rank': 'Diamond Rank 💎', 'isUser': false},
      {'name': 'typewriter_pro 🥉', 'wpm': 115.0, 'acc': 99.0, 'rank': 'Gold Rank 🥇', 'isUser': false},
      {'name': 'matrix_coder', 'wpm': 98.3, 'acc': 98.2, 'rank': 'Gold Rank 🥇', 'isUser': false},
    ];

    // Determine user's highest earned rank label
    String userRankLabel = 'Unranked';
    if (userHighWpm > 0.0) {
      if (userHighWpm > 90.0) {
        userRankLabel = 'Diamond Rank 💎';
      } else if (userHighWpm > 70.0) {
        userRankLabel = 'Gold Rank 🥇';
      } else if (userHighWpm > 50.0) {
        userRankLabel = 'Silver Rank 🥈';
      } else {
        userRankLabel = 'Bronze Rank 🥉';
      }
    }

    // Insert user's high score entry
    masters.add({
      'name': '${gameState.userName} (You)',
      'wpm': userHighWpm,
      'acc': userAvgAcc > 0.0 ? userAvgAcc : 96.2,
      'rank': userRankLabel,
      'isUser': true,
    });

    // Sort descending by WPM speed
    masters.sort((a, b) => (b['wpm'] as num).compareTo(a['wpm'] as num));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: masters.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = masters[index];
        final bool isUser = item['isUser'];
        final double wpm = item['wpm'];
        final double acc = item['acc'];
        final String rank = item['rank'];
        final String name = item['name'];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isUser ? themeProvider.accentColor.withOpacity(0.08) : themeProvider.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUser ? themeProvider.accentColor : themeProvider.borderColor,
              width: isUser ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    alignment: Alignment.center,
                    child: Text(
                      '#${index + 1}',
                      style: themeProvider.getMonospaceTextStyle(fontSize: 14, fontWeight: FontWeight.bold).copyWith(
                            color: index == 0
                                ? const Color(0xFFFFC107)
                                : index == 1
                                    ? const Color(0xFFB0BEC5)
                                    : index == 2
                                        ? const Color(0xFFFF7043)
                                        : themeProvider.subtextColor,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: themeProvider.getHeadingStyle(fontSize: 13, fontWeight: isUser ? FontWeight.bold : FontWeight.normal),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rank,
                        style: themeProvider.getMonospaceTextStyle(fontSize: 9).copyWith(
                              color: themeProvider.subtextColor,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${wpm.toStringAsFixed(1)} WPM',
                    style: themeProvider.getMonospaceTextStyle(fontSize: 13, fontWeight: FontWeight.bold).copyWith(
                          color: isUser ? themeProvider.accentColor : themeProvider.textColor,
                        ),
                  ),
                  Text(
                    '${acc.toStringAsFixed(1)}% acc',
                    style: themeProvider.getMonospaceTextStyle(fontSize: 9).copyWith(
                          color: themeProvider.subtextColor,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
