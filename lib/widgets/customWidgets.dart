import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bendemistim/widgets/newWidget/DataHolder.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';
import 'newWidget/ImageGridItem.dart';

Widget customTitleText(String title, {BuildContext? context}) {
  final color = context != null
      ? Theme.of(context).colorScheme.onSurface
      : Colors.black87;
  return Text(
    title,
    style: TextStyle(
      color: color,
      fontFamily: 'HelveticaNeue',
      fontWeight: FontWeight.w900,
      fontSize: 20,
    ),
  );
}

Widget heading(String heading,
    {double horizontalPadding = 10, BuildContext? context}) {
  double fontSize = 16;
  if (context != null) {
    fontSize = getDimention(context, 16);
  }
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
    child: Text(
      heading,
      style: (AppTheme.apptheme.textTheme.displayLarge ?? TextStyle())
          .copyWith(fontSize: fontSize),
    ),
  );
}

Widget userImage(String path, {double height = 100}) {
  return Container(
    child: Container(
      width: height,
      height: height,
      alignment: FractionalOffset.topCenter,
      decoration: BoxDecoration(
        boxShadow: shadow,
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(height / 2),
        image: DecorationImage(image: NetworkImage(path)),
      ),
    ),
  );
}

Widget customIcon(
  BuildContext context, {
  required IconData icon,
  bool isEnable = false,
  double size = 18,
  bool istwitterIcon = true,
  bool isFontAwesomeSolid = false,
  Color? iconColor,
  double paddingIcon = 10,
}) {
  final color = iconColor ?? Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
  return Padding(
    padding: EdgeInsets.only(bottom: istwitterIcon ? paddingIcon : 0),
    child: Icon(
      icon,
      size: size,
      color: isEnable ? Theme.of(context).primaryColor : color,
    ),
  );
}

Widget customTappbleIcon(BuildContext context, IconData icon,
    {double size = 16,
    bool isEnable = false,
    Function(bool, int)? onPressed1,
    bool isBoolValue = false,
    int id = 0,
    Function? onPressed2,
    bool isFontAwesomeRegular = false,
    bool istwitterIcon = false,
    bool isFontAwesomeSolid = false,
    Color? iconColor,
    EdgeInsetsGeometry? padding}) {
  final paddingVal = padding ?? EdgeInsets.all(10);
  return MaterialButton(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    minWidth: 10,
    height: 10,
    padding: paddingVal,
    shape: CircleBorder(),
    color: Colors.transparent,
    elevation: 0,
    onPressed: () {
      if (onPressed1 != null) {
        onPressed1(isBoolValue, id);
      } else if (onPressed2 != null) {
        onPressed2();
      }
    },
    child: customIcon(context,
        icon: icon,
        size: size,
        isEnable: isEnable,
        istwitterIcon: istwitterIcon,
        isFontAwesomeSolid: isFontAwesomeSolid,
        iconColor: iconColor ?? Colors.grey),
  );
}

Widget customText(String msg,
    {Key? key,
    TextStyle? style,
    TextAlign textAlign = TextAlign.justify,
    TextOverflow overflow = TextOverflow.visible,
    BuildContext? context,
    bool softwrap = true}) {
  if (msg.isEmpty) {
    return SizedBox(
      height: 0,
      width: 0,
    );
  } else {
    TextStyle? textStyle = style ??
        (context != null ? Theme.of(context).textTheme.bodyMedium : null);
    if (context != null && textStyle != null) {
      var fontSize =
          textStyle.fontSize ?? Theme.of(context).textTheme.bodyLarge?.fontSize;
      textStyle = textStyle.copyWith(
        fontSize: fontSize != null ? fontSize - (fullWidth(context) <= 375 ? 2 : 0) : null,
      );
    }
    return Text(
      msg,
      style: textStyle,
      textAlign: textAlign,
      overflow: overflow,
      softWrap: softwrap,
      key: key,
    );
  }
}

Widget customImage(
  BuildContext context,
  String path, {
  double height = 50,
  bool isBorder = false,
}) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade100, width: isBorder ? 2 : 0),
    ),
    child: CircleAvatar(
      maxRadius: height / 2,
      backgroundColor: Theme.of(context).cardColor,
      backgroundImage: customAdvanceNetworkImage(path ?? dummyProfilePic),
    ),
  );
}

/// Profil resmi: boşsa varsayılan 5 avatar'dan userId'ye göre biri, değilse URL'den gösterir.
Widget customProfileImage(
  BuildContext context,
  String? profilePic, {
  String? userId,
  double height = 50,
  bool isBorder = false,
}) {
  final effectivePath = (profilePic != null && profilePic.trim().isNotEmpty)
      ? profilePic
      : DefaultProfilePics.assetForUser(userId);
  final isAsset = effectivePath.startsWith('assets/');
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade100, width: isBorder ? 2 : 0),
    ),
    child: CircleAvatar(
      maxRadius: height / 2,
      backgroundColor: Theme.of(context).cardColor,
      backgroundImage: isAsset
          ? AssetImage(effectivePath)
          : customAdvanceNetworkImage(effectivePath),
    ),
  );
}

