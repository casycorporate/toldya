import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';

class TabIndicator extends Decoration {
  final BoxPainter _painter;

  TabIndicator() : _painter = _TabPainter();

  @override
  BoxPainter createBoxPainter([void Function()? onChanged]) => _painter;
}

class _TabPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final size = cfg.size ?? Size.zero;
    final Offset blueLineOffset1 = offset + Offset(0, size.height);
    final Offset greyLineOffset2 = Offset(0, size.height + 1);

    final Offset blueLinePaint2 =
        offset + Offset(size.width, size.height);
    final Offset greyLineOffset1 =
        offset + Offset(size.width * 3, size.height + 1);

    var blueLinePaint = Paint()
      ..color = ToldyaColor.dodgetBlue
      ..strokeWidth = 2;
    var greyLinePaint = Paint()
      ..color = AppColor.lightGrey
      ..strokeWidth = .2;

    canvas.drawLine(greyLineOffset1, greyLineOffset2, greyLinePaint);
    canvas.drawLine(blueLineOffset1, blueLinePaint2, blueLinePaint);
  }
}
