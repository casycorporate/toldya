import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/topicMap.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';
import 'package:bendemistim/widgets/newWidget/customUrlText.dart';
import 'package:bendemistim/widgets/newWidget/emptyList.dart';
import 'package:bendemistim/widgets/newWidget/rippleButton.dart';
import 'package:bendemistim/widgets/tweet/tweet.dart';
import 'package:bendemistim/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

double _xpProgress(int xp) {
  if (xp < AppIcon.xpCaylakMax) return (xp / AppIcon.xpCaylakMax).clamp(0.0, 1.0);
  if (xp < AppIcon.xpUstaMin) return ((xp - AppIcon.xpCaylakMax) / (AppIcon.xpUstaMin - AppIcon.xpCaylakMax)).clamp(0.0, 1.0);
  return 1.0;
}

String _xpProgressLabel(int xp) {
  if (xp < AppIcon.xpCaylakMax) return '$xp / ${AppIcon.xpCaylakMax}';
  if (xp < AppIcon.xpUstaMin) return '$xp / ${AppIcon.xpUstaMin}';
  return '$xp (Usta)';
}

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key, this.profileId}) : super(key: key);

  final String? profileId;

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isMyProfile = false;
  int pageIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var authstate = Provider.of<AuthState>(context, listen: false);
      authstate.getProfileUser(userProfileId: widget.profileId);
      isMyProfile =
          widget.profileId == null || widget.profileId == authstate.userId;
    });
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  SliverAppBar getAppbar() {
    return SliverAppBar(
      forceElevated: false,
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings_outlined),
          onPressed: () => Navigator.pushNamed(context, '/SettingsAndPrivacyPage'),
        ),
      ],
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/CreateFeedPage');
      },
      child: customIcon(
        context,
        icon: AppIcon.fabToldya,
        istwitterIcon: true,
        iconColor: Theme.of(context).colorScheme.onPrimary,
        size: 25,
      ),
    );
  }

  Widget _emptyBox() {
    return SliverToBoxAdapter(child: SizedBox.shrink());
  }

  isFollower() {
    var authstate = Provider.of<AuthState>(context, listen: false);
    final followers = authstate.profileUserModel?.followersList;
    final myId = authstate.userModel?.userId;
    if (followers != null && followers.isNotEmpty && myId != null) {
      return followers.any((x) => x == myId);
    }
    return false;
  }

  isBlackList() {
    var authstate = Provider.of<AuthState>(context, listen: false);
    final blackList = authstate.profileUserModel?.blackList;
    final myId = authstate.userModel?.userId;
    if (blackList != null && blackList.isNotEmpty && myId != null) {
      return blackList.any((x) => x == myId);
    }
    return false;
  }

  /// This meathod called when user pressed back button
  /// When profile page is about to close
  /// Maintain minimum user's profile in profile page list
  Future<bool> _onWillPop() async {
    final state = Provider.of<AuthState>(context, listen: false);

    /// It will remove last user's profile from profileUserModelList
    state.removeLastUser();
    return true;
  }

  late TabController _tabController;
  /// 0=Aktif, 1=Bekleyen, 2=Tamamlanan, 3=Reddedilen (sadece kendi profilinde Bahislerim sekmesinde)
  int _bahislerimStatusFilter = 0;

  void shareProfile(BuildContext context) async {
    var authstate = context.read<AuthState>();
    var user = authstate.profileUserModel!;
    Utility.createLinkToShare(
      context,
      "profile/${user.userId ?? ''}",
      socialMetaTagParameters: SocialMetaTagParameters(
          description: user.bio ?? "Checkout ${user.displayName}'s profile",
          title: "${user.displayName ?? ''} is on witter app",
          imageUrl: Uri.parse(user.profilePic ?? '')),
    );
  }

  @override
  build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    var authstate = Provider.of<AuthState>(context);
    final feedlist = state.feedlist ?? <FeedModel>[];
    String id = widget.profileId ?? authstate.userId ?? '';
    final profileUserId = authstate.profileUserModel?.userId ?? '';

    /// Filter user's tweet among all tweets available in home page tweets list
    List<FeedModel> list = feedlist
        .where((x) =>
            x.userId == id ||
            (x.unlikeList ?? []).any((e) => e.userId == profileUserId) ||
            (x.likeList ?? []).any((e) => e.userId == profileUserId))
        .toList();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: MockupDesign.background,
        body: SafeArea(
          child: NestedScrollView(
          // controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
            return <Widget>[
              getAppbar(),
              authstate.isbusy || isBlackList()
                  ? _emptyBox()
                  : SliverToBoxAdapter(
                      child: authstate.isbusy || authstate.profileUserModel == null
                          ? SizedBox.shrink()
                          : _ProfileHeader(
                              user: authstate.profileUserModel!,
                              isMyProfile: isMyProfile,
                              canClaimDailyBonus: isMyProfile && authstate.canClaimDailyBonus,
                              onClaimDailyBonus: () async {
                                final msg = await authstate.claimDailyBonus();
                                if (context.mounted) {
                                  if (msg != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                  }
                                  authstate.getProfileUser(userProfileId: widget.profileId);
                                }
                              },
                              onEditOrFollow: () {
                                if (isBlackList()) return;
                                if (isMyProfile) {
                                  Navigator.pushNamed(context, '/EditProfile');
                                } else {
                                  authstate.followUser(removeFollower: isFollower());
                                }
                              },
                              isFollower: isFollower(),
                              isBlackList: isBlackList(),
                              onAvatarTap: () => Navigator.pushNamed(context, '/ProfileImageView'),
                              onTokenManagement: () => Navigator.of(context).pushNamed('/TokenEarnPage'),
                            ),
                    ),
              SliverToBoxAdapter(
                child: Container(
                  color: MockupDesign.background,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 3, color: AppNeon.green),
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey.shade600,
                    labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    unselectedLabelStyle: TextStyle(fontSize: 15),
                    tabs: <Widget>[
                      Tab(text: 'Bahislerim'),
                      Tab(text: 'Oy verdiklerim'),
                    ],
                  ),
                ),
              )
            ];
          },
          body: isBlackList()
              ? Container(color: MockupDesign.background)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    /// Display all independent tweers list (bahislerim); kendi profilinde filtre chip'leri
                    isMyProfile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _bahislerimFilterChips(context),
                              Expanded(
                                child: _tweetList(
                                  context,
                                  authstate,
                                  list,
                                  false,
                                  false,
                                  id,
                                  statusFilter: _bahislerimStatusFilter,
                                ),
                              ),
                            ],
                          )
                        : _tweetList(context, authstate, list, false, false, id),

                    /// Display all reply tweet list
                    _tweetList(context, authstate, list, true, false, id),

                    // /// Display all reply and comments tweet list
                    // _tweetList(context, authstate, list, false, true)
                  ],
                ),
          ),
        ),
      ),
    );
  }

  /// 1. Header: avatar, name, @handle, kompakt Profili Düzenle (saydam koyu gri, ince gri çerçeve)
  Widget _ProfileHeader({
    required UserModel user,
    required bool isMyProfile,
    required bool canClaimDailyBonus,
    required VoidCallback onClaimDailyBonus,
    required VoidCallback onEditOrFollow,
    required bool isFollower,
    required bool isBlackList,
    required VoidCallback onAvatarTap,
    required VoidCallback onTokenManagement,
  }) {
    return Builder(
      builder: (context) {
        final handle = user.userName ?? user.displayName ?? '';
        final displayHandle = handle.startsWith('@') ? handle : '@$handle';
        return Container(
          color: MockupDesign.background,
          padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey.shade800,
                  child: ClipOval(
                    child: customProfileImage(
                      context,
                      user.profilePic,
                      userId: user.userId,
                      height: 96,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14),
              Text(
                user.displayName ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                displayHandle.isEmpty ? '@kullanıcı' : displayHandle,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
              SizedBox(height: 14),
              Center(
                child: Material(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: onEditOrFollow,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade600, width: 1),
                      ),
                      child: Text(
                        isMyProfile
                            ? 'Profili Düzenle'
                            : isBlackList
                                ? 'engellendin'
                                : isFollower
                                    ? 'Takip ediliyor'
                                    : 'Takip et',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _WalletCapsule(
                user: user,
                isMyProfile: isMyProfile,
                canClaimDailyBonus: canClaimDailyBonus,
                onClaimDailyBonus: onClaimDailyBonus,
                onTokenManagement: onTokenManagement,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 2. Cüzdan kapsülü: Bakiye + Takipçi | Günlük bonus | Token Yönetimi, Divider(white10)
  Widget _WalletCapsule({
    required UserModel user,
    required bool isMyProfile,
    required bool canClaimDailyBonus,
    required VoidCallback onClaimDailyBonus,
    required VoidCallback onTokenManagement,
  }) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.monetization_on_rounded, size: 24, color: Color(0xFFFFD700)),
                    SizedBox(width: 10),
                    Text(
                      'Bakiye: ${user.pegCount ?? 0} Token',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${user.getFollower()} Takipçi',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
            if (isMyProfile && canClaimDailyBonus) ...[
              Divider(height: 24, color: Colors.white10),
              InkWell(
                onTap: onClaimDailyBonus,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.card_giftcard, size: 20, color: AppNeon.green),
                      SizedBox(width: 8),
                      Text(
                        'Günlük bonusu al (+${AppIcon.dailyBonusAmount} token)',
                        style: TextStyle(
                          color: AppNeon.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (isMyProfile) ...[
              Divider(height: 24, color: Colors.white10),
              InkWell(
                onTap: onTokenManagement,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings_ethernet, size: 18, color: Colors.grey.shade400),
                      SizedBox(width: 8),
                      Text(
                        'Token Yönetimi',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _profileBannerImage(BuildContext context,
      {required String? bannerImage, required String userId}) {
    final defaultAsset = DefaultBanners.assetForUser(userId);

    if (bannerImage == null || bannerImage.isEmpty) {
      return Image.asset(defaultAsset, fit: BoxFit.fill);
    }
    final assetPath = DefaultBanners.assetForKey(bannerImage);
    if (assetPath != null) {
      return Image.asset(assetPath, fit: BoxFit.fill);
    }
    return CachedNetworkImage(
      imageUrl: bannerImage,
      fit: BoxFit.fill,
      placeholder: (context, url) => Image.asset(defaultAsset, fit: BoxFit.fill),
      errorWidget: (context, url, error) =>
          Image.asset(defaultAsset, fit: BoxFit.fill),
    );
  }

  String _emptyListTitle({
    required bool isreply,
    required bool isMedia,
    int? statusFilter,
    required bool isMyProfile,
    required String profileUserName,
  }) {
    if (!isreply && statusFilter != null && isMyProfile) {
      switch (statusFilter) {
        case 0:
          return 'Aktif tahminin yok';
        case 1:
          return 'Bekleyen tahminin yok';
        case 2:
          return 'Tamamlanan tahminin yok';
        case 3:
          return 'Reddedilen tahminin yok';
        case 4:
          return 'Kilitli tahminin yok';
      }
    }
    if (isMyProfile) {
      return 'Hiç ${isreply ? 'oy vermedin' : isMedia ? 'gönderi veya medya yok' : 'gönderi yok'}';
    }
    return '$profileUserName hiç ${isreply ? 'oy vermedi' : isMedia ? 'gönderi veya medya yok' : 'gönderi yok'}';
  }

  /// 3. Filtre chip'leri: seçili = yeşil metin + hafif yeşil arka plan, diğerleri gri; altında kısa yeşil pill
  Widget _bahislerimFilterChips(BuildContext context) {
    const labels = ['Aktif', 'Bekleyen', 'Tamamlanan', 'Reddedilen', 'Kilitli'];
    return Container(
      color: MockupDesign.background,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(5, (index) {
            final selected = _bahislerimStatusFilter == index;
            return GestureDetector(
              onTap: () => setState(() => _bahislerimStatusFilter = index),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppNeon.green.withOpacity(0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: selected ? AppNeon.green : Colors.grey.shade500,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 6),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: selected ? 24 : 0,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppNeon.green,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _tweetList(BuildContext context, AuthState authstate,
      List<FeedModel>? tweetsList, bool isreply, bool isMedia, String id,
      {int? statusFilter}) {
    List<FeedModel> list;

    /// If user hasn't tweeted yet
    if (tweetsList == null) {
      list = [];
    } else if (isMedia) {
      /// Display all Tweets with media file

      list = tweetsList.where((x) => x.imagePath != null).toList();
    } else if (!isreply) {
      /// Display all independent Tweets
      /// No comments Tweet will display

      list = tweetsList
          .where((x) =>
              (x.parentkey == null || x.childRetoldyaKey != null) &&
              x.userId == id)
          .toList();

      /// Bahislerim sekmesinde statü filtresi (Aktif / Bekleyen / Tamamlanan / Reddedilen / Kilitli)
      if (statusFilter != null && list.isNotEmpty) {
        list = list.where((x) {
          final s = parseStatu(x.statu);
          if (s == null) return false;
          switch (statusFilter) {
            case 0: // Aktif: yayında, bahis alınabilir (statu 0, 2)
              return s == Statu.statusLive || s == Statu.statusOk;
            case 1: // Bekleyen: admin/AI incelemesi bekliyor (statu 1, 6)
              return s == Statu.statusPending || s == Statu.statusPendingAiReview;
            case 2: // Tamamlanan: onaylanmış / sonuçlanmış (statu 2, 4)
              return s == Statu.statusOk || s == Statu.statusComplete;
            case 3: // Reddedilen: admin/AI reddi (statu 3, 7)
              return s == Statu.statusDenied || s == Statu.statusRejectedByAi;
            case 4: // Kilitli: bahisler kapandı, sonuç bekleniyor (statu 5)
              return s == Statu.statusLocked;
            default:
              return false;
          }
        }).toList();
      }
    } else {
      /// Display all reply Tweets (oy verdiklerim - kullanıcının bahis yaptığı tahminler)
      /// Sadece ilgili statülerdeki gönderiler: Live, Ok, Locked, Complete
      final profileUserId = authstate.profileUserModel?.userId;
      list = tweetsList
          .where((x) {
            final hasVoted = (x.likeList ?? []).any(
                    (e) => e.userId == profileUserId) ||
                (x.unlikeList ?? []).any((e) => e.userId == profileUserId);
            if (!hasVoted) return false;
            final s = parseStatu(x.statu);
            if (s == null) return false;
            return s == Statu.statusLive || s == Statu.statusOk ||
                s == Statu.statusLocked || s == Statu.statusComplete;
          })
          .toList();
    }

    /// if [authState.isbusy] is true then an loading indicator will be displayed on screen.
    return authstate.isbusy
        ? Container(
            height: fullHeight(context) - 180,
            child: CustomScreenLoader(
              height: double.infinity,
              width: fullWidth(context),
              backgroundColor: MockupDesign.background,
            ),
          )

        /// if tweet list is empty or null then need to show user a message
        : list.isEmpty
            ? Container(
                padding: EdgeInsets.only(top: 20, left: 30, right: 30),
                color: MockupDesign.background,
                child: NotifyText(
                  title: _emptyListTitle(
                    isreply: isreply,
                    isMedia: isMedia,
                    statusFilter: statusFilter,
                    isMyProfile: isMyProfile,
                    profileUserName: authstate.profileUserModel?.userName ?? '',
                  ),
                  subTitle:
                      isMyProfile ? 'Şimdi ekle' : 'burada gösterilecekler',
                ),
              )

            /// 4. Tahmin kartları: #2C2C2E, 16px radius, çerçeve yok; ince Evet/Hayır butonları
            : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding, vertical: spacing8),
                itemCount: list.length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(bottom: spacing8),
                  child: _ProfilePredictionCard(
                    model: list[index],
                    scaffoldKey: scaffoldKey,
                    trailing: ToldyaBottomSheet().toldyaOptionIcon(
                      context,
                      model: list[index],
                      type: ToldyaType.Toldya,
                      scaffoldKey: scaffoldKey,
                    ),
                  ),
                ),
              );
  }
}

/// Profil tahmin kartı: koyu gri arka plan, çerçeve yok; oran barı altında ince Evet/Hayır (ok ikonlu)
class _ProfilePredictionCard extends StatelessWidget {
  final FeedModel model;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget trailing;

  const _ProfilePredictionCard({
    Key? key,
    required this.model,
    required this.scaffoldKey,
    required this.trailing,
  }) : super(key: key);

  void _onCardTap(BuildContext context) {
    Provider.of<FeedState>(context, listen: false).getpostDetailFromDatabase(model.key ?? '', model: model);
    Navigator.of(context).pushNamed('/FeedPostDetail/${model.key}');
  }

  void _onVoteTap(BuildContext context, int commentFlag) {
    final authState = Provider.of<AuthState>(context, listen: false);
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
      type: ToldyaType.Detail,
      model: model,
      scaffoldKey: scaffoldKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalYes = sumOfVote(model.likeList ?? []);
    final totalNo = sumOfVote(model.unlikeList ?? []);
    final total = totalYes + totalNo;
    final percent = total == 0 ? 0.5 : totalYes / total;
    final closed = isBettingClosed(model.statu, model.endDate);
    final topicLabel = topic.topicMap[model.topic ?? ''] ?? model.topic ?? 'Genel';
    const cardColor = Color(0xFF2C2C2E);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _onCardTap(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.description ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '@${model.user?.userName ?? model.user?.displayName ?? ''}',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                topicLabel,
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing,
                ],
              ),
              SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: AppNeon.red.withOpacity(0.4),
                  valueColor: AlwaysStoppedAnimation<Color>(AppNeon.green),
                  minHeight: 8,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      k_m_b_generator(totalYes),
                      style: TextStyle(color: AppNeon.green, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      k_m_b_generator(totalNo),
                      style: TextStyle(color: AppNeon.red, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: AppNeon.green.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _onVoteTap(context, AppIcon.evetCommentFlag),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.trending_up_rounded, size: 20, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Evet ${total > 0 ? (percent * 100).round() : 50}',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      color: AppNeon.red.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _onVoteTap(context, AppIcon.hayirCommentFlag),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.trending_down_rounded, size: 20, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Hayır ${total > 0 ? ((1 - percent) * 100).round() : 50}',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
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
}

class UserNameRowWidget extends StatelessWidget {
  const UserNameRowWidget({
    Key? key,
    required this.user,
    required this.isMyProfile,
  }) : super(key: key);

  final bool isMyProfile;
  final UserModel user;

  String getBio(String bio) {
    if (isMyProfile) {
      return bio;
    } else if (bio == "Biyografiyi güncellemek için profili düzenle") {
      return "Biyografi yok";
    } else {
      return bio;
    }
  }

  Widget _tappbleText(
      BuildContext context, String count, String text, String navigateTo) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/$navigateTo');
      },
      child: Row(
        children: <Widget>[
          customText(
            '$count ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          customText(
            '$text',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontSize: 17),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Row(
            children: <Widget>[
              UrlText(
                text: user.displayName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(
                width: 3,
              ),
              // user.isVerified
              //     ? customIcon(context,
              //         icon: AppIcon.blueTick,
              //         istwitterIcon: true,
              //         iconColor: AppColor.primary,
              //         size: 13,
              //         paddingIcon: 3)
              //     : SizedBox(width: 0),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 9),
          child: customText(
            '${user.userName}',
            style: subtitleStyle.copyWith(fontSize: 13),
          ),
        ),
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        //   child: customText(
        //     getBio(user.bio),
        //   ),
        // ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on, size: 24, color: Theme.of(context).primaryColor),
                SizedBox(width: 10),
                Text(
                  '${user.pegCount ?? 0}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  'Token',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isMyProfile && (user.xp != null)) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'XP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      _xpProgressLabel(user.xp ?? 0),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _xpProgress(user.xp ?? 0),
                    minHeight: 8,
                    backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: <Widget>[
              Icon(Icons.emoji_events, size: 20, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              customText('Bahisçi: ', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
              customText('${user.rank ?? 0}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              SizedBox(width: 20),
              Icon(Icons.lightbulb_outline, size: 20, color: AppNeon.green),
              SizedBox(width: 8),
              customText('Tahminci: ', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
              customText('${user.predictorScore ?? 0}', style: TextStyle(fontWeight: FontWeight.bold, color: AppNeon.green)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: <Widget>[
              ratingBar(user.rank ?? 0, 5, context, itemSize: 20.0),
              SizedBox(width: 10),
              customText(
                user.getLevel(),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 10,
                height: 30,
              ),
              _tappbleText(context, '${user.getFollower()}', ' Takipçiler',
                  'FollowerListPage'),
              SizedBox(width: 40),
              _tappbleText(context, '${user.getFollowing()}', ' takipler',
                  'FollowingListPage'),
            ],
          ),
        ),
      ],
    );
  }
}

class Choice {
  const Choice({required this.title, required this.icon});

  final IconData icon;
  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Paylaş', icon: Icons.directions_car),
  // const Choice(title: 'Draft', icon: Icons.directions_bike),
  // const Choice(title: 'View Lists', icon: Icons.directions_boat),
  // const Choice(title: 'View Moments', icon: Icons.directions_bus),
  // const Choice(title: 'QR code', icon: Icons.directions_railway),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key? key, required this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.headlineLarge;
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle?.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}