Widget ratingBar(int initialRating,int itemCount,
    BuildContext context, {
      bool ignoreGestures = true,
      double itemSize =10.0
    }) {
  return Container(
    height: 10,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      // border: Border.all(color: Colors.grey.shade100, width:2),
    ),
    child:  RatingBar(
        ratingWidget: RatingWidget(
          full: Image.asset("assets/icons/prometheusfull.png"),
          half:Image.asset("assets/icons/prometheushalf.png"),
          empty:Image.asset("assets/icons/prometheusempty.png"),
        ),
      initialRating: (initialRating / 100).toDouble(),
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: itemCount,
      itemSize: itemSize,
      itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
      ignoreGestures: ignoreGestures,
      onRatingUpdate: (_) {},
    ),
  );
}

double fullWidth(BuildContext context) {
  // cprint(MediaQuery.of(context).size.width.toString());
  return MediaQuery.of(context).size.width;
}

double fullHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

Widget customInkWell(
    {Widget? child,
    BuildContext? context,
    Function(bool, int)? function1,
    Function? onPressed,
    bool isEnable = false,
    int no = 0,
    Color color = Colors.transparent,
    Color? splashColor,
    BorderRadius? radius}) {
  final splash = splashColor ?? (context != null ? Theme.of(context).primaryColorLight : Colors.grey);
  final borderRadius = radius ?? BorderRadius.circular(0);
  return Material(
    color: color,
    child: InkWell(
      borderRadius: borderRadius,
      onTap: () {
        if (function1 != null) {
          function1(isEnable, no);
        } else if (onPressed != null) {
          onPressed();
        }
      },
      splashColor: splash,
      child: child,
    ),
  );
}

SizedBox sizedBox({double height = 5, String? title}) {
  return SizedBox(
    height: title == null || title.isEmpty ? 0 : height,
  );
}

Widget customNetworkImage(String path, {BoxFit fit = BoxFit.contain}) {
  return CachedNetworkImage(
    fit: fit,
    imageUrl: path ?? dummyProfilePic,
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: fit,
        ),
      ),
    ),
    placeholderFadeInDuration: Duration(milliseconds: 500),
    placeholder: (context, url) => Container(
      color: Color(0xffeeeeee),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}

dynamic customAdvanceNetworkImage(String path) {
  if (path == null) {
    path = dummyProfilePic;
  }
  return CachedNetworkImageProvider(
    path ?? dummyProfilePic,
  );
}

void showAlert(BuildContext context,
    {required Function onPressedOk,
    required String title,
    String okText = 'OK',
    String cancelText = 'Cancel'}) async {
  showDialog(
      context: context,
      builder: (context) {
        return customAlert(context,
            onPressedOk: onPressedOk,
            title: title,
            okText: okText,
            cancelText: cancelText);
      });
}

Widget customAlert(BuildContext context,
    {required Function onPressedOk,
    required String title,
    String okText = 'OK',
    String cancelText = 'Cancel'}) {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  return AlertDialog(
    title: Text('Alert',
        style: TextStyle(
            fontSize: getDimention(context, 25),
            color: onSurface.withOpacity(0.8))),
    content: customText(title,
        context: context,
        style: TextStyle(color: onSurface.withOpacity(0.7))),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(cancelText,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          onPressedOk();
        },
        child: Text(okText, style: TextStyle(color: Theme.of(context).primaryColor)),
      )
    ],
  );
}

void customSnackBar(GlobalKey<ScaffoldState> _scaffoldKey, String msg,
    {double height = 30, Color backgroundColor = Colors.black}) {
  final ctx = _scaffoldKey.currentContext;
  if (ctx == null) return;
  ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: backgroundColor,
    content: Text(
      msg,
      style: TextStyle(
        color: Colors.white,
      ),
    ),
  );
  ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
}

Widget emptyListWidget(BuildContext context, String title,
    {String subTitle = '', String image = 'emptyImage.png'}) {
  return Container(
    color: Color(0xfffafafa),
    child: Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: fullWidth(context) * .95,
            height: fullWidth(context) * .95,
            decoration: BoxDecoration(
              // color: Color(0xfff1f3f6),
              boxShadow: <BoxShadow>[
                // BoxShadow(blurRadius: 50,offset: Offset(0, 0),color: Color(0xffe2e5ed),spreadRadius:20),
                BoxShadow(
                  offset: Offset(0, 0),
                  color: Color(0xffe2e5ed),
                ),
                BoxShadow(
                    blurRadius: 50,
                    offset: Offset(10, 0),
                    color: Color(0xffffffff),
                    spreadRadius: -5),
              ],
              shape: BoxShape.circle,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/$image', height: 170),
              SizedBox(
                height: 20,
              ),
              customText(
                title,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: Color(0xff9da9c7)) ?? TextStyle(color: Color(0xff9da9c7)),
              ),
              customText(
                subTitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Color(0xffabb8d6)) ?? TextStyle(color: Color(0xffabb8d6)),
              ),
            ],
          )
        ],
      ),
    ),
  );
}

