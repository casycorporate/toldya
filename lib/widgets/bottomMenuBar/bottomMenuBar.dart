
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/state/appState.dart';
import 'package:bendemistim/widgets/bottomMenuBar/tabItem.dart';
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
  Widget _iconRow(){
    var state = Provider.of<AppState>(context,);
    return Container(
      height: 50,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, boxShadow: [
            BoxShadow(
                color: Colors.black12, offset: Offset(0,-.1), blurRadius: 0)
          ]),
      child:  Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _icon(widget.iconData ?? Icons.home,0,icon:0 == state.pageIndex ? AppIcon.homeFill : AppIcon.home,isCustomIcon:true),
                  _icon(widget.iconData ?? Icons.search,1,icon:1 == state.pageIndex ? AppIcon.searchFill : AppIcon.search,isCustomIcon:true),
                  _icon(widget.iconData ?? Icons.notifications,2,icon: 2 == state.pageIndex ? AppIcon.notificationFill : AppIcon.notification,isCustomIcon:true),
                  // _icon(null,3,icon:3 == state.pageIndex ? AppIcon.messageFill :AppIcon.messageEmpty,isCustomIcon:true),
                ],
              ),
    );
  }
  Widget _icon(IconData iconData,int index,{bool isCustomIcon = false, IconData? icon}){
    var state = Provider.of<AppState>(context,);
    return Expanded(
      child:  Container(
            height: double.infinity,
            width: double.infinity,
            child: AnimatedAlign(
              duration: Duration(milliseconds: ANIM_DURATION),
              curve: Curves.easeIn,
              alignment: Alignment(0,  ICON_ON),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: ANIM_DURATION),
                opacity:  ALPHA_ON,
                child: IconButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  padding: EdgeInsets.all(0),
                  alignment: Alignment(0, 0),
                  icon: isCustomIcon ? customIcon(context,icon: icon ?? iconData, size: 22, istwitterIcon: true, isEnable: index == state.pageIndex) :
                  Icon(iconData,
                   color:index == state.pageIndex ? Theme.of(context).primaryColor: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                  ),
                  onPressed: () {
                      setState(() {
                        state.setpageIndex = index;
                      });
                  },
                ),
              ),
            ),
          ),
    );
  }
  final iconList = <IconData>[
    Icons.home_filled,
    Icons.search,
    Icons.notifications,
    Icons.account_box,
  ];
   // AnimationController _controller;
   // Animation<double> animation;
 
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AppState>(context,);
     return AnimatedBottomNavigationBar.builder(
       itemCount: iconList.length,
       tabBuilder: (int index, bool isActive) {
         final color = isActive ? HexColor('#FFA400') : Colors.white;
         return Column(
           mainAxisSize: MainAxisSize.min,
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(
               iconList[index],
               size: 24,
               color: color,
             ),
             // const SizedBox(height: 4),
             // Padding(
             //   padding: const EdgeInsets.symmetric(horizontal: 8),
             //   child: Text(
             //     "brightness $index",
             //     maxLines: 1,
             //     style: TextStyle(color: color),
             //   ),
             // )
           ],
         );
       },
       backgroundColor: HexColor('#373A36'),
       activeIndex: state.pageIndex,
       splashColor: HexColor('#FFA400'),
       splashSpeedInMilliseconds: 300,
       notchSmoothness: NotchSmoothness.verySmoothEdge,
       gapLocation: GapLocation.center,
       leftCornerRadius: 32,
       rightCornerRadius: 32,
       onTap: (index) => setState(() => state.setpageIndex = index),
     );
   }
}

