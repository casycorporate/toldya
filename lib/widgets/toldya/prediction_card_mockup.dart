import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:toldya/widgets/animated_bounce_button.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/topicMap.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/customUrlText.dart';
import 'package:toldya/widgets/toldya/prediction_shared_ui.dart';
import 'package:toldya/widgets/toldya/widgets/toldya_bottom_sheet.dart';
import 'package:toldya/helper/toldya_stake_flow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:toldya/widgets/toldya/widgets/yes_no_stake_buttons_row.dart';

/// Mockup’a uygun tahmin kartı: soru üstte, countdown belirgin, progress + Evet/Hayır.
class PredictionCardMockup extends StatelessWidget {
  final FeedModel model;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const PredictionCardMockup({
    Key? key,
    required this.model,
    required this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalYes = sumOfVote(model.likeList ?? []);
    final totalNo = sumOfVote(model.unlikeList ?? []);
    final total = totalYes + totalNo;
    final percent = total == 0 ? 0.5 : totalYes / total;
    final closed = isToldyaStakeClosed(model.statu, model.endDate);
    final topicLabel = topic.topicMap[model.topic ?? ''] ?? model.topic ?? 'Genel';

    final isLive = !closed && (model.statu == Statu.statusLive);
    final countdownLong = getCountdownLong(model.endDate);
    final yesPct = total > 0 ? (percent * 100).round().clamp(0, 100) : 50;
    final noPct = 100 - yesPct;

    return InkWell(
      onTap: () {
        if (!kEnablePostDetail) {
          return;
        }
        Provider.of<FeedState>(context, listen: false)
            .getpostDetailFromDatabase(model.key ?? '', model: model);
        Navigator.of(context).pushNamed('/FeedPostDetail/${model.key}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zone 1 — Header: Avatar + username + RankBadge + category; right: single more_horiz
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<UserModel?>(
                  future: Provider.of<AuthState>(context, listen: false).getuserDetail(model.user?.userId ?? ''),
                  builder: (context, AsyncSnapshot<UserModel?> snapshot) {
                    final user = snapshot.data ?? model.user;
                    final handle = formatHandle(user?.userName, user?.displayName);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAvatar(context, user),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      handle,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                topicLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              ToldyaBottomSheet().toldyaOptionIcon(
                context,
                model: model,
                type: ToldyaType.Toldya,
                scaffoldKey: scaffoldKey,
              ),
            ],
          ),
          // Zone 2 — Body: prediction text prominent, bold, white
          if (model.description != null && (model.description ?? '').isNotEmpty) ...[
            SizedBox(height: 12),
            UrlText(
              text: model.description,
              onHashTagPressed: (_) {},
              style: GoogleFonts.sawarabiMincho(
                fontSize: 17,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              urlStyle: TextStyle(
                fontSize: 17,
                height: 1.35,
                color: AppNeon.cyan,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          // Zone 3 — Action: progress-style Evet/Hayır buttons
          SizedBox(height: 12),
          YesNoStakeButtonsRow(
            yesPercent: yesPct,
            noPercent: noPct,
            onYesTap: () => openToldyaStakeFlowWithFeedback(
              context: context,
              model: model,
              commentFlag: AppIcon.evetCommentFlag,
              type: ToldyaType.Toldya,
              scaffoldKey: scaffoldKey,
            ),
            onNoTap: () => openToldyaStakeFlowWithFeedback(
              context: context,
              model: model,
              commentFlag: AppIcon.hayirCommentFlag,
              type: ToldyaType.Toldya,
              scaffoldKey: scaffoldKey,
            ),
          ),
          // Zone 4 — Footer: pool left, live + countdown right (pulse when live)
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '💰 ${AppLocalizations.of(context)!.amountPlayed(k_m_b_generator(total) + ' token')}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              if (isLive && countdownLong.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.red)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .fadeIn(duration: 600.ms)
                        .fadeOut(duration: 600.ms),
                    SizedBox(width: 6),
                    Text(
                      '${AppLocalizations.of(context)!.liveLabel} • ${AppLocalizations.of(context)!.timeLeftLabel}: $countdownLong',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  model.statu == Statu.statusPendingAiReview
                      ? AppLocalizations.of(context)!.statuUnderReview
                      : AppLocalizations.of(context)!.predictionEnded,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusTag(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label == 'LIVE') Icon(Icons.circle, size: 5, color: color),
          if (label == 'LIVE') SizedBox(width: 4),
          if (label == 'TREND') Icon(Icons.thumb_up_alt_outlined, size: 10, color: color),
          if (label == 'TREND') SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, UserModel? user) {
    final userId = user?.userId ?? model.user?.userId ?? '';
    final profilePic = user?.profilePic ?? '';
    if (userId.isEmpty) return SizedBox(width: 34, height: 34);
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/ProfilePage/$userId'),
      child: Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppNeon.orange.withOpacity(0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppNeon.orange.withOpacity(0.2),
              blurRadius: 6,
            ),
          ],
        ),
        child: ClipOval(
          child: Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.all(1),
            child: customProfileImage(context, profilePic.isEmpty ? null : profilePic, userId: userId, height: 28),
          ),
        ),
      ),
    );
  }

  Widget _countdownChip(BuildContext context) {
    final text = getEndTime(model.endDate ?? '');
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
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(BuildContext context, IconData icon, Color color, VoidCallback onPressed) {
    return CupertinoButton(
      padding: EdgeInsets.all(4),
      minSize: 0,
      onPressed: onPressed,
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _voteButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool closed,
  }) {
    return AnimatedBounceButton(
      enabled: !closed,
      child: Material(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.4), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: color),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openToldyaStakeSheet(BuildContext context, AuthState authState, int commentFlag) {
    final closed = isToldyaStakeClosed(model.statu, model.endDate);
    if (closed || (authState.userModel?.pegCount ?? 0) == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          closed ? 'Kapandığı için seçim yapılamaz' : 'Token yetersiz',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black87,
      ));
      return;
    }
    if (userAlreadyStakedOtherSide(model, authState.userId, commentFlag)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          AppLocalizations.of(context)!.stakeOneSideOnly,
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 4),
        backgroundColor: Colors.orange.shade800,
      ));
      return;
    }
    ToldyaBottomSheet().openRetoldyabottomSheet(
      commentFlag,
      context,
      type: ToldyaType.Toldya,
      model: model,
      scaffoldKey: scaffoldKey,
    );
  }
}

