import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/topicMap.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/widgets/newWidget/customUrlText.dart';
import 'package:bendemistim/widgets/newWidget/title_text.dart';
import 'package:bendemistim/widgets/tweet/widgets/parentTweet.dart';
import 'package:bendemistim/widgets/tweet/widgets/tweetIconsRow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../customWidgets.dart';
import 'widgets/retweetWidget.dart';
import 'widgets/tweetImage.dart';

/// Statü etiketinin (Beklemede/İncelemede/AI reddi) kartta gösterilmesi gerekiyor mu?
bool _showStatuBadge(int? statu) {
  if (statu == null) return false;
  return statu == Statu.statusPending ||
      statu == Statu.statusPendingAiReview ||
      statu == Statu.statusRejectedByAi;
}

class Toldya extends StatelessWidget {
  final FeedModel model;
  final Widget? trailing;
  final ToldyaType type;
  final bool isDisplayOnProfile;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const Toldya({
    Key? key,
    required this.model,
    this.trailing,
    this.type = ToldyaType.Toldya,
    this.isDisplayOnProfile = false,
    this.scaffoldKey,
  }) : super(key: key);

  void onLongPressedToldya(BuildContext context) {
    if (type == ToldyaType.Detail || type == ToldyaType.ParentToldya) {
      copyToClipBoard(
          scaffoldKey: scaffoldKey ?? GlobalKey<ScaffoldState>(),
          text: model.description ?? "",
          message: "Panoya kopyala");
    }
  }

