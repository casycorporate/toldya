import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';

/// Ana sayfa ve tahmin detayda ortak: EVET/HAYIR bar + donut tooltip
class YesNoProgressWithTooltip extends StatelessWidget {
  final double yesPercent;
  final int totalStaked;
  final Color yesColor;
  final Color noColor;

  const YesNoProgressWithTooltip({
    Key? key,
    required this.yesPercent,
    required this.totalStaked,
    required this.yesColor,
    required this.noColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final yes = (yesPercent * 100).round().clamp(0, 100);
    final no = 100 - yes;
    const barHeight = 26.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EVET $yes%',
              style: TextStyle(
                color: yesColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'HAYIR $no%',
              style: TextStyle(
                color: noColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(barHeight / 2),
            boxShadow: [
              BoxShadow(
                color: yesColor.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 0,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(barHeight / 2),
            child: Container(
              height: barHeight,
              child: Row(
                children: [
                  Expanded(
                    flex: yes.clamp(1, 99),
                    child: Container(color: yesColor),
                  ),
                  Expanded(
                    flex: no.clamp(1, 99),
                    child: Container(color: noColor),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 3),
        _TooltipInfo(
          yesPercent: yesPercent,
          totalStaked: totalStaked,
          yesColor: yesColor,
          noColor: noColor,
        ),
      ],
    );
  }
}

class _TooltipInfo extends StatelessWidget {
  final double yesPercent;
  final int totalStaked;
  final Color yesColor;
  final Color noColor;

  const _TooltipInfo({
    Key? key,
    required this.yesPercent,
    required this.totalStaked,
    required this.yesColor,
    required this.noColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return SizedBox(
              height: 5,
              width: w,
              child: CustomPaint(
                painter: _TooltipArrowPainter(arrowPosition: w / 2),
              ),
            );
          },
        ),
        Container(
          padding: EdgeInsets.fromLTRB(spacing12, spacing8, spacing12, spacing8),
          decoration: BoxDecoration(
            color: MockupDesign.background,
            borderRadius: BorderRadius.circular(radiusSmall),
            border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _legendDot(yesColor),
                  SizedBox(width: 4),
                  Text(
                    'EVET',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  _legendDot(noColor),
                  SizedBox(width: 4),
                  Text(
                    'HAYIR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                '${k_m_b_generator(totalStaked)} Token bahis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _TooltipArrowPainter extends CustomPainter {
  final double arrowPosition;

  _TooltipArrowPainter({this.arrowPosition = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width.isFinite ? size.width : 300.0;
    final x = (arrowPosition.clamp(16.0, w - 16)).toDouble();
    final h = size.height;
    final path = Path();
    path.moveTo(x - 6, h);
    path.lineTo(x, 0.0);
    path.lineTo(x + 6, h);
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Color(0xFF1C1C1E)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _TooltipArrowPainter oldDelegate) =>
      oldDelegate.arrowPosition != arrowPosition;
}

class _DonutChartPainter extends CustomPainter {
  final double yesPercent;
  final Color yesColor;
  final Color noColor;

  _DonutChartPainter({required this.yesPercent, required this.yesColor, required this.noColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const pi = 3.14159265359;
    final sweepYes = 2 * pi * yesPercent;
    final sweepNo = 2 * pi * (1 - yesPercent);
    final paintYes = Paint()
      ..color = yesColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final paintNo = Paint()
      ..color = noColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweepYes, false, paintYes);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2 + sweepYes, sweepNo, false, paintNo);
    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.yesPercent != yesPercent;
}

/// Kalan süre: daire göstergesi + kırmızı metin
class CountdownWithCircle extends StatelessWidget {
  final String countdownText;
  final double progress;

  const CountdownWithCircle({
    Key? key,
    required this.countdownText,
    required this.progress,
  }) : super(key: key);

  static const Color _countdownRed = Color(0xFFE53935);
  static const Color _countdownGlow = Color(0xFFFF1744);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: CustomPaint(
            painter: _CountdownRingPainter(
              progress: progress,
              color: _countdownRed,
              glowColor: _countdownGlow,
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(
          countdownText,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _countdownRed,
            letterSpacing: 0.8,
            shadows: [
              Shadow(
                color: _countdownGlow.withOpacity(0.8),
                blurRadius: 8,
                offset: Offset(0, 0),
              ),
              Shadow(
                color: _countdownGlow.withOpacity(0.4),
                blurRadius: 14,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color glowColor;

  _CountdownRingPainter({
    required this.progress,
    required this.color,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 3.0;
    const pi = 3.14159265359;
    const gapAtTop = 0.12;

    final outerRadius = size.width / 2 - strokeWidth;
    final fullSweep = 2 * pi - gapAtTop;
    final startAngle = -pi / 2 + gapAtTop / 2;

    final paintOuter = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngle,
      fullSweep,
      false,
      paintOuter,
    );

    final sweepAngle = fullSweep * progress;
    final paintProgress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngle,
      sweepAngle,
      false,
      paintProgress,
    );

    final innerRadius = outerRadius - 8;
    final innerSweep = sweepAngle * 0.7;
    final paintInner = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      startAngle,
      innerSweep,
      false,
      paintInner,
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
