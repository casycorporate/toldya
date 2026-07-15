import 'package:flutter/material.dart';

/// Lifts [child] above the software keyboard.
///
/// Use for [Scaffold.bottomNavigationBar], chat input bars, and modal sheet footers.
class KeyboardAwareBar extends StatelessWidget {
  const KeyboardAwareBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottom),
      child: child,
    );
  }
}

/// Scroll padding so the last focused field stays above the keyboard.
EdgeInsets keyboardScrollPadding(BuildContext context, {double extra = 0}) {
  return EdgeInsets.only(
    bottom: MediaQuery.viewInsetsOf(context).bottom + extra,
  );
}
