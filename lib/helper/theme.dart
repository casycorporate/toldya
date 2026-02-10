import 'package:flutter/material.dart';


List<BoxShadow>  shadow = <BoxShadow>[BoxShadow(blurRadius: 10,offset: Offset(5, 5),color: AppTheme.apptheme.colorScheme.secondary,spreadRadius:1)];
String get description { return '';}
TextStyle get onPrimaryTitleText { return  TextStyle(color: Colors.white,fontWeight: FontWeight.w600);}
TextStyle get onPrimarySubTitleText { return  TextStyle(color: Colors.white,);}
BoxDecoration softDecoration =  BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(blurRadius: 8,offset: Offset(5, 5),color: Color(0xffe2e5ed),spreadRadius:5),
              BoxShadow(blurRadius: 8,offset: Offset(-5,-5),color: Color(0xffffffff),spreadRadius:5)
              ],
              color: Color(0xfff1f3f6)
          );
TextStyle get titleStyle { return  TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold,);}
TextStyle get subtitleStyle { return  TextStyle(color: AppColor.darkGrey,fontSize: 14,fontWeight: FontWeight.bold);}
TextStyle get userNameStyle { return  TextStyle(color: AppColor.darkGrey,fontSize: 12,fontWeight: FontWeight.bold);}
TextStyle get textStyle14 { return  TextStyle(color: AppColor.darkGrey,fontSize: 14,fontWeight: FontWeight.bold);}

class ToldyaColor {
  static final Color bondiBlue = Color.fromRGBO(0, 132, 180, 1.0);
  static final Color yesGreen = Color.fromRGBO(18, 176, 55, 1);
  static final Color okRed = Color.fromRGBO(102, 37, 17, 1);
  static final Color noRed = Color.fromRGBO(217, 4, 4, 1);
  static final Color cerulean = Color.fromRGBO(0, 172, 237, 1.0);
  static final Color spindle = Color.fromRGBO(192, 222, 237, 1.0);
  static final Color white = Color.fromRGBO(255, 255, 255, 1.0);
  static final Color black = Color.fromRGBO(0, 0, 0, 1.0);
  static final Color woodsmoke = Color.fromRGBO(20, 23, 2, 1.0);
  static final Color woodsmoke_50 = Color.fromRGBO(20, 23, 2, 0.5);
  static final Color mystic = Color.fromRGBO(230, 236, 240, 1.0);
  static final Color dodgetBlue =Color(0xfff7892b);// Color.fromRGBO(29, 162, 240, 1.0);
  static final Color dodgetBlue_50 = Color.fromRGBO(29, 162, 240, 0.5);
  static final Color paleSky = Color.fromRGBO(101, 119, 133, 1.0);
  static final Color ceriseRed = Color.fromRGBO(224, 36, 94, 1.0);
  static final Color paleSky50 = Color.fromRGBO(101, 118, 133, 0.5);
  static final Color  primaryColor = Colors.yellow.shade500;
}

class AppColor{
  static final Color primary = Color(0xffFFA400);
  static final Color secondary = Color(0xff14171A);
  static final Color darkGrey = Color(0xff1657786);
  static final Color lightGrey = Color(0xffAAB8C2);
  static final Color extraLightGrey = Color(0xffE1E8ED);
  static final Color extraExtraLightGrey = Color(0xfF5F8FA);
  static final Color white = Color(0xFFffffff);
}
class AppTheme{
  static final ThemeData apptheme = ThemeData(
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: ToldyaColor.white,
    primaryColor: AppColor.primary,
    cardColor: Colors.white,
    unselectedWidgetColor: Colors.grey,
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColor.white
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ToldyaColor.white,
      foregroundColor: Colors.black,
      iconTheme: IconThemeData(color: ToldyaColor.dodgetBlue,),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 26,
        fontStyle: FontStyle.normal),
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: titleStyle.copyWith(color: ToldyaColor.dodgetBlue),
      unselectedLabelColor: AppColor.darkGrey,
      unselectedLabelStyle: titleStyle.copyWith(color: AppColor.darkGrey),
      labelColor: ToldyaColor.dodgetBlue,
      labelPadding: EdgeInsets.symmetric(vertical: 12),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ToldyaColor.dodgetBlue,
    ),
    colorScheme: ColorScheme.light(
      primary: ToldyaColor.dodgetBlue,
      secondary: AppColor.secondary,
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onError: Colors.white,
    )
    );
}