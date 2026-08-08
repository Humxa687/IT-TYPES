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
        child: DefaultTabController(
          length: 2,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: themeProvider.borderColor, width: 1.5),
              ),
            ),
            child: Column(
              children: [
                // Header Title
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings_outlined, color: themeProvider.accentColor),
                          const SizedBox(width: 10),
                          Text(
                            'SETTINGS',
                            style: themeProvider.getHeadingStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

                // Tab Bar
                TabBar(
                  labelColor: themeProvider.accentColor,
                  unselectedLabelColor: themeProvider.subtextColor,
                  indicatorColor: themeProvider.accentColor,
                  labelStyle: themeProvider.getMonospaceTextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(icon: Icon(Icons.keyboard_alt_outlined, size: 18), text: 'TYPING'),
                    Tab(icon: Icon(Icons.tune_outlined, size: 18), text: 'APP SYSTEM'),
                  ],
                ),
                const Divider(height: 1),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    children: [
                      // TAB 1: TYPING SETTINGS
                      ListView(
                        padding: const EdgeInsets.all(20.0),
                        children: [
                          // Dynamic Font Sizing (Stacked vertically to prevent overlay!)
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
                                      'Size Level',
                                      style: themeProvider.getMonospaceTextStyle(fontSize: 11, fontWeight: FontWeight.bold).copyWith(color: themeProvider.subtextColor),
                                    ),
                                    Text(
                                      '${themeProvider.fontSize.toInt()}px',
                                      style: themeProvider.getMonospaceTextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                // Preview on its own row to avoid overlapping
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: themeProvider.backgroundColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Preview Text',
                                    style: themeProvider.getMonospaceTextStyle(fontSize: themeProvider.fontSize),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Slider(
                                  value: themeProvider.fontSize,
                                  min: 14.0,
                                  max: 50.0,
                                  divisions: 18,
                                  activeColor: themeProvider.accentColor,
                                  inactiveColor: themeProvider.borderColor,
                                  onChanged: (val) => themeProvider.setFontSize(val),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Typography Font Family selection
                          _buildSectionHeader(context, 'TYPING FONT FAMILY'),
                          const SizedBox(height: 12),
                          _buildSelectionDropdown<String>(
                            context,
                            value: themeProvider.fontFamily,
                            items: const ['monospace', 'sans-serif', 'serif'],
                            labelBuilder: (val) => val == 'monospace'
                                ? 'Monospace Style'
                                : val == 'sans-serif'
                                    ? 'Clean Sans-Serif'
                                    : 'Elegant Serif',
                            onChanged: (val) {
                              if (val != null) themeProvider.setFontFamily(val);
                            },
                          ),
                        ],
                      ),

                      // TAB 2: APP SYSTEM SETTINGS
                      ListView(
                        padding: const EdgeInsets.all(20.0),
                        children: [
                          // Audio settings (Keystroke toggle + volume slider)
                          _buildSectionHeader(context, 'AUDIO EFFECTS'),
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
                                      'Keystroke Sound',
                                      style: themeProvider.getHeadingStyle(fontSize: 14, fontWeight: FontWeight.normal),
                                    ),
                                    Switch(
                                      value: gameState.isSoundEnabled,
                                      onChanged: (val) => gameState.toggleSound(),
                                      activeColor: themeProvider.accentColor,
                                    ),
                                  ],
                                ),
                                if (gameState.isSoundEnabled) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Sound Volume',
                                        style: themeProvider.getMonospaceTextStyle(fontSize: 10, fontWeight: FontWeight.bold).copyWith(color: themeProvider.subtextColor),
                                      ),
                                      Text(
                                        '${(gameState.soundVolume * 100).toInt()}%',
                                        style: themeProvider.getMonospaceTextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Slider(
                                    value: gameState.soundVolume,
                                    min: 0.0,
                                    max: 1.0,
                                    divisions: 10,
                                    activeColor: themeProvider.accentColor,
                                    inactiveColor: themeProvider.borderColor,
                                    onChanged: (val) => gameState.setSoundVolume(val),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Reset Statistics
                          _buildSectionHeader(context, 'DATA & PROGRESS'),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: themeProvider.incorrectCharColor.withOpacity(0.5)),
                              foregroundColor: themeProvider.incorrectCharColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              gameState.resetStatistics();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('High scores and stats cleared successfully.')),
                              );
                            },
                            icon: const Icon(Icons.delete_sweep_outlined),
                            label: Text(
                              'CLEAR STATS & SCORES',
                              style: themeProvider.getMonospaceTextStyle(fontSize: 11, fontWeight: FontWeight.bold).copyWith(
                                    color: themeProvider.incorrectCharColor,
                                  ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // App Updates
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
                              final Uri url = Uri.parse('https://github.com/humza/ittypes/releases');
                              try {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not open page: $e')),
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
}