  void onTapToldya(BuildContext context) {
    var feedstate = Provider.of<FeedState>(context, listen: false);
    if (type == ToldyaType.Detail || type == ToldyaType.ParentToldya) {
      return;
    }
    if (type == ToldyaType.Toldya && !isDisplayOnProfile) {
      feedstate.clearAllDetailAndReplyToldyaStack();
    }
    feedstate.getpostDetailFromDatabase(model.key ?? '', model: model);
    Navigator.of(context).pushNamed('/FeedPostDetail/' + (model.key ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        /// Left vertical bar of a toldya
        type != ToldyaType.ParentToldya
            ? SizedBox.shrink()
            : Positioned.fill(
                child: Container(
                  margin: EdgeInsets.only(
                    left: 38,
                    top: 75,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 3.0, color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
        InkWell(
          onLongPress: () {
            onLongPressedToldya(context);
          },
          onTap: () {
            onTapToldya(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  top: type == ToldyaType.Toldya || type == ToldyaType.Reply
                      ? 12
                      : 0,
                ),
                child: type == ToldyaType.Toldya || type == ToldyaType.Reply
                    ? _ToldyaBody(
                        isDisplayOnProfile: isDisplayOnProfile,
                        model: model,
                        trailing: trailing ?? SizedBox.shrink(),
                        type: type,
                      )
                    : _ToldyaDetailBody(
                        isDisplayOnProfile: isDisplayOnProfile,
                        model: model,
                        trailing: trailing ?? SizedBox.shrink(),
                        type: type,
                      ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: ToldyaImage(
                  model: model,
                  type: type,
                ),
              ),
              model.childRetoldyaKey == null
                  ? SizedBox.shrink()
                  : RetoldyaWidget(
                      childRetoldyaKey: model.childRetoldyaKey!,
                      type: type,
                      isImageAvailable:
                          model.imagePath != null && (model.imagePath?.isNotEmpty ?? false),
                    ),
              model.parentkey != null && model.childRetoldyaKey == null
                  ? SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only(
                          left: type == ToldyaType.Detail ? 10 : 12, right: 12, bottom: 12),
                      child: ToldyaIconsRow(
                        type: type,
                        model: model,
                        isTweetDetail: type == ToldyaType.Detail,
                        iconColor: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                        iconEnableColor: ToldyaColor.ceriseRed,
                        size: 20,
                        scaffoldKey: scaffoldKey ?? GlobalKey<ScaffoldState>(),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToldyaBody extends StatelessWidget {
  final FeedModel model;
  final Widget trailing;
  final ToldyaType type;
  final bool isDisplayOnProfile;

  const _ToldyaBody(
      {Key? key, required this.model, Widget? trailing, required this.type, required this.isDisplayOnProfile})
      : trailing = trailing ?? const SizedBox.shrink(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var authstate = Provider.of<AuthState>(context, listen: false);

    void addFavToldya(BuildContext context) {
      var state = Provider.of<FeedState>(context, listen: false);
      // var authState = Provider.of<AuthState>(context, listen: false);
      state.addFavToToldya(model, authstate.userId);
    }

    void shareToldya(BuildContext context) async {
      Utility.createLinkToShare(
        context,
        "toldya/${model.key}",
        socialMetaTagParameters: SocialMetaTagParameters(
            description: model.description ??
                "${model.user?.displayName ?? ''} Toldya uygulamasında bir toldya paylaştı.",
            title: "Toldya",
            imageUrl: Uri.parse(
                "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw")),
      );
    }

    Widget _userAvater(String userId) {
      return FutureBuilder(
        future: authstate.getuserDetail(userId),
        //  initialData: InitialData,
        builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            return GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/ProfilePage/' + (data.userId ?? ''));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppNeon.orange.withOpacity(0.8),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppNeon.orange.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        color: Theme.of(context).cardColor,
                        padding: EdgeInsets.all(2),
                        child: customProfileImage(context, data.profilePic, userId: data.userId, height: 44),
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: authstate.getuserDetail(model.user?.userId ?? ''),
                    //  initialData: InitialData,
                    builder: (BuildContext context,
                        AsyncSnapshot<UserModel?> snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        // name(snapshot.data.displayName);
                        return ratingBar(snapshot.data!.rank ?? 0, 3, context,
                            itemSize: 11.0);
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      );
    }

    double descriptionFontSize = type == ToldyaType.Toldya
        ? 15
        : type == ToldyaType.Detail || type == ToldyaType.ParentToldya
            ? 18
            : 14;
    FontWeight descriptionFontWeight =
        type == ToldyaType.Toldya || type == ToldyaType.Toldya
            ? FontWeight.w400
            : FontWeight.w400;
    final topicLabel = topic.topicMap[model.topic ?? ''] ?? model.topic ?? 'Genel';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: 14),
        Container(width: 52, height: 78, child: _userAvater(model.user?.userId ?? '')),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: TitleText(
                            model.user?.displayName ?? '',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            overflow: TextOverflow.ellipsis,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(width: 6),
                        _CountdownChip(endDate: model.endDate),
                      ],
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.fill,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CupertinoButton(
                          minSize: double.minPositive,
                          padding: EdgeInsets.all(5.0),
                          child: Icon(
                            (model.favList ?? [])
                                .any((userId) => userId == authstate.userId)
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColor.primary,
                              size: 20
                          ),
                          onPressed: () {
                              addFavToldya(context);
                          },
                        ),
                        CupertinoButton(
                          minSize: double.minPositive,
                          padding: EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.send_to_mobile,
                            color: AppColor.darkGrey,
                              size: 20
                          ),
                          onPressed: () {
                            shareToldya(context);
                          },
                        ),
                        Container(child: trailing == null ? SizedBox() : trailing),
                      ],
                    ),
                  ),
                ],
              ),
              if (model.topic != null && (model.topic ?? '').isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      topicLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                ),
              if (_showStatuBadge(model.statu))
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: model.statu == Statu.statusRejectedByAi
                              ? Colors.red.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              model.statu == Statu.statusRejectedByAi ? Icons.block : Icons.pending_actions,
                              size: 14,
                              color: model.statu == Statu.statusRejectedByAi ? Colors.red : Colors.orange,
                            ),
                            SizedBox(width: 4),
                            Text(
                              getStatuLabel(model.statu),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: model.statu == Statu.statusRejectedByAi ? Colors.red : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (model.statu == Statu.statusRejectedByAi && (model.aiModerationReason ?? '').isNotEmpty) ...[
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            model.aiModerationReason!,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              model.description == null
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: UrlText(
                        text: model.description,
                        onHashTagPressed: (tag) {
                          cprint(tag);
                        },
                        style: GoogleFonts.sawarabiMincho(
                          fontSize: descriptionFontSize,
                          fontWeight: descriptionFontWeight,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        urlStyle: TextStyle(
                            color: AppNeon.cyan,
                            fontSize: descriptionFontSize,
                            fontWeight: descriptionFontWeight),
                      ),
                    ),
            ],
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}

class _ToldyaDetailBody extends StatelessWidget {
  final FeedModel model;
  final Widget trailing;
  final ToldyaType type;
  final bool isDisplayOnProfile;

  const _ToldyaDetailBody(
      {Key? key, required this.model, required this.trailing, required this.type, required this.isDisplayOnProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    var authstate = Provider.of<AuthState>(context, listen: false);
    double descriptionFontSize = type == ToldyaType.Toldya
        ? getDimention(context, 15)
        : type == ToldyaType.Detail
            ? getDimention(context, 18)
            : type == ToldyaType.ParentToldya
                ? getDimention(context, 14)
                : 10;

    FontWeight descriptionFontWeight =
        type == ToldyaType.Toldya || type == ToldyaType.Toldya
            ? FontWeight.w300
            : FontWeight.w400;
    void addFavToldya(BuildContext context) {
      var state = Provider.of<FeedState>(context, listen: false);
      // var authState = Provider.of<AuthState>(context, listen: false);
      state.addFavToToldya(model, authstate.userId);
    }

    void shareToldya(BuildContext context) async {
      Utility.createLinkToShare(
        context,
        "toldya/${model.key}",
        socialMetaTagParameters: SocialMetaTagParameters(
            description: model.description ??
                "${model.user?.displayName ?? ''} Toldya uygulamasında bir toldya paylaştı.",
            title: "Toldya",
            imageUrl: Uri.parse(
                "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw")),
      );
    }
    Widget _userAvater(String userId) {
      return FutureBuilder(
        future: authstate.getuserDetail(userId),
        //  initialData: InitialData,
        builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            return GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/ProfilePage/' + (data.userId ?? ''));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  customProfileImage(context, data.profilePic, userId: data.userId),
                  // FutureBuilder(
                  //   future: authstate.getuserDetail(model.user.userId),
                  //   //  initialData: InitialData,
                  //   builder: (BuildContext context,
                  //       AsyncSnapshot<UserModel> snapshot) {
                  //     if (snapshot.hasData) {
                  //       // name(snapshot.data.displayName);
                  //       return ratingBar(snapshot.data.rank, 3, context,
                  //           itemSize: 11.0);
                  //     } else {
                  //       return Container();
                  //     }
                  //   },
                  // ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      );
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        model.parentkey != null &&
                model.childRetoldyaKey == null &&
                type != ToldyaType.ParentToldya
            ? ParentToldyaWidget(
                childRetoldyaKey: model.parentkey!,
                type: ToldyaType.ParentToldya,
                isImageAvailable: false,
                trailing: trailing)
            : SizedBox.shrink(),
        Container(
          width: fullWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 1),
                leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/ProfilePage/' + (model?.userId ?? ''));
                  },
                  child:  Container(width: 40, height: 60, child: _userAvater(model.user?.userId ?? '')),
                ),
                title: Row(
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: 0, maxWidth: fullWidth(context) * .31),
                      child: TitleText(model.user?.displayName ?? '',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 2),

                    customText('· ${getEndTime(model.endDate ?? '')}',
                        style: userNameStyle),
                    // model.user.isVerified
                    //     ? customIcon(
                    //         context,
                    //         icon: AppIcon.blueTick,
                    //         istwitterIcon: true,
                    //         iconColor: AppColor.primary,
                    //         size: 13,
                    //         paddingIcon: 3,
                    //       )
                    //     : SizedBox(width: 0),
                    SizedBox(
                      width: (model.user?.isVerified ?? false) ? 1 : 0,
                    ),
                  ],
                ),
                subtitle:
                    customText('${model.user?.userName ?? ''}', style: userNameStyle),
                trailing:
                FittedBox(
                  fit: BoxFit.fill,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CupertinoButton(
                        minSize: double.minPositive,
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                            (model.favList ?? [])
                                .any((userId) => userId == authstate.userId)
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColor.primary,
                            size: 20
                        ),
                        onPressed: () {
                          addFavToldya(context);
                        },
                      ),
                      CupertinoButton(
                        minSize: double.minPositive,
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                            Icons.send_to_mobile,
                            color: AppColor.darkGrey,
                            size: 20
                        ),
                        onPressed: () {
                          shareToldya(context);
                        },
                      ),
                      Container(child: trailing == null ? SizedBox() : trailing),
                    ],
                  ),
                ),
              ),
              if (_showStatuBadge(model.statu))
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: model.statu == Statu.statusRejectedByAi
                              ? Colors.red.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              model.statu == Statu.statusRejectedByAi ? Icons.block : Icons.pending_actions,
                              size: 14,
                              color: model.statu == Statu.statusRejectedByAi ? Colors.red : Colors.orange,
                            ),
                            SizedBox(width: 4),
                            Text(
                              getStatuLabel(model.statu),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: model.statu == Statu.statusRejectedByAi ? Colors.red : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (model.statu == Statu.statusRejectedByAi && (model.aiModerationReason ?? '').isNotEmpty) ...[
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            model.aiModerationReason!,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              model.description == null
                  ? SizedBox()
                  : Padding(
                      padding: type == ToldyaType.ParentToldya
                          ? EdgeInsets.only(left: 80, right: 16)
                          : EdgeInsets.symmetric(horizontal: 16),
                      child: UrlText(
                        text: model.description,
                        onHashTagPressed: (tag) {
                          cprint(tag);
                        },
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: descriptionFontSize,
                          fontWeight: descriptionFontWeight,
                        ),
                        urlStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: descriptionFontSize,
                          fontWeight: descriptionFontWeight,
                        ),
                      ),
                    )
            ],
          ),
        ),
      ],
    );
  }
}

/// Belirgin geri sayım chip'i (acil hissi, okunaklı)
class _CountdownChip extends StatelessWidget {
  final String? endDate;

  const _CountdownChip({Key? key, this.endDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = getEndTime(endDate ?? '');
    if (text.isEmpty) return SizedBox.shrink();
    final isUrgent = text == 'bitti' || text.contains('sn') || text.contains('dk');
    final color = isUrgent ? AppNeon.red : Theme.of(context).primaryColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
