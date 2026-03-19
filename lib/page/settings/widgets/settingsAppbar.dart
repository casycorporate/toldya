import 'package:flutter/material.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/widgets/customWidgets.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  SettingsAppBar({Key? key, this.title = '', this.subtitle = ''}) : super(key: key);
  final String title, subtitle;
  final Size appBarHeight = Size.fromHeight(60.0);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'HelveticaNeue',
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 18,
            ),
          )
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  @override
  Size get preferredSize => appBarHeight;
}
