import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/topicMap.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/model/userPegModel.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';
import 'package:bendemistim/widgets/newWidget/customUrlText.dart';
import 'package:bendemistim/widgets/tweet/tweet.dart';
import 'package:bendemistim/widgets/tweet/widgets/tweetBottomSheet.dart';
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

  Widget _commentRow(FeedModel model) {
    return Toldya(
      model: model,
      type: ToldyaType.Reply,
      trailing: ToldyaBottomSheet().toldyaOptionIcon(context,
          scaffoldKey: scaffoldKey, model: model, type: ToldyaType.Reply),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    final model = (state.toldyaDetailModel?.length ?? 0) > 0 ? state.toldyaDetailModel!.last : null;

    return WillPopScope(
      onWillPop: () async {
        Provider.of<FeedState>(context, listen: false).removeLastToldyaDetail(postId);
        return true;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? MockupDesign.background : Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Tahmin Detayı',
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(MockupDesign.screenPadding, spacing24, MockupDesign.screenPadding, spacing8),
                      child: Text(
                        'Yorumlar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      state.toldyaReplyMap == null ||
                              state.toldyaReplyMap[postId] == null ||
                              (state.toldyaReplyMap[postId] ?? []).isEmpty
                          ? [
                              Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'Henüz yorum yok. İlk yorumu sen yap.',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          : (state.toldyaReplyMap[postId] ?? [])
                              .map<Widget>((x) => Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? AppColor.cardDarkBorder
                                              : Colors.black.withOpacity(0.06),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: _commentRow(x),
                                      ),
                                    ),
                                  ))
                              .toList(),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
        floatingActionButton: model != null
            ? FloatingActionButton(
                onPressed: () {
                  state.setToldyaToReply = model;
                  Navigator.of(context).pushNamed('/ComposeToldyaPage/toldya/$postId');
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
              )
            : null,
      ),
    );
  }
}

/// Tasarım önerilerine uygun: badge, soru, kullanıcı+countdown, Oracle chip’ler, bar+tooltip, bahis, son bahisler.
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
    final closed = isBettingClosed(model.statu, model.endDate);
    final evetColor = AppNeon.green;
    final hayirColor = AppNeon.red;
    final balance = authState.userModel?.pegCount ?? 0;
    final xp = authState.userModel?.xp ?? 0;
    final maxBet = [balance, Tokenomics.maxBetByRank(balance, xp), Tokenomics.maxBetByPool(total)].reduce((a, b) => a < b ? a : b);
    final topicLabel = topic.topicMap[model.topic ?? ''] ?? model.topic ?? 'Genel';
    final kapanisText = getEndTime(model.endDate ?? '');
    final userName = model.user?.userName ?? model.user?.displayName ?? '';
    final displayHandle = userName.isNotEmpty ? (userName.startsWith('@') ? userName : '@$userName') : '@kullanıcı';
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
          // 2. Kullanıcı & bilgi satırı: avatar, @kullaniciadi, kategori | Kapanış
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/ProfilePage/${model.userId}'),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.shade800,
                  child: ClipOval(
                    child: customProfileImage(context, model.user?.profilePic, userId: model.user?.userId, height: 44),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayHandle,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                kapanisText.isNotEmpty ? 'Kapanış: $kapanisText' : '',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                textAlign: TextAlign.end,
              ),
            ],
          ),
          SizedBox(height: 20),
          // 3. Oran çubuğu: üstte YES % / NO %, altta bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YES ${(percent * 100).round()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: evetColor,
                ),
              ),
              Text(
                'NO ${(percentNo * 100).round()}%',
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
            'Maksimum bahis: $maxBet token',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
          SizedBox(height: 16),
          // 4. Ana eylem butonları: Evet / Hayır, 56px, stadium, tam renk
          Row(
            children: [
              Expanded(
                child: Material(
                  color: evetColor,
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    onTap: () => _openBet(context, authState, 0),
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: Text(
                        'Evet ile bahis yap',
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
              SizedBox(width: 16),
              Expanded(
                child: Material(
                  color: hayirColor,
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    onTap: () => _openBet(context, authState, 1),
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: Text(
                        'Hayır ile bahis yap',
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
            ],
          ),
          SizedBox(height: 24),
          // 5. Son Bahisler başlığı
          Text(
            'Son Bahisler',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          SizedBox(height: 12),
          _RecentBetsList(
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

  void _openBet(BuildContext context, AuthState authState, int flag) {
    final closed = isBettingClosed(model.statu, model.endDate);
    if (closed || (authState.userModel?.pegCount ?? 0) == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            closed ? 'Kapandığı için seçim yapılamaz' : 'Token yetersiz',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.black87,
        ),
      );
      return;
    }
    final commentFlag = flag == 0 ? AppIcon.evetCommentFlag : AppIcon.hayirCommentFlag;
    if (userAlreadyBetOnOtherSide(model, authState.userId, commentFlag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Bu tahminde zaten diğer tarafa bahis yaptınız. Bir tahminde yalnızca tek tarafa (Evet veya Hayır) bahis yapabilirsiniz.',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 4),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }
    ToldyaBottomSheet().openRetoldyabottomSheet(
      commentFlag,
      context,
      type: ToldyaType.Detail,
      model: model,
      scaffoldKey: scaffoldKey,
    );
  }
}

class _RecentBetsList extends StatelessWidget {
  final List<UserPegModel> likeList;
  final List<UserPegModel> unlikeList;
  final VoidCallback? emptyCta;

  const _RecentBetsList({Key? key, required this.likeList, required this.unlikeList, this.emptyCta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final combined = <_BetEntry>[
      ...likeList.map((e) => _BetEntry(userId: e.userId, pegCount: e.pegCount, isYes: true)),
      ...unlikeList.map((e) => _BetEntry(userId: e.userId, pegCount: e.pegCount, isYes: false)),
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
              'Henüz bahis yok.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Yukarıdaki "Evet ile bahis yap" veya "Hayır ile bahis yap" butonuna tıklayarak bahis yapabilirsiniz.',
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
              final displayName = name.length > 1 ? name : 'Kullanıcı';
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

class _BetEntry {
  final String userId;
  final int pegCount;
  final bool isYes;
  _BetEntry({required this.userId, required this.pegCount, required this.isYes});
}
