import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../providers/theme_provider.dart';

class VirtualKeyboard extends StatelessWidget {
  const VirtualKeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (isMobile) {
      return const SizedBox.shrink();
    }

    final gameState = Provider.of<GameState>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // QWERTY Layout rows configuration
    final List<List<String>> rows = [
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/']
    ];

    final activeKey = gameState.lastPressedKey;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1 - 3
            for (var row in rows) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((key) {
                  final isActive = activeKey == key;
                  return _buildKeyCell(context, key, isActive);
                }).toList(),
              ),
              const SizedBox(height: 6),
            ],
            // Space bar row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildKeyCell(context, ' ', activeKey == ' ', width: 200),
                const SizedBox(width: 6),
                _buildKeyCell(context, '⌫', activeKey == 'backspace', width: 44, label: 'back'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildKeyCell(BuildContext context, String keyChar, bool isActive, {double? width, String? label}) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final displayLabel = label ?? keyChar.toUpperCase();
    final double defaultWidth = 28.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      curve: Curves.easeOutQuad,
      width: width ?? defaultWidth,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive
            ? themeProvider.accentColor.withOpacity(0.35)
            : themeProvider.cardColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? themeProvider.accentColor : themeProvider.borderColor.withOpacity(0.4),
          width: isActive ? 2.0 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: themeProvider.accentColor.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Text(
        displayLabel,
        style: TextStyle(
          fontSize: width != null ? 10 : 11,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: isActive ? themeProvider.accentColor : themeProvider.textColor.withOpacity(0.7),
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
