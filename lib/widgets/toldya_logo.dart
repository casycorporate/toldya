import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';

/// Toldya logosu (SVG) – mavi veya dark tema varyantı.
class ToldyaLogo extends StatelessWidget {
  const ToldyaLogo({
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    /// true ise dark tema logosu (koyu arka plan) kullanılır.
    this.useDarkVariant = false,
  }) : super(key: key);

  final double? width;
  final double? height;
  final BoxFit fit;
  final bool useDarkVariant;

  @override
  Widget build(BuildContext context) {
    final dark = useDarkVariant || useDarkTheme;
    return SvgPicture.asset(
      dark ? kToldyaLogoDark : kToldyaLogo,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