Widget loader(BuildContext context) {
  return Center(
    child: CustomScreenLoader(
      height: 80,
      width: 80,
      backgroundColor: Colors.transparent,
    ),
  );
}

Widget customSwitcherWidget(
    {required child, Duration duraton = const Duration(milliseconds: 500)}) {
  return AnimatedSwitcher(
    duration: duraton,
    transitionBuilder: (Widget child, Animation<double> animation) {
      return ScaleTransition(child: child, scale: animation);
    },
    child: child,
  );
}

Widget customExtendedText(String text, bool isExpanded,
    {BuildContext? context,
    TextStyle? style,
    required Function onPressed,
    required TickerProvider provider,
    AlignmentGeometry alignment = Alignment.topRight,
    required EdgeInsetsGeometry padding,
    int wordLimit = 100,
    bool isAnimated = true}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      AnimatedSize(
        duration: Duration(milliseconds: (isAnimated ? 500 : 0)),
        child: ConstrainedBox(
          constraints: isExpanded
              ? BoxConstraints()
              : BoxConstraints(maxHeight: wordLimit == 100 ? 100.0 : 260.0),
          child: customText(text,
              softwrap: true,
              overflow: TextOverflow.fade,
              style: style,
              context: context,
              textAlign: TextAlign.start),
        ),
      ),
      text != null && text.length > wordLimit
          ? Container(
              alignment: alignment,
              child: InkWell(
                onTap: onPressed != null ? () => onPressed!() : null,
                child: Padding(
                  padding: padding,
                  child: Text(
                    !isExpanded ? 'more...' : 'Less...',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
              ),
            )
          : Container()
    ],
  );
}

double getDimention(context, double unit) {
  if (fullWidth(context) <= 360.0) {
    return unit / 1.3;
  } else {
    return unit;
  }
}

Widget customListTile(BuildContext context,
    {Widget? title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    Function? onTap}) {
  return customInkWell(
    context: context,
    onPressed: () {
      if (onTap != null) {
        onTap();
      }
    },
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 10,
          ),
          Container(
            width: 40,
            height: 40,
            child: leading ?? SizedBox.shrink(),
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            width: fullWidth(context) - 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: title ?? Container()),
                    trailing ?? Container(),
                  ],
                ),
                subtitle ?? SizedBox.shrink()
              ],
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    ),
  );
}

openImagePickerUseCameraAndGallery(
    BuildContext context, Function onImageSelected) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
        color: ToldyaColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text(
              'Bir resim seçin',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      'Kamerayı Kullan',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    onPressed: () {
                      getImageUseCameraAndGallery(
                          context, ImageSource.camera, onImageSelected);
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      'Galeriyi Kullan',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    onPressed: () {
                      getImageUseCameraAndGallery(
                          context, ImageSource.gallery, onImageSelected);
                    },
                  ),
                )
              ],
            )
          ],
        ),
      );
    },
  );
}

getImageUseCameraAndGallery(
    BuildContext context, ImageSource source, Function onImageSelected) {
  ImagePicker().pickImage(source: source, imageQuality: 50).then((XFile? file) {
    if (file != null) onImageSelected(File(file.path));
    Navigator.pop(context);
  });
}

openImagePicker(BuildContext context, Function onImageSelected,int type) {

  showModalBottomSheet(backgroundColor: Colors.transparent,
    context: context,
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
        color: ToldyaColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
        height: fullHeight(context) * 0.5,
        // padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text(
              'Bir resim seçin',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
                child: SingleChildScrollView(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(), //<--here
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: 12,
                      //number of grid items
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (context, index) {
                        return ImageGridItem(index:index,onImageSelected:onImageSelected,type:type); //populating with grid items
                      },
                    ))),
          ],
        ),
      );
    },
  ).whenComplete(() {
    requestedIndex.clear();
    imageData.clear();
    print('Hey there, I\'m calling after hide bottomSheet');
  });
}

getImage(BuildContext context, ImageSource source, Function onImageSelected) {
  ImagePicker().pickImage(source: source, imageQuality: 50).then((XFile? file) {
    if (file != null) onImageSelected(File(file.path));
    Navigator.pop(context);
  });
}
