import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toldya/widgets/animated_bounce_button.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/topicMap.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/model/userPegModel.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/customLoader.dart';
import 'package:toldya/widgets/newWidget/customUrlText.dart';
import 'package:toldya/widgets/toldya/widgets/toldya_bottom_sheet.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/toldya_stake_flow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FeedPostDetail extends StatefulWidget {
  FeedPostDetail({Key? key, this.postId}) : super(key: key);
  final String? postId;

  _FeedPostDetailState createState() => _FeedPostDetailState();
}

class _FeedPostDetailState extends State<FeedPostDetail> {
  late String postId;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    postId = widget.postId ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    final model = (state.toldyaDetailModel?.length ?? 0) > 0 ? state.toldyaDetailModel!.last : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Provider.of<FeedState>(context, listen: false).removeLastToldyaDetail(postId);
        if (Navigator.canPop(context)) Navigator.of(context).pop();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? MockupDesign.background : Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            color: Colors.white,
            onPressed: () {
              Provider.of<FeedState>(context, listen: false).removeLastToldyaDetail(postId);
              if (Navigator.canPop(context)) Navigator.of(context).pop();
            },
          ),
          title: Text(
            AppLocalizations.of(context)!.predictionDetail,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(Icons.share_outlined),
              color: Colors.white,
              onPressed: () async {
                await Utility.createLinkToShare(context, 'toldya/$postId');
              },
            ),
          ],
        ),
        body: model == null
            ? Center(
                child: CustomScreenLoader(
                  height: 80,
                  width: 80,
                  backgroundColor: Colors.transparent,
                ),
              )
            : CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
                      child: _PredictionDetailBody(model: model, scaffoldKey: scaffoldKey),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
    );
  }
}

