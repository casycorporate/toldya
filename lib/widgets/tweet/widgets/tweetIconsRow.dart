import 'dart:io';

import 'package:bendemistim/model/userPegModel.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/customRoute.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/page/common/usersListPage.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../model/user.dart';

class ToldyaIconsRow extends StatelessWidget {
  final FeedModel model;
  final Color iconColor;
  final Color iconEnableColor;
  final double size;
  final bool isTweetDetail;
  final ToldyaType type;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ToldyaIconsRow(
      {Key? key,
      required this.model,
      required this.iconColor,
      required this.iconEnableColor,
      required this.size,
      this.isTweetDetail = false,
      required this.type,
      required this.scaffoldKey})
      : super(key: key);

  Widget _likeCommentsIcons(BuildContext context, FeedModel model) {
    var authState = Provider.of<AuthState>(context, listen: false);
    double getPercent(){
      final total = sumOfVote(model.unlikeList ?? []) + sumOfVote(model.likeList ?? []);
      if (total == 0) return 0.5;
      final percent = sumOfVote(model.likeList ?? []) / total;
      return percent.isNaN ? 0.5 : percent;
    }
    final closed = isBettingClosed(model.statu, model.endDate);
    final evetColor = model.feedResult == FeedResult.feedResultlike
        ? Color(0xFF2E7D32)
        : (model.likeList ?? []).any((e) => e.userId == authState.userId)
            ? Color(0xFF4CAF50)
            : Color(0xFF81C784);
    final hayirColor = model.feedResult == FeedResult.feedResultunLike
        ? Color(0xFFC62828)
        : (model.unlikeList ?? []).any((e) => e.userId == authState.userId)
            ? Color(0xFFE53935)
            : Color(0xFFE57373);
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: LinearPercentIndicator(
              percent: getPercent(),
              lineHeight: 8,
              animation: true,
              animationDuration: 600,
              barRadius: Radius.circular(4),
              leading: Text(
                k_m_b_generator(sumOfVote(model.likeList ?? [])),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: evetColor,
                  fontSize: 13,
                ),
              ),
              trailing: Text(
                k_m_b_generator(sumOfVote(model.unlikeList ?? [])),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: hayirColor,
                  fontSize: 13,
                ),
              ),
              backgroundColor: Color(0xFFE0E0E0),
              progressColor: evetColor,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _voteChip(
                  context,
                  label: 'Evet',
                  count: k_m_b_generator(sumOfVote(model.likeList ?? [])),
                  icon: Icons.thumb_up_rounded,
                  color: evetColor,
                  onPressed: () => _onVotePressed(context, authState, AppIcon.evetCommentFlag),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _voteChip(
                  context,
                  label: 'Hayır',
                  count: isTweetDetail ? '' : k_m_b_generator(sumOfVote(model.unlikeList ?? [])),
                  icon: Icons.thumb_down_rounded,
                  color: hayirColor,
                  onPressed: () => _onVotePressed(context, authState, AppIcon.hayirCommentFlag),
                ),
              ),
            ],
          ),
        ]);
  }

  void _onVotePressed(BuildContext context, AuthState authState, int commentFlag) {
    final closed = isBettingClosed(model.statu, model.endDate);
    if (!closed && (authState.userModel?.pegCount ?? 0) != 0) {
      ToldyaBottomSheet().openRetoldyabottomSheet(
          commentFlag, context,
          type: type, model: model, scaffoldKey: scaffoldKey);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          closed ? 'Kapandığı için seçim yapılamaz' : 'Kapak sayısı yetersiz olduğu için seçim yapılamaz',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black87,
      ));
    }
  }

  Widget _voteChip(BuildContext context, {
    required String label,
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                  if (count.isNotEmpty)
                    Text(
                      count,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconWidget(BuildContext context,
      {String? textB,
      String? text,
      IconData? icon,
      VoidCallback? onPressed,
      IconData? sysIcon,
      Color? iconColor,
      double size = 20,
      int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 30,
        child: InkWell(
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              customText(
                textB ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                  fontSize: size - 5,
                ),
                context: context,
              ),
              IconButton(
                onPressed: onPressed,
                icon: sysIcon != null
                    ? Icon(sysIcon, color: iconColor ?? Colors.grey, size: size)
                    : customIcon(
                        context,
                        size: size,
                        icon: icon ?? Icons.help_outline,
                        istwitterIcon: true,
                        iconColor: iconColor ?? Colors.grey,
                      ),
              ),
              // customText(
              //   text,
              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     color: iconColor,
              //     fontSize: size - 5,
              //   ),
              //   context: context,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 8),
        Row(
          children: <Widget>[
            SizedBox(width: 5),
            customText(getPostTime2(model.createdAt ?? ''), style: textStyle14),
            SizedBox(width: 5),
            Platform.isIOS
                ? customText('for ios',
                    style: TextStyle(color: Theme.of(context).primaryColor))
                : customText('for Android',
                    style: TextStyle(color: Theme.of(context).primaryColor))
          ],
        ),
        SizedBox(height: 5),
      ],
    );
  }

  Widget _likeCommentWidget(BuildContext context) {
    bool isLikeAvailable =
        ((model.likeCount ?? 0) > 0 || (model.unlikeCount ?? 0) > 0);
    bool isRetweetAvailable = (model.retweetCount ?? 0) > 0;
    bool isLikeRetweetAvailable = isRetweetAvailable || isLikeAvailable;
    return Column(
      children: <Widget>[
        Divider(
          endIndent: 10,
          height: 0,
        ),
        AnimatedContainer(
            padding:
                EdgeInsets.symmetric(vertical: isLikeRetweetAvailable ? 12 : 0),
            duration: Duration(milliseconds: 500),
            child: AnimatedCrossFade(
              firstChild: SizedBox.shrink(),
              secondChild: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  customSwitcherWidget(
                    duraton: Duration(milliseconds: 300),
                    child: customText(sumOfVote(model.likeList ?? []).toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                        key: ValueKey(model.likeCount)),
                  ),
                  InkWell(
                    onTap: () {
                      onLikeTextPressed(context, model.likeList ?? []);
                    },
                    child: customText('dedim',
                        style: subtitleStyle.copyWith(
                            color: ToldyaColor.cerulean)),
                  ),
                  SizedBox(width: fullWidth(context) * 0.4),
                  customSwitcherWidget(
                    duraton: Duration(milliseconds: 300),
                    child: customText(sumOfVote(model.unlikeList ?? []).toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                        key: ValueKey(model.unlikeCount)),
                  ),
                  InkWell(
                    onTap: () {
                      onLikeTextPressed(context, model.unlikeList ?? []);
                    },
                    child: customText('demedim',
                        style: subtitleStyle.copyWith(
                            color: ToldyaColor.cerulean)),
                  ),
                ],
              ),
              crossFadeState: !isLikeAvailable
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 300),
            )),
        !isLikeRetweetAvailable
            ? SizedBox.shrink()
            : Divider(
                endIndent: 10,
                height: 0,
              ),
      ],
    );
  }

  void addLikeToToldya(BuildContext context) {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.addLikeToToldya(model, authState.userId, 1);
  }

  void onLikeTextPressed(BuildContext context, List<UserPegModel> list) {
    Navigator.of(context).push(
      CustomRoute<bool>(
        builder: (BuildContext context) => UsersListPage(
          pageTitle: "Seçim yapanlar",
          userIdsList: list.map((userId) => userId.userId).toList(),
          emptyScreenText: "Bu gönderiye henüz seçim yapılmadı",
          emptyScreenSubTileText:
              "Bir kullanıcı bu gönderi için seçim yaptığında kullanıcı listesi burada gösterilecektir.",
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        isTweetDetail ? _timeWidget(context) : SizedBox(),
        isTweetDetail ? _likeCommentsIcons(context, model):SizedBox(),
        isTweetDetail ? _likeCommentWidget(context) : SizedBox(),
        isTweetDetail ? sizedBox() : _likeCommentsIcons(context, model)
      ],
    ));
  }
}
