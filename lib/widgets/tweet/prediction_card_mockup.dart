import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/topicMap.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customUrlText.dart';
import 'package:bendemistim/widgets/tweet/prediction_shared_ui.dart';
import 'package:bendemistim/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

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
    final authState = Provider.of<AuthState>(context, listen: false);
    final totalYes = sumOfVote(model.likeList ?? []);
    final totalNo = sumOfVote(model.unlikeList ?? []);
    final total = totalYes + totalNo;
    final percent = total == 0 ? 0.5 : totalYes / total;
    final closed = isBettingClosed(model.statu, model.endDate);
    final evetColor = (model.likeList ?? []).any((e) => e.userId == authState.userId)
        ? AppNeon.green
        : AppNeon.green.withOpacity(0.8);
    final hayirColor = (model.unlikeList ?? []).any((e) => e.userId == authState.userId)
        ? AppNeon.red
        : AppNeon.red.withOpacity(0.8);
    final topicLabel = topic.topicMap[model.topic ?? ''] ?? model.topic ?? 'Genel';

    final isLive = !isBettingClosed(model.statu, model.endDate) && (model.statu == Statu.statusLive);

    final isTrend = total >= 10 && isLive;
    final countdownLong = getCountdownLong(model.endDate);

    final yesPct = total > 0 ? (percent * 100).round().clamp(0, 100) : 50;
    final noPct = 100 - yesPct;

    return InkWell(
      onTap: () {
        Provider.of<FeedState>(context, listen: false)
            .getpostDetailFromDatabase(model.key ?? '', model: model);
        Navigator.of(context).pushNamed('/FeedPostDetail/${model.key}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Üst satır: sol avatar + @kullanici + kategori; sağ LIVE + Kalan + aksiyon ikonları
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatarSection(context),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '@${model.user?.userName ?? model.user?.displayName ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      topicLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLive || isTrend) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLive ? AppNeon.green.withOpacity(0.15) : AppNeon.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isLive ? AppNeon.green : AppNeon.orange,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLive ? 'LIVE' : 'TREND',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isLive ? AppNeon.green : AppNeon.orange,
                        ),
                      ),
                      if (countdownLong.isNotEmpty) ...[
                        SizedBox(height: 2),
                        Text(
                          'Kalan: $countdownLong',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 6),
              ],
              _iconBtn(
                context,
                (model.favList ?? []).any((id) => id == authState.userId)
                    ? Icons.star
                    : Icons.star_border,
                Theme.of(context).primaryColor,
                () {
                  Provider.of<FeedState>(context, listen: false)
                      .addFavToToldya(model, authState.userId);
                },
              ),
              _iconBtn(context, Icons.share_outlined, Colors.grey, () async {
                await Utility.createLinkToShare(
                  context,
                  'toldya/${model.key}',
                  socialMetaTagParameters: SocialMetaTagParameters(
                    description: model.description ?? 'Tahmin paylaşıldı.',
                    title: 'Toldya',
                  ),
                );
              }),
              ToldyaBottomSheet().toldyaOptionIcon(
                context,
                model: model,
                type: ToldyaType.Toldya,
                scaffoldKey: scaffoldKey,
              ),
            ],
          ),
          // Tahmin başlığı
          if (model.description != null && (model.description ?? '').isNotEmpty) ...[
            SizedBox(height: 12),
            UrlText(
              text: model.description,
              onHashTagPressed: (_) {},
              style: GoogleFonts.sawarabiMincho(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              urlStyle: TextStyle(
                fontSize: 17,
                color: AppNeon.cyan,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          // Oran çubuğu + altında % YES / % NO
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  flex: yesPct.clamp(1, 99),
                  child: Container(height: 10, color: evetColor),
                ),
                Expanded(
                  flex: noPct.clamp(1, 99),
                  child: Container(height: 10, color: hayirColor),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '%$yesPct YES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: evetColor,
                ),
              ),
              Text(
                '%$noPct NO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: hayirColor,
                ),
              ),
            ],
          ),
          // Alt satır: Token Bahis (sol) + BAHİS YAP (sağ)
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${k_m_b_generator(total)} Token Bahis',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: closed
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              'Kapandığı için seçim yapılamaz',
                              style: TextStyle(color: Colors.white),
                            ),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.black87,
                          ));
                        }
                      : () {
                          Provider.of<FeedState>(context, listen: false)
                              .getpostDetailFromDatabase(model.key ?? '', model: model);
                          Navigator.of(context).pushNamed('/FeedPostDetail/${model.key}');
                        },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 36,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: closed ? Colors.grey[700] : const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      closed ? 'Bitti' : 'BAHİS YAP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
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

  Widget _avatarSection(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthState>(context, listen: false).getuserDetail(model.user?.userId ?? ''),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return SizedBox(width: 34, height: 34);
        }
        final user = snapshot.data as dynamic;
        final userId = user?.userId ?? model.user?.userId ?? '';
        final profilePic = user?.profilePic ?? '';
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
      },
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
    return Material(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
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
    );
  }

  void _openBetSheet(BuildContext context, AuthState authState, int commentFlag) {
    final closed = isBettingClosed(model.statu, model.endDate);
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
    if (userAlreadyBetOnOtherSide(model, authState.userId, commentFlag)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Bu tahminde zaten diğer tarafa bahis yaptınız. Bir tahminde yalnızca tek tarafa (Evet veya Hayır) bahis yapabilirsiniz.',
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