/// Tasarım önerilerine uygun: badge, soru, kullanıcı+countdown, bar+tooltip, tahmin, son katılımlar.
class _PredictionDetailBody extends StatelessWidget {
  final FeedModel model;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _PredictionDetailBody({Key? key, required this.model, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context, listen: false);
    final totalYes = sumOfVote(model.likeList ?? []);
    final totalNo = sumOfVote(model.unlikeList ?? []);
    final total = totalYes + totalNo;
    final percent = total == 0 ? 0.5 : totalYes / total;
    final closed = isToldyaStakeClosed(model.statu, model.endDate);
    final evetColor = AppNeon.green;
    final hayirColor = AppNeon.red;
    final balance = authState.userModel?.pegCount ?? 0;
    final maxStakeAmount = (balance * 0.75).floor();
    final topicLabel = topic.topicMap[model.topic ?? ''] ?? model.topic ?? AppLocalizations.of(context)!.topicGeneral;
    final kapanisText = getEndTime(model.endDate ?? '');
    final authorUserId = model.userId ?? model.user?.userId ?? '';
    final percentNo = 1.0 - percent;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: spacing8),
          // 1. Soru metni – en üstte, sola hizalı, büyük ve okunaklı
          if (model.description != null && (model.description ?? '').isNotEmpty)
            UrlText(
              text: model.description,
              onHashTagPressed: (_) {},
              style: GoogleFonts.sawarabiMincho(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              urlStyle: TextStyle(fontSize: 23, color: AppNeon.cyan, fontWeight: FontWeight.w700),
            ),
          SizedBox(height: 16),
          // 2. Kullanıcı & bilgi satırı: güncel profil (getuserDetail) + formatHandle
          FutureBuilder<UserModel?>(
            future: authorUserId.isEmpty ? Future.value(null) : Provider.of<AuthState>(context, listen: false).getuserDetail(authorUserId),
            builder: (context, authorSnap) {
              final author = authorSnap.data ?? model.user;
              final displayHandle = formatHandle(author?.userName, author?.displayName);
              final handleToShow = displayHandle.isEmpty ? AppLocalizations.of(context)!.userHandlePlaceholder : displayHandle;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/ProfilePage/${model.userId}'),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey.shade800,
                      child: ClipOval(
                        child: customProfileImage(context, author?.profilePic, userId: author?.userId ?? model.userId, height: 44),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Text(
                                handleToShow,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (model.topic != null && (model.topic ?? '').isNotEmpty)
                          Text(
                            topicLabel,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    model.statu == Statu.statusPendingAdminReview
                        ? AppLocalizations.of(context)!.statuUnderReview
                        : (kapanisText.isNotEmpty
                            ? AppLocalizations.of(context)!.closingAt(kapanisText)
                            : ''),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    textAlign: TextAlign.end,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 20),
          // 3. Oran çubuğu: üstte YES % / NO %, altta bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppLocalizations.of(context)!.yes} ${(percent * 100).round()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: evetColor,
                ),
              ),
              Text(
                '${AppLocalizations.of(context)!.no} ${(percentNo * 100).round()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: hayirColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 14,
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: hayirColor,
                valueColor: AlwaysStoppedAnimation<Color>(evetColor),
                minHeight: 14,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.maxStakeTokens(maxStakeAmount.toString()),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
          SizedBox(height: 16),
          // 4. Ana eylem butonları: Evet / Hayır, 56px, stadium, tam renk (bounce + haptic)
          Row(
            children: [
              Expanded(
                child: AnimatedBounceButton(
                  enabled: !closed && (authState.userModel?.pegCount ?? 0) > 0,
                  child: Material(
                    color: evetColor,
                    borderRadius: BorderRadius.circular(28),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _openStakeSheet(context, authState, 0);
                      },
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context)!.toldyaYesLabel,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: AnimatedBounceButton(
                  enabled: !closed && (authState.userModel?.pegCount ?? 0) > 0,
                  child: Material(
                    color: hayirColor,
                    borderRadius: BorderRadius.circular(28),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _openStakeSheet(context, authState, 1);
                      },
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context)!.toldyaNoLabel,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          // 5. Son katılımlar başlığı
          Text(
            AppLocalizations.of(context)!.recentStakesTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          SizedBox(height: 12),
          _RecentStakesList(
            likeList: model.likeList ?? [],
            unlikeList: model.unlikeList ?? [],
            emptyCta: closed || balance == 0 ? null : () {
              ToldyaBottomSheet().openRetoldyabottomSheet(
                AppIcon.evetCommentFlag,
                context,
                type: ToldyaType.Detail,
                model: model,
                scaffoldKey: scaffoldKey,
              );
            },
          ),
        ],
      ),
    );
  }

  void _openStakeSheet(BuildContext context, AuthState authState, int flag) {
    final commentFlag = flag == 0 ? AppIcon.evetCommentFlag : AppIcon.hayirCommentFlag;
    openToldyaStakeFlowWithFeedback(
      context: context,
      model: model,
      commentFlag: commentFlag,
      type: ToldyaType.Detail,
      scaffoldKey: scaffoldKey,
    );
  }
}

class _RecentStakesList extends StatelessWidget {
  final List<UserPegModel> likeList;
  final List<UserPegModel> unlikeList;
  final VoidCallback? emptyCta;

  const _RecentStakesList({Key? key, required this.likeList, required this.unlikeList, this.emptyCta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final combined = <_StakeEntry>[
      ...likeList.map((e) => _StakeEntry(userId: e.userId, pegCount: e.pegCount, isYes: true)),
      ...unlikeList.map((e) => _StakeEntry(userId: e.userId, pegCount: e.pegCount, isYes: false)),
    ];
    combined.sort((a, b) => b.pegCount.compareTo(a.pegCount));
    final top = combined.take(10).toList();
    if (top.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? MockupDesign.card : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? MockupDesign.cardBorder : Colors.black.withOpacity(0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.noStakesYet,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.noStakesYetHint,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? MockupDesign.card : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColor.cardDarkBorder : Colors.black.withOpacity(0.06)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: top.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white10),
        itemBuilder: (context, i) {
          final e = top[i];
          return FutureBuilder(
            future: Provider.of<AuthState>(context, listen: false).getuserDetail(e.userId),
            builder: (context, AsyncSnapshot snapshot) {
              final user = snapshot.data;
              final name = user?.displayName ?? user?.userName ?? e.userId;
              final displayName = name.length > 1 ? name : AppLocalizations.of(context)!.user;
              final tokenColor = e.isYes ? AppNeon.green : AppNeon.red;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade800,
                      child: ClipOval(
                        child: customProfileImage(context, user?.profilePic, userId: user?.userId, height: 40),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${e.pegCount}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: tokenColor,
                          ),
                        ),
                        Text(
                          '—',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StakeEntry {
  final String userId;
  final int pegCount;
  final bool isYes;
  _StakeEntry({required this.userId, required this.pegCount, required this.isYes});
}
