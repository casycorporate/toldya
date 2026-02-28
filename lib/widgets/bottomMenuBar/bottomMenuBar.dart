import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/state/appState.dart';
import 'package:provider/provider.dart';
import '../customWidgets.dart';

/// Kavisli bar: üst köşeler yuvarlak, ortada FAB için yarım daire çentik.
/// Guest (FAB rect) varsa ona göre, yoksa bar ortasına çentik çizer.
class _CurvedNotchedRectangle extends NotchedShape {
  const _CurvedNotchedRectangle({
    this.cornerRadius = 16,
    this.notchRadius = 28,
  });

  final double cornerRadius;
  final double notchRadius;

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    final w = host.width;
    final h = host.height;
    final r = math.min(cornerRadius, math.min(h / 2, w / 4));
    final nr = math.min(notchRadius, (h - 2) / 2);
    final centerX = guest != null ? guest!.center.dx : host.center.dx;
    final path = Path();

    // Sol alt -> sol üst (yuvarlak köşe)
    path.moveTo(0, h);
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r), clockwise: false);
    // Üst kenar -> çentiğin sol ucu
    path.lineTo(centerX - nr, 0);
    // Çentik: aşağı inen yarım daire (arcTo ile açık açı)
    final notchRect = Rect.fromLTWH(centerX - nr, 0, nr * 2, nr * 2);
    path.arcTo(notchRect, math.pi, math.pi, false);
    // Üst kenar -> sağ üst
    path.lineTo(w - r, 0);
    path.arcToPoint(Offset(w, r), radius: Radius.circular(r), clockwise: false);
    path.lineTo(w, h);
    path.close();
    return path;
  }
}

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
    Icons.notifications_none,
    Icons.person_outline,
  ];

  final labels = <String>[
    'Ana',
    'Arama',
    'Bildirim',
    'Profil',
  ];

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barColor = isDark ? AppColor.surfaceDark : theme.cardColor;
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: barColor,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withOpacity(isDark ? 0.7 : 0.3),
              width: 0.6,
            ),
          ),
        ),
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navIcon(context, state, 0),
              _navIcon(context, state, 1),
              const SizedBox(width: 56),
              _navIcon(context, state, 2),
              _navIcon(context, state, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navIcon(BuildContext context, AppState state, int index) {
    final isActive = state.pageIndex == index;
    final theme = Theme.of(context);
    final Color activeColor = Colors.white;
    final Color inactiveColor =
        theme.colorScheme.onSurface.withOpacity(0.6);
    final color = isActive ? activeColor : inactiveColor;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => state.setpageIndex = index),
        child: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconList[index], size: 24, color: color),
              const SizedBox(height: 2),
              Text(
                labels[index],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

