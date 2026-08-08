import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class TypingTextDisplay extends StatelessWidget {
  final String targetText;
  final String typedText;
  final int cursorIndex;

  const TypingTextDisplay({
    super.key,
    required this.targetText,
    required this.typedText,
    required this.cursorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    List<InlineSpan> spans = [];

    final fontSize = themeProvider.fontSize;
    final cursorHeight = fontSize * 1.25;

    for (int i = 0; i < targetText.length; i++) {
      Color charColor;
      TextDecoration decoration = TextDecoration.none;
      String displayText;

      // Insert animated blinking cursor at current position
      if (i == cursorIndex) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: BlinkingCursor(
              color: themeProvider.accentColor,
              height: cursorHeight,
            ),
          ),
        );
      }

      if (i < typedText.length) {
        if (typedText[i] == targetText[i]) {
          charColor = themeProvider.correctCharColor;
          displayText = targetText[i];
        } else {
          charColor = themeProvider.incorrectCharColor;
          decoration = TextDecoration.underline;
          displayText = typedText[i];
        }
      } else {
        charColor = themeProvider.untypedCharColor;
        displayText = targetText[i];
      }

      spans.add(
        TextSpan(
          text: displayText,
          style: themeProvider.getMonospaceTextStyle(fontSize: fontSize).copyWith(
                color: charColor,
                decoration: decoration,
                decorationColor: themeProvider.incorrectCharColor,
              ),
        ),
      );
    }

    // Append cursor if at the end of the text
    if (cursorIndex >= targetText.length) {
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: BlinkingCursor(
            color: themeProvider.accentColor,
            height: cursorHeight,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }
}

class BlinkingCursor extends StatefulWidget {
  final Color color;
  final double height;

  const BlinkingCursor({
    super.key,
    required this.color,
    required this.height,
  });

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2.5,
        height: widget.height,
        color: widget.color,
      ),
    );
  }
}
