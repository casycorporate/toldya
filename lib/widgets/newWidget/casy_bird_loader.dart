import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';

/// Casy kuşu: 7 parça (tangram tarzı, sola bakan). Normalize koordinatlar 0..1.
class _CasyBirdPaths {
  static const int pieceCount = 7;

  /// Her parça için normalize (0-1) köşe noktaları. Canvas size ile scale edilir.
  static List<Path> paths(double width, double height) {
    final w = width;
    final h = height;
    return [
      // 0: Gaga - küçük üçgen, sol üst
      Path()
        ..moveTo(w * 0.08, h * 0.48)
        ..lineTo(w * 0.08, h * 0.52)
        ..lineTo(w * 0.18, h * 0.50)
        ..close(),
      // 1: Baş / üst boyun
      Path()
        ..moveTo(w * 0.18, h * 0.38)
        ..lineTo(w * 0.18, h * 0.50)
        ..lineTo(w * 0.36, h * 0.44)
        ..lineTo(w * 0.28, h * 0.38)
        ..close(),
      // 2: Üst gövde / kanat (büyük üçgen)
      Path()
        ..moveTo(w * 0.28, h * 0.28)
        ..lineTo(w * 0.36, h * 0.44)
        ..lineTo(w * 0.56, h * 0.36)
        ..lineTo(w * 0.46, h * 0.26)
        ..close(),
      // 3: Alt gövde (büyük üçgen)
      Path()
        ..moveTo(w * 0.36, h * 0.44)
        ..lineTo(w * 0.56, h * 0.36)
        ..lineTo(w * 0.50, h * 0.72)
        ..lineTo(w * 0.32, h * 0.68)
        ..close(),
      // 4: Bacak (ince paralelkenar)
      Path()
        ..moveTo(w * 0.32, h * 0.68)
        ..lineTo(w * 0.50, h * 0.72)
        ..lineTo(w * 0.46, h * 0.92)
        ..lineTo(w * 0.28, h * 0.90)
        ..close(),
      // 5: Kuyruk (büyük üçgen, sağ üst)
      Path()
        ..moveTo(w * 0.56, h * 0.36)
        ..lineTo(w * 0.78, h * 0.26)
        ..lineTo(w * 0.90, h * 0.44)
        ..lineTo(w * 0.56, h * 0.50)
        ..close(),
      // 6: Kuyruk ucu (küçük üçgen)
      Path()
        ..moveTo(w * 0.90, h * 0.44)
        ..lineTo(w * 0.96, h * 0.40)
        ..lineTo(w * 0.96, h * 0.50)
        ..close(),
    ];
  }
}

/// 7 parçanın opacity değerleri (0-1) ile kuşu çizer.
class CasyBirdPainter extends CustomPainter {
  final List<double> opacities;
  final Color color;
  final double width;
  final double height;

  CasyBirdPainter({
    required this.opacities,
    required this.color,
    required this.width,
    required this.height,
  }) : assert(opacities.length >= _CasyBirdPaths.pieceCount);

  @override
  void paint(Canvas canvas, Size size) {
    final paths = _CasyBirdPaths.paths(width, height);
    for (int i = 0; i < paths.length; i++) {
      final opacity = (i < opacities.length) ? opacities[i].clamp(0.0, 1.0) : 0.0;
      if (opacity <= 0) continue;
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawPath(paths[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CasyBirdPainter oldDelegate) {
    return oldDelegate.opacities != opacities ||
        oldDelegate.color != color ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }
}

/// Parçalar tek tek belirir, sonra tek tek kaybolur; döngü tekrarlanır.
class CasyBirdLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const CasyBirdLoader({
    Key? key,
    this.size = 80,
    this.color,
  }) : super(key: key);

  @override
  State<CasyBirdLoader> createState() => _CasyBirdLoaderState();
}

class _CasyBirdLoaderState extends State<CasyBirdLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const int _pieceCount = _CasyBirdPaths.pieceCount;
  static const int _steps = _pieceCount * 2; // 7 görünür + 7 kaybolur

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<double> _opacities(double phase) {
    final step = phase * _steps; // 0 .. 14
    final opacities = List<double>.filled(_pieceCount, 0);
    for (int i = 0; i < _pieceCount; i++) {
      // Görünme: step i .. i+1 arası parça i 0->1
      if (step <= i) {
        opacities[i] = 0;
      } else if (step <= i + 1) {
        opacities[i] = step - i;
      } else if (step <= _pieceCount + (_pieceCount - 1 - i)) {
        opacities[i] = 1;
      } else if (step <= _pieceCount + (_pieceCount - i)) {
        final fadeStart = _pieceCount + (_pieceCount - 1 - i);
        opacities[i] = 1 - (step - fadeStart);
      } else {
        opacities[i] = 0;
      }
    }
    return opacities;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ??
        Theme.of(context).colorScheme.primary;
    final size = widget.size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacities = _opacities(_controller.value);
        return CustomPaint(
          size: Size(size, size),
          painter: CasyBirdPainter(
            opacities: opacities,
            color: color,
            width: size,
            height: size,
          ),
        );
      },
    );
  }
}
