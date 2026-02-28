import 'dart:math';

import 'package:flutter/material.dart';

import 'clipPainter.dart';

class BezierContainer extends StatelessWidget {
  const BezierContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topColor = isDark
        ? theme.colorScheme.primary.withOpacity(0.25)
        : Color(0xfffbb448);
    final bottomColor = isDark
        ? theme.colorScheme.primary.withOpacity(0.08)
        : Color(0xffe46b10);
    return Container(
      child: Transform.rotate(
        angle: -pi / 3.5,
        child: ClipPath(
          clipper: ClipPainter(),
          child: Container(
            height: MediaQuery.of(context).size.height * .5,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [topColor, bottomColor],
              ),
            ),
          ),
        ),
      ),
    );
  }
}