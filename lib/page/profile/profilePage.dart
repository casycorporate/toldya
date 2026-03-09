import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/topicMap.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/state/appState.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/customLoader.dart';
import 'package:toldya/widgets/newWidget/custom_shimmer.dart';
import 'package:toldya/widgets/newWidget/customUrlText.dart';
import 'package:toldya/widgets/newWidget/emptyList.dart';
import 'package:toldya/widgets/newWidget/rippleButton.dart';
import 'package:toldya/widgets/tweet/tweet.dart';
import 'package:toldya/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:toldya/widgets/rank/rankBadgeWidget.dart';
import 'package:toldya/widgets/rank/xpProgressBarWidget.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key, this.profileId, this.isTabContent = false, this.parentScaffoldKey})
      : super(key: key);

  final String? profileId;
  /// True when shown as HomePage bottom bar tab (index 3). Back must not pop; use drawer or no-op.
  final bool isTabContent;
  /// When [isTabContent] is true, leading can open this scaffold's drawer (e.g. HomePage).
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isMyProfile = false;
  int pageIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFollowingAction = false;

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
      leading: widget.isTabContent
          ? IconButton(
              icon: Icon(Icons.arrow_back_rounded),
              onPressed: () {
                debugPrint('[Profile] back (tab) pressed profileId=${widget.profileId} isTabContent=${widget.isTabContent} canPop=${Navigator.of(context).canPop()}');
                final appState = Provider.of<AppState>(context, listen: false);
                appState.setpageIndex = appState.lastTabBeforeProfile;
              },
            )
          : IconButton(
              icon: Icon(Icons.arrow_back_rounded),
              onPressed: () {
                debugPrint('[Profile] back pressed profileId=${widget.profileId} isTabContent=${widget.isTabContent} canPop=${Navigator.of(context).canPop()}');
                final routeName = ModalRoute.of(context)?.settings.name;
                debugPrint('[Profile] about to pop, currentRoute=$routeName');
                Provider.of<AuthState>(context, listen: false).profilePageClosing(widget.profileId);
                if (Navigator.canPop(context)) Navigator.of(context).pop();
              },
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

  /// Cleanup when leaving profile: run profilePageClosing then pop. AppBar leading and PopScope (system back) both use this (same cleanup, then pop).
  /// When [isTabContent] is true, do not pop; switch to last tab (Feed/Search/Notifications) instead.
  void _onPopInvoked(bool didPop, dynamic result) {
    if (didPop) return;
    if (widget.isTabContent) {
      debugPrint('[Profile] system back (tab) isTabContent=${widget.isTabContent} canPop=${Navigator.of(context).canPop()}');
      final appState = Provider.of<AppState>(context, listen: false);
      appState.setpageIndex = appState.lastTabBeforeProfile;
      return;
    }
    Provider.of<AuthState>(context, listen: false).profilePageClosing(widget.profileId);
    if (Navigator.canPop(context)) Navigator.of(context).pop();
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
          description: user.bio ?? AppLocalizations.of(context)!.profileShareDescription(user.displayName ?? ''),
          title: AppLocalizations.of(context)!.profileShareTitle(user.displayName ?? ''),
          imageUrl: Uri.parse(user.profilePic ?? '')),
    );
  }

  @override
  build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    var authstate = Provider.of<AuthState>(context);
    if (widget.profileId == null && authstate.profileUserModel?.userId != authstate.userId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Provider.of<AuthState>(context, listen: false).ensureProfileIsCurrentUser();
        }
      });
    }
    final feedlist = state.feedlist ?? <FeedModel>[];
    String id = widget.profileId ?? authstate.userId ?? '';
    final profileUserId = authstate.profileUserModel?.userId ?? '';

    final profileMatchesPage = authstate.profileUserModel == null
        ? false
        : (widget.profileId == null ||
            authstate.profileUserModel!.userId == widget.profileId);
    final showHeader = !authstate.isbusy &&
        !isBlackList() &&
        authstate.profileUserModel != null &&
        profileMatchesPage;
    debugPrint('[ProfilePage] build profileId=${widget.profileId} profileUserModel=${authstate.profileUserModel != null} isbusy=${authstate.isbusy} showHeader=$showHeader');

    if (id.isNotEmpty && profileMatchesPage && state.profileUserToldyaUserId != id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Provider.of<FeedState>(context, listen: false).loadToldyaListForUser(id);
        }
      });
    }

    /// Bahislerim: use dedicated profile user list from Firebase when available; else fallback to feedlist filtered by userId
    final listForBahislerim = (state.profileUserToldyaUserId == id && state.profileUserToldyaList != null)
        ? state.profileUserToldyaList!
        : feedlist
            .where((x) =>
                (x.parentkey == null || x.childRetoldyaKey != null) &&
                x.userId == id)
            .toList();
    /// Oy verdiklerim: from feedlist where user has voted
    final listForOyVerdiklerim = feedlist
        .where((x) =>
            (x.unlikeList ?? []).any((e) => e.userId == profileUserId) ||
            (x.likeList ?? []).any((e) => e.userId == profileUserId))
        .toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: MockupDesign.background,
        body: SafeArea(
          child: NestedScrollView(
          // controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
            final profileMatchesPage = authstate.profileUserModel == null
                ? false
                : (widget.profileId == null ||
                    authstate.profileUserModel!.userId == widget.profileId);
            final hasProfile = authstate.profileUserModel != null && profileMatchesPage;
            final showHeader = !isBlackList() && hasProfile;
            final waitingForProfile =
                widget.profileId != null && !profileMatchesPage;
            final ownProfileWaiting = widget.profileId == null &&
                authstate.profileUserModel == null;
            final showProfileShimmer = (waitingForProfile || ownProfileWaiting) &&
                authstate.profileError == null;
            final showProfileError = (waitingForProfile || ownProfileWaiting) &&
                authstate.profileError != null;
            final l10n = AppLocalizations.of(context)!;
            return <Widget>[
              getAppbar(),
              if (authstate.isbusy && showHeader)
                SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    backgroundColor: MockupDesign.background,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                ),
              authstate.isbusy && isBlackList()
                  ? _emptyBox()
                  : SliverToBoxAdapter(
                      child: !showHeader
                          ? showProfileError
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        l10n.errorTryAgain,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                      ),
                                      SizedBox(height: 16),
                                      TextButton.icon(
                                        onPressed: () {
                                          authstate.clearProfileError();
                                          authstate.getProfileUser(userProfileId: widget.profileId);
                                        },
                                        icon: Icon(Icons.refresh),
                                        label: Text(l10n.retry),
                                      ),
                                    ],
                                  ),
                                )
                              : showProfileShimmer
                                  ? ProfileShimmer()
                                  : SizedBox.shrink()
                          : _ProfileHeader(
                              user: authstate.profileUserModel!,
                              isMyProfile: isMyProfile,
                              canClaimDailyBonus: isMyProfile && authstate.canClaimDailyBonus,
                              onClaimDailyBonus: () async {
                                final msg = await authstate.claimDailyBonus(context);
                                if (context.mounted) {
                                  if (msg != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                  }
                                  authstate.getProfileUser(userProfileId: widget.profileId);
                                }
                              },
                              onEditOrFollow: () async {
                                if (isBlackList()) return;
                                if (isMyProfile) {
                                  Navigator.pushNamed(context, '/EditProfile');
                                  return;
                                }
                                setState(() => _isFollowingAction = true);
                                try {
                                  authstate.followUser(removeFollower: isFollower());
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isFollower() ? AppLocalizations.of(context)!.unfollowSuccess : AppLocalizations.of(context)!.followSuccess,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (_) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context)!.errorGeneric),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => _isFollowingAction = false);
                                }
                              },
                              isFollowLoading: _isFollowingAction,
                              isFollower: isFollower(),
                              isBlackList: isBlackList(),
                              onAvatarTap: () => Navigator.pushNamed(context, '/ProfileImageView'),
                              onTokenManagement: () => Navigator.of(context).pushNamed('/TokenEarnPage'),
                            ),
                    ),
              SliverToBoxAdapter(
                child: Container(
                  color: MockupDesign.background,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                      Tab(text: AppLocalizations.of(context)!.myBetsTab),
                      Tab(text: AppLocalizations.of(context)!.myVotesTab),
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
                                  listForBahislerim,
                                  false,
                                  false,
                                  id,
                                  statusFilter: _bahislerimStatusFilter,
                                ),
                              ),
                            ],
                          )
                        : _tweetList(context, authstate, listForBahislerim, false, false, id),

                    /// Display all reply tweet list (oy verdiklerim)
                    _tweetList(context, authstate, listForOyVerdiklerim, true, false, id),

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
    bool isFollowLoading = false,
    required bool isFollower,
    required bool isBlackList,
    required VoidCallback onAvatarTap,
    required VoidCallback onTokenManagement,
  }) {
    return Builder(
      builder: (context) {
        final handle = user.userName ?? user.displayName ?? '';
        final displayHandle = handle.startsWith('@') ? handle : '@$handle';
        final xp = user.xp ?? 0;
        final hasXp = user.xp != null;
        return Container(
          color: MockupDesign.background,
          padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.grey.shade800,
                  child: ClipOval(
                    child: customProfileImage(
                      context,
                      user.profilePic,
                      userId: user.userId,
                      height: 88,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      user.displayName ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if ((user.currentStreak ?? 0) >= 3) ...[
                    SizedBox(width: 6),
                    Icon(Icons.local_fire_department, size: 22, color: Colors.orange),
                  ],
                  if (hasXp) ...[
                    SizedBox(width: 8),
                    RankBadgeWidget(
                      xp: xp,
                      compact: false,
                    ),
                  ],
                ],
              ),
              SizedBox(height: 2),
              Text(
                displayHandle.isEmpty ? AppLocalizations.of(context)!.defaultUserHandle : displayHandle,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
              SizedBox(height: 10),
              Center(
                child: Material(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: isFollowLoading ? null : onEditOrFollow,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade600, width: 1),
                      ),
                      child: isFollowLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                        isMyProfile
                            ? AppLocalizations.of(context)!.editProfile
                            : isBlackList
                                ? AppLocalizations.of(context)!.youAreBlocked
                                : isFollower
                                    ? AppLocalizations.of(context)!.followingLabel
                                    : AppLocalizations.of(context)!.follow,
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
              SizedBox(height: 14),
              _WalletCapsule(
                user: user,
                isMyProfile: isMyProfile,
                canClaimDailyBonus: canClaimDailyBonus,
                onClaimDailyBonus: onClaimDailyBonus,
                onTokenManagement: onTokenManagement,
              ),
              _ProfileStatsSection(context, user: user, isMyProfile: isMyProfile),
            ],
          ),
        );
      },
    );
  }

  /// Rütbe ilerlemesi, Bahisçi/Tahminci kartları, Seviye ve Liderlik CTA (profil ağacında görünsün diye burada)
  Widget _ProfileStatsSection(BuildContext context, {required UserModel user, required bool isMyProfile}) {
    final theme = Theme.of(context);
    final xp = user.xp ?? 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 14, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMyProfile && user.xp != null) ...[
            Text(
              AppLocalizations.of(context)!.rankProgressTitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 4),
            XpProgressBarWidget(xp: xp),
            SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: _profileStatCard(
                  context: context,
                  icon: Icons.emoji_events,
                  iconColor: theme.primaryColor,
                  title: AppLocalizations.of(context)!.bettors,
                  value: user.rank ?? 0,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _profileStatCard(
                  context: context,
                  icon: Icons.lightbulb_outline,
                  iconColor: AppNeon.green,
                  title: AppLocalizations.of(context)!.rankPredictor,
                  value: user.predictorScore ?? 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              RankBadgeWidget(xp: user.xp ?? 0, compact: true),
              SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.levelLabel(user.getLevel().trim()),
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (isMyProfile) ...[
            SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/LeaderboardPage'),
                icon: Icon(Icons.leaderboard_outlined, size: 18, color: AppNeon.green),
                label: Text(
                  AppLocalizations.of(context)!.seeLeaderboard,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppNeon.green),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  foregroundColor: AppNeon.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _profileStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required int value,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
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
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                    Icon(Icons.monetization_on_rounded, size: 22, color: Color(0xFFFFD700)),
                    SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.balanceToken(user.pegCount ?? 0),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${user.getFollower()} ${AppLocalizations.of(context)!.follower}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
            if (isMyProfile && canClaimDailyBonus) ...[
              Divider(height: 18, color: Colors.white10),
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
                        AppLocalizations.of(context)!.dailyBonusClaim(AppIcon.dailyBonusAmount),
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
              Divider(height: 18, color: Colors.white10),
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
                        AppLocalizations.of(context)!.tokenManagement,
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
    final l10n = AppLocalizations.of(context)!;
    if (!isreply && statusFilter != null && isMyProfile) {
      switch (statusFilter) {
        case 0:
          return l10n.emptyActivePredictions;
        case 1:
          return l10n.emptyPendingPredictions;
        case 2:
          return l10n.emptyCompletedPredictions;
        case 3:
          return l10n.emptyRejectedPredictions;
        case 4:
          return l10n.emptyLockedPredictions;
      }
    }
    if (isMyProfile) {
      return isreply ? l10n.emptyMyNoVotes : (isMedia ? l10n.emptyMyNoMedia : l10n.emptyMyNoPosts);
    }
    return isreply ? l10n.emptyOtherNoVotes(profileUserName) : (isMedia ? l10n.emptyOtherNoMedia(profileUserName) : l10n.emptyOtherNoPosts(profileUserName));
  }

  /// 3. Filtre chip'leri: seçili = yeşil metin + hafif yeşil arka plan, diğerleri gri; altında kısa yeşil pill
  Widget _bahislerimFilterChips(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [l10n.filterActive, l10n.filterPending, l10n.filterCompleted, l10n.filterRejected, l10n.filterLocked];
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
            case 0: // Aktif: yayında veya kilitli, bahis açık (sadece Live ve Locked; bitmiş/Tamamlanan hariç)
              return s == Statu.statusLive || s == Statu.statusLocked;
            case 1: // Bekleyen: admin/AI incelemesi bekliyor (statu 1, 6)
              return s == Statu.statusPending || s == Statu.statusPendingAiReview;
            case 2: // Tamamlanan: onaylanmış / sonuçlanmış (statu 2, 4) — "bitmiş" burada
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

    /// When loading: show list with top indicator if we have data, else shimmer placeholders.
    if (authstate.isbusy && list.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            backgroundColor: MockupDesign.background,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          Expanded(
            child: ListView.builder(
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
            ),
          ),
        ],
      );
    }
    if (authstate.isbusy && list.isEmpty) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding, vertical: spacing8),
          child: FeedShimmer(itemCount: 3),
        ),
      );
    }

    /// if tweet list is empty or null then need to show user a message
    final bottomPadding = 24.0 + MediaQuery.of(context).padding.bottom;
    return list.isEmpty
            ? SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: bottomPadding),
                  color: MockupDesign.background,
                  constraints: BoxConstraints(
                    minHeight: 200,
                  ),
                  child: NotifyText(
                    title: _emptyListTitle(
                      isreply: isreply,
                      isMedia: isMedia,
                      statusFilter: statusFilter,
                      isMyProfile: isMyProfile,
                      profileUserName: authstate.profileUserModel?.userName ?? '',
                    ),
                    subTitle:
                        isMyProfile ? AppLocalizations.of(context)!.addNow : AppLocalizations.of(context)!.willShowHere,
                  ),
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
          closed ? AppLocalizations.of(context)!.closedNoSelection : AppLocalizations.of(context)!.tokenInsufficient,
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
          AppLocalizations.of(context)!.betOnOneSideOnly,
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
    final topicLabel = topic.topicMap[model.topic ?? ''] ?? model.topic ?? AppLocalizations.of(context)!.topicGeneral;
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
                              formatHandle(model.user?.userName, model.user?.displayName),
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
                                AppLocalizations.of(context)!.yesPercent(total > 0 ? (percent * 100).round() : 50),
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
                                AppLocalizations.of(context)!.noPercent(total > 0 ? ((1 - percent) * 100).round() : 50),
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

  String getBio(BuildContext context, String bio) {
    if (isMyProfile) {
      return bio;
    } else if (bio == AppLocalizations.of(context)!.editBioHint) {
      return AppLocalizations.of(context)!.noBio;
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

  Widget _statCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required int value,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xp = user.xp ?? 0;
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
              if ((user.currentStreak ?? 0) >= 3) ...[
                SizedBox(width: 4),
                Icon(Icons.local_fire_department, size: 18, color: Colors.orange),
              ],
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
                  AppLocalizations.of(context)!.tokenLabel,
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
                Text(
                  AppLocalizations.of(context)!.rankProgressTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 4),
                XpProgressBarWidget(xp: xp),
              ],
            ),
          ),
        ],
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _statCard(
                  context: context,
                  icon: Icons.emoji_events,
                  iconColor: Theme.of(context).primaryColor,
                  title: AppLocalizations.of(context)!.bettors,
                  value: user.rank ?? 0,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  context: context,
                  icon: Icons.lightbulb_outline,
                  iconColor: AppNeon.green,
                  title: AppLocalizations.of(context)!.rankPredictor,
                  value: user.predictorScore ?? 0,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: <Widget>[
              RankBadgeWidget(xp: user.xp ?? 0, compact: true),
              SizedBox(width: 10),
              customText(
                AppLocalizations.of(context)!.levelLabel(user.getLevel().trim()),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (isMyProfile)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/LeaderboardPage'),
                icon: Icon(
                  Icons.leaderboard_outlined,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
                label: Text(
                  AppLocalizations.of(context)!.seeLeaderboard,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  foregroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
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
              _tappbleText(context, '${user.getFollower()}', ' ${AppLocalizations.of(context)!.followers}',
                  'FollowerListPage'),
              SizedBox(width: 40),
              _tappbleText(context, '${user.getFollowing()}', ' ${AppLocalizations.of(context)!.followingCountLabel}',
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

List<Choice> _shareChoices(BuildContext context) => [
  Choice(title: AppLocalizations.of(context)!.share, icon: Icons.directions_car),
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
