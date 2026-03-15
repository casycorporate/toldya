import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextOverflow overflow;
  const TitleText(
    this.text, {
    Key? key,
    this.fontSize = 18,
    this.color,
    this.fontWeight = FontWeight.w600,
    this.textAlign = TextAlign.left,
    this.overflow = TextOverflow.visible,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;
    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: effectiveColor,
      ),
      textAlign: textAlign,
      overflow: overflow,
    );
  }
}
