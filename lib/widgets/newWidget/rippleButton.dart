import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';

class RippleButton extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final BorderRadius borderRadius;
  final Color? splashColor;
  RippleButton({Key? key, this.child, this.onPressed, this.borderRadius = const BorderRadius.all(Radius.circular(0)), this.splashColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child ?? SizedBox.shrink(),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: splashColor ?? Theme.of(context).splashColor,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius
              ),
            ),
              onPressed: onPressed,
              child: Container()),
        )
      ],
    );
  }
}
