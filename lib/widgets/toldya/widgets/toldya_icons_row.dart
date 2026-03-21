import 'dart:io';

import 'package:toldya/model/userPegModel.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toldya/widgets/animated_bounce_button.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/customRoute.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/page/common/usersListPage.dart';
import 'package:toldya/helper/toldya_stake_flow.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/toldya/widgets/toldya_bottom_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:toldya/widgets/toldya/widgets/yes_no_stake_buttons_row.dart';

import '../../../model/user.dart';

class ToldyaIconsRow extends StatelessWidget {
  final FeedModel model;
  final Color iconColor;
  final Color iconEnableColor;
  final double size;
  final bool isToldyaDetail;
  final ToldyaType type;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ToldyaIconsRow(
      {Key? key,
      required this.model,
      required this.iconColor,
      required this.iconEnableColor,
      required this.size,
      this.isToldyaDetail = false,
      required this.type,
      required this.scaffoldKey})
      : super(key: key);

  Widget _likeCommentsIcons(BuildContext context, FeedModel model) {
    double getPercent(){
      final total = sumOfVote(model.unlikeList ?? []) + sumOfVote(model.likeList ?? []);
      if (total == 0) return 0.5;
      final percent = sumOfVote(model.likeList ?? []) / total;
      return percent.isNaN ? 0.5 : percent;
    }
    final totalPool = sumOfVote(model.likeList ?? []) + sumOfVote(model.unlikeList ?? []);
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          YesNoStakeButtonsRow(
            yesPercent: (getPercent() * 100).round(),
            noPercent: (100 - (getPercent() * 100).round()).clamp(0, 100),
            onYesTap: () => openToldyaStakeFlowWithFeedback(
              context: context,
              model: model,
              commentFlag: AppIcon.evetCommentFlag,
              type: type,
              scaffoldKey: scaffoldKey,
            ),
            onNoTap: () => openToldyaStakeFlowWithFeedback(
              context: context,
              model: model,
              commentFlag: AppIcon.hayirCommentFlag,
              type: type,
              scaffoldKey: scaffoldKey,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '💰 ${AppLocalizations.of(context)!.amountPlayed(k_m_b_generator(totalPool))}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              _buildFooterTime(context),
            ],
          ),
        ]);
  }

  Widget _buildFooterTime(BuildContext context) {
    final countdownLong = getCountdownLong(model.endDate);
    final isLive = !isToldyaStakeClosed(model.statu, model.endDate) && (model.statu == Statu.statusLive);
    if (isLive && countdownLong.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.red)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 600.ms)
              .fadeOut(duration: 600.ms),
          SizedBox(width: 6),
          Text(
            '${AppLocalizations.of(context)!.liveLabel} • ${AppLocalizations.of(context)!.timeLeftLabel}: $countdownLong',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
          ),
        ],
      );
    }
    return Text(
      AppLocalizations.of(context)!.predictionEnded,
      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
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
                ? customText(AppLocalizations.of(context)!.forIos,
                    style: TextStyle(color: Theme.of(context).primaryColor))
                : customText(AppLocalizations.of(context)!.forAndroid,
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
    bool isRetoldyaAvailable = (model.retoldyaCount ?? 0) > 0;
    bool isLikeRetoldyaAvailable = isRetoldyaAvailable || isLikeAvailable;
    return Column(
      children: <Widget>[
        Divider(
          endIndent: 10,
          height: 0,
        ),
        AnimatedContainer(
            padding:
                EdgeInsets.symmetric(vertical: isLikeRetoldyaAvailable ? 12 : 0),
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
                    child: customText(AppLocalizations.of(context)!.iSayYes,
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
                    child: customText(AppLocalizations.of(context)!.iSayNo,
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
        !isLikeRetoldyaAvailable
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
          pageTitle: AppLocalizations.of(context)!.votersList,
          userIdsList: list.map((userId) => userId.userId).toList(),
          emptyScreenText: AppLocalizations.of(context)!.noVotesYet,
          emptyScreenSubTileText: AppLocalizations.of(context)!.voteListEmptySubtitle,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        isToldyaDetail ? _timeWidget(context) : SizedBox(),
        isToldyaDetail ? _likeCommentsIcons(context, model):SizedBox(),
        isToldyaDetail ? _likeCommentWidget(context) : SizedBox(),
        isToldyaDetail ? sizedBox() : _likeCommentsIcons(context, model)
      ],
    ));
  }
}
