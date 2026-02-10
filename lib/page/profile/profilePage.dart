import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/page/profile/widgets/tabPainter.dart';
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
    var authstate = Provider.of<AuthState>(context);
    return SliverAppBar(
      forceElevated: false,
      expandedHeight: 200,
      elevation: 0,
      stretch: true,
      iconTheme: IconThemeData(color: HexColor('#FFA400')),
      backgroundColor: Colors.transparent,
      actions: <Widget>[
        authstate.isbusy
            ? SizedBox.shrink()
            : PopupMenuButton<Choice>(
                onSelected: (d) {
                  if (d.title == "Paylaş") {
                    shareProfile(context);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                },
              ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: <StretchMode>[
          StretchMode.zoomBackground,
          StretchMode.blurBackground
        ],
        background: authstate.isbusy
            ? SizedBox.shrink()
            : Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  SizedBox.expand(
                    child: Container(
                      padding: EdgeInsets.only(top: 50),
                      height: 30,
                      color: Colors.white,
                    ),
                  ),
                  // Container(height: 50, color: Colors.black),

                  /// Banner image
                  Container(
                    height: 180,
                    padding: EdgeInsets.only(top: 28),
                    child: customNetworkImage(
                      authstate.profileUserModel?.bannerImage ?? 'https://firebasestorage.googleapis.com/v0/b/casy-570c4.appspot.com/o/ortak%2Fprofil%2Fbanner%2Forigami-936729_960_720.webp?alt=media&token=6e14e64a-8e3d-4060-94b9-61412eb2031d',
                      fit: BoxFit.fill,
                    ),
                  ),

                  /// UserModel avatar, message icon, profile edit and follow/following button
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 5),
                              shape: BoxShape.circle),
                          child: RippleButton(
                            child: customImage(
                              context,
                              authstate.profileUserModel?.profilePic ?? '',
                              height: 80,
                            ),
                            borderRadius: BorderRadius.circular(50),
                            onPressed: () {
                              Navigator.pushNamed(context, "/ProfileImageView");
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 90, right: 30),
                          child: Row(
                            children: <Widget>[
                              /*mesaj gönderme başlangıç*/
                              // isMyProfile
                              //     ? Container(height: 40)
                              //     : RippleButton(
                              //         splashColor: ToldyaColor.dodgetBlue_50
                              //             .withAlpha(100),
                              //         borderRadius: BorderRadius.all(
                              //           Radius.circular(20),
                              //         ),
                              //         onPressed: () {
                              //           if (!isMyProfile) {
                              //             final chatState =
                              //                 Provider.of<ChatState>(context,
                              //                     listen: false);
                              //             chatState.setChatUser =
                              //                 authstate.profileUserModel;
                              //             Navigator.pushNamed(
                              //                 context, '/ChatScreenPage');
                              //           }
                              //         },
                              //         child: Container(
                              //           height: 35,
                              //           width: 35,
                              //           padding: EdgeInsets.only(
                              //               bottom: 5,
                              //               top: 0,
                              //               right: 0,
                              //               left: 0),
                              //           decoration: BoxDecoration(
                              //               border: Border.all(
                              //                   color: isMyProfile
                              //                       ? Colors.black87
                              //                           .withAlpha(180)
                              //                       : Colors.blue,
                              //                   width: 1),
                              //               shape: BoxShape.circle),
                              //           child: Icon(
                              //             IconData(AppIcon.messageEmpty,
                              //                 fontFamily: 'TwitterIcon'),
                              //             color: Colors.blue,
                              //             size: 20,
                              //           ),
                              //
                              //           // customIcon(context, icon:AppIcon.messageEmpty, iconColor: ToldyaColor.dodgetBlue, paddingIcon: 8)
                              //         ),
                              //       ),
                              /*mesaj gönderme bitiş*/
                              SizedBox(width: 10),
                              RippleButton(
                                splashColor:
                                    ToldyaColor.dodgetBlue_50.withAlpha(100),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(60)),
                                onPressed: () {
                                  if (isBlackList()) {
                                    // authstate.addBlackList(authstate.profileUserModel.userId,removeBlackList: isBlackList());
                                  } else if (isMyProfile) {
                                    Navigator.pushNamed(
                                        context, '/EditProfile');
                                  } else {
                                    authstate.followUser(
                                      removeFollower: isFollower(),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isFollower()
                                        ? HexColor('#FFA400')
                                        : ToldyaColor.white,
                                    border: Border.all(
                                        color: HexColor('#FFA400'), width: 1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  /// If [isMyProfile] is true then Edit profile button will display
                                  // Otherwise Follow/Following button will be display
                                  child: Text(
                                    isMyProfile
                                        ? 'Profili Düzenle'
                                        : isBlackList()
                                            ? 'engellendin'
                                            : isFollower()
                                                ? 'Takip ediliyor'
                                                : 'Takip et',
                                    style: TextStyle(
                                      color: isMyProfile
                                          ? HexColor('#FFA400')
                                          : isFollower()
                                              ? ToldyaColor.white
                                              : HexColor('#FFA400'),
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/CreateFeedPage');
      },
      child: customIcon(
        context,
        icon: AppIcon.fabTweet,
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
        // floatingActionButton: !isMyProfile ? null : _floatingActionButton(),
        backgroundColor: ToldyaColor.mystic,
        body: NestedScrollView(
          // controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
            return <Widget>[
              getAppbar(),
              authstate.isbusy || isBlackList()
                  ? _emptyBox()
                  : SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        child: authstate.isbusy
                            ? SizedBox.shrink()
                            : authstate.profileUserModel != null
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      UserNameRowWidget(
                                        user: authstate.profileUserModel!,
                                        isMyProfile: isMyProfile,
                                      ),
                                      if (isMyProfile && authstate.canClaimDailyBonus)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.card_giftcard),
                                            label: Text(
                                                'Günlük bonusu al (+${AppIcon.dailyBonusAmount} token)'),
                                            onPressed: () async {
                                              final msg =
                                                  await authstate.claimDailyBonus();
                                              if (context.mounted) {
                                                if (msg != null) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          SnackBar(content: Text(msg)));
                                                }
                                                authstate.getProfileUser(
                                                    userProfileId: widget.profileId);
                                              }
                                            },
                                          ),
                                        ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                      ),
                    ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      color: ToldyaColor.white,
                      child: TabBar(
                        indicator: TabIndicator(),
                        controller: _tabController,
                        tabs: <Widget>[
                          Text("bahislerim"),
                          Text("oy verdiklerim"),
                          // Text("Media")
                        ],
                      ),
                    )
                  ],
                ),
              )
            ];
          },
          body: isBlackList()
              ? Container()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    /// Display all independent tweers list
                    _tweetList(context, authstate, list, false, false, id),

                    /// Display all reply tweet list
                    _tweetList(context, authstate, list, true, false, id),

                    // /// Display all reply and comments tweet list
                    // _tweetList(context, authstate, list, false, true)
                  ],
                ),
        ),
      ),
    );
  }

  Widget _tweetList(BuildContext context, AuthState authstate,
      List<FeedModel>? tweetsList, bool isreply, bool isMedia, String id) {
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
              (x.parentkey == null || x.childRetwetkey != null) &&
              x.userId == id)
          .toList();
    } else {
      /// Display all reply Tweets
      /// No intependent tweet will display
      ///
      // list = tweetsList
      //     .where((x) => x.parentkey != null && x.childRetwetkey == null)
      //     .toList();
      final profileUserId = authstate.profileUserModel?.userId;
      list = tweetsList
          .where((x) =>
              (x.likeList ?? []).any(
                  (id) => id.userId == profileUserId) ||
              (x.unlikeList ?? [])
                  .any((id) => id.userId == profileUserId))
          .toList();
    }

    /// if [authState.isbusy] is true then an loading indicator will be displayed on screen.
    return authstate.isbusy
        ? Container(
            height: fullHeight(context) - 180,
            child: CustomScreenLoader(
              height: double.infinity,
              width: fullWidth(context),
              backgroundColor: Colors.white,
            ),
          )

        /// if tweet list is empty or null then need to show user a message
        : list.isEmpty
            ? Container(
                padding: EdgeInsets.only(top: 20, left: 30, right: 30),
                child: NotifyText(
                  title: isMyProfile
                      ? 'Hiç ${isreply ? 'oy vermedin' : isMedia ? 'gönderi veya medya yok' : 'gönderi yok'}'
                      : '${authstate.profileUserModel?.userName ?? ''} hiç ${isreply ? 'oy vermedi' : isMedia ? 'gönderi veya medya yok' : 'gönderi yok'}',
                  subTitle:
                      isMyProfile ? 'Şimdi ekle' : 'burada gösterilecekler',
                ),
              )

            /// If tweets available then tweet list will displayed
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 0),
                itemCount: list.length,
                itemBuilder: (context, index) => Container(
                  color: ToldyaColor.white,
                  child: Toldya(
                    model: list[index],
                    isDisplayOnProfile: true,
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
            style: TextStyle(color: AppColor.darkGrey, fontSize: 17),
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
                  color: Colors.black,
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
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              customIcon(context,
                  icon: AppIcon.blueTick,
                  size: 24,
                  istwitterIcon: true,
                  paddingIcon: 5,
                  iconColor: ToldyaColor.dodgetBlue),
              SizedBox(width: 10),
              Expanded(
                child: customText(
                  user.pegCount.toString(),
                  style: TextStyle(color: AppColor.darkGrey),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: <Widget>[
              Icon(Icons.emoji_events, size: 20, color: HexColor('#FFA400')),
              SizedBox(width: 8),
              customText('Bahisçi: ', style: TextStyle(color: AppColor.darkGrey)),
              customText('${user.rank ?? 0}', style: TextStyle(fontWeight: FontWeight.bold, color: HexColor('#FFA400'))),
              SizedBox(width: 20),
              Icon(Icons.lightbulb_outline, size: 20, color: HexColor('#4CAF50')),
              SizedBox(width: 8),
              customText('Tahminci: ', style: TextStyle(color: AppColor.darkGrey)),
              customText('${user.predictorScore ?? 0}', style: TextStyle(fontWeight: FontWeight.bold, color: HexColor('#4CAF50'))),
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
                style: TextStyle(color: AppColor.darkGrey),
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
      color: Colors.white,
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
