import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/widgets/newWidget/customUrlText.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final bool secondHeader;
  const HeaderWidget(this.title,{Key? key, this.secondHeader = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: secondHeader ? EdgeInsets.only(left: 18, right: 18, bottom: 10, top: 35) : EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.centerLeft,
      child: UrlText(
        text: title ?? '',
        style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
