import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/game_state.dart';
import '../providers/theme_provider.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      backgroundColor: themeProvider.backgroundColor,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: themeProvider.borderColor, width: 1.5),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings, color: themeProvider.accentColor),
                        const SizedBox(width: 10),
                        Text(
                          'SETTINGS',
                          style: themeProvider.getHeadingStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: themeProvider.textColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Drawer options
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [

                    // Audio Switcher
                    _buildSectionHeader(context, 'AUDIO EFFECTS'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              Icon(
                                gameState.isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                                color: gameState.isSoundEnabled ? themeProvider.accentColor : themeProvider.subtextColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Keystroke Sound',
                                style: themeProvider.getHeadingStyle(fontSize: 14, fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                          Switch(
                            value: gameState.isSoundEnabled,
                            onChanged: (val) => gameState.toggleSound(),
                            activeColor: themeProvider.accentColor,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Font Size Slider
                    _buildSectionHeader(context, 'TYPING TEXT SIZE'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: themeProvider.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Size: ${themeProvider.fontSize.toInt()}px',
                                style: themeProvider.getMonospaceTextStyle(fontSize: 12),
                              ),
                              Text(
                                'Preview Text',
                                style: themeProvider.getMonospaceTextStyle(fontSize: themeProvider.fontSize),
                              ),
                            ],
                          ),
                          Slider(
                            value: themeProvider.fontSize,
                            min: 14.0,
                            max: 28.0,
                            divisions: 7,
                            activeColor: themeProvider.accentColor,
                            inactiveColor: themeProvider.borderColor,
                            onChanged: (val) => themeProvider.setFontSize(val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Training Mode selector
                    _buildSectionHeader(context, 'TRAINING MODE'),
                    const SizedBox(height: 12),
                    _buildSelectionDropdown<GameMode>(
                      context,
                      value: gameState.mode,
                      items: GameMode.values,
                      labelBuilder: (m) => m == GameMode.timeAttack
                          ? 'Time Attack'
                          : m == GameMode.wordLimit
                              ? 'Word Limit'
                              : 'Sudden Death',
                      onChanged: (val) {
                        if (val != null) gameState.setMode(val);
                      },
                    ),

                    // Mode Params
                    if (gameState.mode == GameMode.timeAttack) ...[
                      const SizedBox(height: 16),
                      _buildSliderSelector(
                        context,
                        'Time limit (seconds)',
                        [15, 30, 60, 120],
                        gameState.timeLimitSec,
                        (v) => gameState.setTimeLimit(v),
                      ),
                    ] else if (gameState.mode == GameMode.wordLimit) ...[
                      const SizedBox(height: 16),
                      _buildSliderSelector(
                        context,
                        'Words count',
                        [10, 25, 50, 100],
                        gameState.wordLimitCount,
                        (v) => gameState.setWordLimit(v),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Difficulty selector
                    _buildSectionHeader(context, 'DIFFICULTY'),
                    const SizedBox(height: 12),
                    _buildSelectionDropdown<GameDifficulty>(
                      context,
                      value: gameState.difficulty,
                      items: GameDifficulty.values,
                      labelBuilder: (d) => d == GameDifficulty.easy
                          ? 'Easy Common Words'
                          : d == GameDifficulty.medium
                              ? 'Medium Standard'
                              : d == GameDifficulty.hard
                                  ? 'Hard Vocabulary'
                                  : 'Developer Snippets (Code)',
                      onChanged: (val) {
                        if (val != null) gameState.setDifficulty(val);
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, 'APP UPDATE'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.accentColor,
                        foregroundColor: themeProvider.isDark ? Colors.black87 : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final Uri url = Uri.parse('https://github.com/humza/ittypes/releases'); // Point to the repo releases
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open update page.')),
                          );
                        }
                      },
                      icon: const Icon(Icons.system_update_alt_rounded),
                      label: Text(
                        'CHECK FOR UPDATES',
                        style: themeProvider.getMonospaceTextStyle(fontSize: 12, fontWeight: FontWeight.bold).copyWith(
                              color: themeProvider.isDark ? Colors.black87 : Colors.white,
                            ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: themeProvider.getMonospaceTextStyle(fontSize: 11, fontWeight: FontWeight.bold).copyWith(
              color: themeProvider.accentColor,
              letterSpacing: 0.8,
            ),
      ),
    );
  }

  Widget _buildSelectionDropdown<T>(
    BuildContext context, {
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: themeProvider.backgroundColor,
          style: themeProvider.getHeadingStyle(fontSize: 14, fontWeight: FontWeight.normal),
          icon: Icon(Icons.arrow_drop_down, color: themeProvider.textColor),
          isExpanded: true,
          items: items.map((val) {
            return DropdownMenuItem<T>(
              value: val,
              child: Text(labelBuilder(val)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSliderSelector(
    BuildContext context,
    String label,
    List<int> options,
    int activeValue,
    Function(int) onSelect,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: themeProvider.getMonospaceTextStyle(fontSize: 11).copyWith(color: themeProvider.subtextColor),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: options.map((val) {
            final isSelected = val == activeValue;
            return ChoiceChip(
              label: Text(
                '$val',
                style: themeProvider.getMonospaceTextStyle(fontSize: 11, fontWeight: FontWeight.bold).copyWith(
                      color: isSelected
                          ? (themeProvider.isDark ? Colors.black87 : Colors.white)
                          : themeProvider.textColor,
                    ),
              ),
              selected: isSelected,
              selectedColor: themeProvider.accentColor,
              backgroundColor: themeProvider.cardColor,
              onSelected: (selected) {
                if (selected) {
                  onSelect(val);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
