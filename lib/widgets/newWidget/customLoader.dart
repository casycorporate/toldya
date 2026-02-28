import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/widgets/customWidgets.dart';

class CustomLoader {
  static CustomLoader? _customLoader;

  CustomLoader._createObject();

  factory CustomLoader() {
    if (_customLoader != null) {
      return _customLoader!;
    } else {
      _customLoader = CustomLoader._createObject();
      return _customLoader!;
    }
  }

  //static OverlayEntry _overlayEntry;
  late OverlayState _overlayState; //= new OverlayState();
  OverlayEntry? _overlayEntry;

  _buildLoader() {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Container(
            height: fullHeight(context),
            width: fullWidth(context),
            child: buildLoader(context));
      },
    );
  }

  showLoader(context) {
    _overlayState = Overlay.of(context);
    _buildLoader();
    _overlayState.insert(_overlayEntry!);
  }

  hideLoader() {
    try {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } catch (e) {
      print("Exception:: $e");
    }
  }

  buildLoader(BuildContext context, {Color? backgroundColor}) {
    final theme = Theme.of(context);
    final bg = backgroundColor ??
        (theme.brightness == Brightness.dark
            ? Colors.black.withOpacity(0.75)
            : const Color(0xffa8a8a8).withOpacity(0.5));
    var height = 150.0;
    return CustomScreenLoader(
      height: height,
      width: height,
      backgroundColor: bg,
    );
  }
}

class CustomScreenLoader extends StatelessWidget {
  final Color backgroundColor;
  final double height;
  final double width;
  const CustomScreenLoader({
    Key? key,
    this.backgroundColor = const Color(0xfff8f8f8),
    this.height = 30,
    this.width = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final indicatorColor = theme.colorScheme.primary;
    return Container(
      color: backgroundColor,
      child: Container(
        height: height,
        width: height,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Platform.isIOS
                ? CupertinoActivityIndicator(
                    radius: 35,
                    color: indicatorColor,
                  )
                : CircularProgressIndicator(
                    strokeWidth: 2,
                    color: indicatorColor,
                    backgroundColor: isDark
                        ? theme.colorScheme.onSurface.withOpacity(0.12)
                        : null,
                  ),
            Image.asset(
              'assets/images/casy.png',
              height: 30,
              width: 30,
            )
          ],
        ),
      ),
    );
  }
}
