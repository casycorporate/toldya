import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum HapticStrength { none, light, medium }

/// Wraps a child with scale-down on press (0.96) and spring-back on release.
/// Uses Listener so the child (e.g. InkWell) still receives the tap and shows splash.
/// When [enabled] is false, no scale animation. Add haptics inside the child's onTap.
class AnimatedBounceButton extends StatefulWidget {
  const AnimatedBounceButton({
    Key? key,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 100),
    this.pressScale = 0.96,
  }) : super(key: key);

  final Widget child;
  final bool enabled;
  final Duration duration;
  final double pressScale;

  @override
  State<AnimatedBounceButton> createState() => _AnimatedBounceButtonState();
}

class _AnimatedBounceButtonState extends State<AnimatedBounceButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.enabled && _pressed ? widget.pressScale : 1.0;
    return Listener(
      onPointerDown: (_) {
        if (widget.enabled) setState(() => _pressed = true);
      },
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Call this in onTap for medium (primary) or light (secondary) haptic.
void bounceButtonHaptic(HapticStrength strength) {
  switch (strength) {
    case HapticStrength.medium:
      HapticFeedback.mediumImpact();
      break;
    case HapticStrength.light:
      HapticFeedback.lightImpact();
      break;
    case HapticStrength.none:
      break;
  }
}
