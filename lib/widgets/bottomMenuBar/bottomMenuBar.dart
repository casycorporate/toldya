import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/state/appState.dart';
import 'package:provider/provider.dart';
import '../customWidgets.dart';

class BottomMenubar extends StatefulWidget{
  final IconData? iconData;
  final PageController? pageController;
  const BottomMenubar({this.pageController, this.iconData});
  _BottomMenubarState createState() => _BottomMenubarState();
}
class _BottomMenubarState extends State<BottomMenubar>  with TickerProviderStateMixin{

  @override
  void initState() {
    // _controller = AnimationController(
    //   vsync:this ,
    //   duration: Duration(milliseconds: 1000),
    // );
    // animation = CurvedAnimation(
    //   parent: _controller,
    //   curve: Curves.easeIn,
    // );
    // _controller.forward();
    super.initState();
    
  }
  // @override
  // void didUpdateWidget(BottomMenubar oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.iconData != widget.iconData) {
  //     _startAnimation();
  //   }
  // }
  // _startAnimation() {
  //   _controller = AnimationController(
  //     vsync:this ,
  //     duration: Duration(milliseconds: 1000),
  //   );
  //   animation = CurvedAnimation(
  //     parent: _controller,
  //     curve: Curves.easeIn,
  //   );
  //   _controller.forward();
  // }
  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }
  final iconList = <IconData>[
    Icons.home_outlined,
    Icons.search,
    Icons.leaderboard_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = <String>[
      l10n.bottomNavHome,
      l10n.bottomNavSearch,
      l10n.bottomNavLeaderboard,
      l10n.bottomNavProfile,
    ];
    var state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barColor = isDark ? AppColor.surfaceDark : theme.cardColor;
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: barColor,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withOpacity(isDark ? 0.25 : 0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navIcon(context, state, 0, labels),
                  _navIcon(context, state, 1, labels),
                ],
              ),
            ),
            const SizedBox(width: 64),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navIcon(context, state, 2, labels),
                  _navIcon(context, state, 3, labels),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(BuildContext context, AppState state, int index, List<String> labels) {
    final isActive = state.pageIndex == index;
    final theme = Theme.of(context);
    final Color activeColor = Colors.white;
    final Color inactiveColor =
        theme.colorScheme.onSurface.withOpacity(0.6);
    final color = isActive ? activeColor : inactiveColor;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(iconList[index], size: 24, color: color),
        const SizedBox(height: 2),
        Text(
          labels[index],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: color,
          ),
        ),
      ],
    );
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => state.setpageIndex = index),
          child: SizedBox(
            height: 56,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

