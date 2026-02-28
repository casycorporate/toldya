import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/helper/topicMap.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/state/searchState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';
import 'package:bendemistim/widgets/newWidget/emptyList.dart';
import 'package:bendemistim/widgets/newWidget/empty_state_screen.dart';
import 'package:bendemistim/widgets/tweet/prediction_card_mockup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;

  const FeedPage({Key? key, this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FeedPage();
}

class _FeedPage extends State<FeedPage> {
  late TextEditingController textController;
  int statu = Statu.statusLive;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/CreateFeedPage/toldya');
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

  // Widget _getUserAvatar(BuildContext context) {
  //   var authState = Provider.of<AuthState>(context);
  //   return Padding(
  //     padding: EdgeInsets.all(10),
  //     child: customInkWell(
  //       context: context,
  //       onPressed: () {
  //         /// Open up sidebaar drawer on user avatar tap
  //         widget.scaffoldKey.currentState.openDrawer();
  //       },
  //       child:
  //           customImage(context, authState.userModel?.profilePic, height: 30),
  //     ),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     floatingActionButton: _floatingActionButton(context),
  //     backgroundColor: ToldyaColor.mystic,
  //     body: SafeArea(
  //       child: Container(
  //         height: fullHeight(context),
  //         width: fullWidth(context),
  //         child: _FeedPageBody(
  //           refreshIndicatorKey: refreshIndicatorKey,
  //           scaffoldKey: scaffoldKey,
  //         ),
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    var authstate = Provider.of<AuthState>(context, listen: false);
    var searchState = Provider.of<SearchState>(context, listen: false);
    return Consumer<FeedState>(builder: (context, feedState, _) {
      final mainList = feedState.getToldyaListByTopic(
        authstate.userModel,
        searchState.getUserInBlackList(authstate.userModel),
        textController.text,
        statu,
        topic_val: topic.gundem,
      );
      // Boş ekranı sadece veri yüklendikten sonra ve gerçekten tahmin yoksa göster
      final showEmptyState = !feedState.isBusy &&
          feedState.feedlist != null &&
          mainList.isEmpty;
      if (showEmptyState) {
        return EmptyStateScreen(
          onMenuPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
          onHistoryPressed: () {
            setState(() {
              statu = statu == Statu.statusLive ? Statu.statusOk : Statu.statusLive;
            });
          },
          onFabPressed: () => Navigator.of(context).pushNamed('/CreateFeedPage/toldya'),
          onHomePressed: () {},
          onSearchPressed: () => Navigator.of(context).pushNamed('/SearchPage'),
          onNotificationsPressed: () => Navigator.of(context).pushNamed('/NotificationPage'),
          onProfilePressed: () => Navigator.of(context).pushNamed(
            '/ProfilePage/${authstate.userModel?.userId ?? ''}',
          ),
        );
      }
      final List<String> _tabs = topic.topicMap.values.toList();
      List<FeedModel> list = [];
      _tabs.insert(0, topic.gundem);
      _tabs.insert(1, topic.favList);
      _tabs.insert(2, topic.followList);
      return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu_rounded),
            color: Colors.white,
            onPressed: () {
              widget.scaffoldKey?.currentState?.openDrawer();
            },
          ),
          title: Container(
            height: 38,
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: textController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Ara...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: Colors.white.withOpacity(0.6),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
            ),
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? MockupDesign.background
              : Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          actions: [
            if (authstate.isbusy || authstate.userModel == null)
              SizedBox.shrink()
            else ...[
              // Token cüzdanı (kapsül) — sağ kenardan 16px
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on_rounded,
                          size: 18,
                          color: Color(0xFFFFD700),
                        ),
                        SizedBox(width: 6),
                        Text(
                          k_m_b_generator(authstate.userModel?.pegCount ?? 0),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (authstate.userModel?.role == Role.adminRole)
                PopupMenuButton<Choice>(
                  onSelected: (d) {
                    if (d.title == "bekleyen") {
                      statu = Statu.statusPending;
                    } else if (d.title == "onaylanan") {
                      statu = Statu.statusOk;
                    } else if (d.title == "reddedilen") {
                      statu = Statu.statusDenied;
                    } else if (d.title == "tamamlanan") {
                      statu = Statu.statusComplete;
                    } else if (d.title == "AI incelemesinde") {
                      statu = Statu.statusPendingAiReview;
                    } else if (d.title == "AI reddi") {
                      statu = Statu.statusRejectedByAi;
                    } else {
                      statu = Statu.statusLive;
                    }
                    setState(() {});
                  },
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (BuildContext context) {
                    return choices.map((Choice choice) {
                      return PopupMenuItem<Choice>(
                        value: choice,
                        child: Text(choice.title),
                      );
                    }).toList();
                  },
                )
              else
                IconButton(
                  onPressed: () {
                    setState(() {
                      statu == Statu.statusLive
                          ? statu = Statu.statusOk
                          : statu = Statu.statusLive;
                    });
                  },
                  icon: Icon(
                    Icons.history,
                    color: statu == Statu.statusLive
                        ? Colors.white70
                        : AppColor.primary,
                  ),
                ),
            ],
          ],
          bottom: PreferredSize(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                indicatorColor: AppNeon.green,
                indicatorWeight: 3,
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.white,
                unselectedLabelStyle: GoogleFonts.sawarabiMincho(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                labelStyle: GoogleFonts.sawarabiMincho(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
                isScrollable: true,
                labelPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                tabs: _tabs.map((String name) => Tab(text: name)).toList(),
              ),
            ),
            preferredSize: Size.fromHeight(48.0),
          ),
        ),
        body: TabBarView(
          children: _tabs.map((String name) {
            return Consumer<FeedState>(builder: (context, state, child) {
              final topicVal = (name == topic.gundem || name == topic.favList || name == topic.followList)
                  ? name
                  : topic.getKeyFromVal(name);
              list = state.getToldyaListByTopic(
                authstate.userModel,
                searchState.getUserInBlackList(authstate.userModel),
                textController.text,
                statu,
                topic_val: topicVal,
              );
              final dataLoaded = state.feedlist != null;
              final showLoader = state.isBusy || !dataLoaded;
              return RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  child: CustomScrollView(
                    key: PageStorageKey<String>(name),
                    physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: <Widget>[
                      SliverToBoxAdapter(child: SizedBox(height: 8)),
                      showLoader
                              ? SliverToBoxAdapter(
                                  child: Container(
                                    height: fullHeight(context) - 135,
                                    child: CustomScreenLoader(
                                      height: double.infinity,
                                      width: fullWidth(context),
                                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                    ),
                                  ),
                                )
                          : !state.isBusy && list.isEmpty
                              ? SliverToBoxAdapter(
                                  child: SizedBox(
                                    height: fullHeight(context) - 135,
                                    child: EmptyStateContent(),
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final model = list[index];
                                      return Padding(
                                        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2C2C2E),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          padding: EdgeInsets.all(16),
                                          child: PredictionCardMockup(
                                            model: model,
                                            scaffoldKey: widget.scaffoldKey ?? GlobalKey<ScaffoldState>(),
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: list.length,
                                  ),
                                )
                    ],
                  ),
                  onRefresh: () async {
                    var feedState = Provider.of<FeedState>(context, listen: false);
                    feedState.getDataFromDatabase();
                    return Future.value(true);
                  });
            });
          }).toList(),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? MockupDesign.background
            : Theme.of(context).scaffoldBackgroundColor,
      ),
    );
    });
  }
}

class Choice {
  const Choice({required this.title, required this.icon});

  final IconData icon;
  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'devam eden', icon: Icons.directions_bike),
  const Choice(title: 'bekleyen', icon: Icons.directions_bike),
  const Choice(title: 'onaylanan', icon: Icons.directions_boat),
  const Choice(title: 'reddedilen', icon: Icons.directions_bus),
  const Choice(title: 'tamamlanan', icon: Icons.directions_railway),
  const Choice(title: 'AI incelemesinde', icon: Icons.pending_actions),
  const Choice(title: 'AI reddi', icon: Icons.block),
];

