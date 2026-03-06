import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/helper/topicMap.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/state/searchState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/customLoader.dart';
import 'package:toldya/widgets/newWidget/emptyList.dart';
import 'package:toldya/widgets/newWidget/empty_state_screen.dart';
import 'package:toldya/widgets/tweet/prediction_card_mockup.dart';
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
      final List<String> _tabValues = topic.topicMap.values.toList();
      List<FeedModel> list = [];
      _tabValues.insert(0, topic.gundem);
      _tabValues.insert(1, topic.favList);
      _tabValues.insert(2, topic.followList);
      final l10n = AppLocalizations.of(context)!;
      final _tabLabels = _tabValues.map((String val) {
        if (val == topic.gundem) return l10n.categoryFlow;
        if (val == topic.favList) return l10n.categoryFavorite;
        if (val == topic.followList) return l10n.categoryFollow;
        if (val == 'sports') return l10n.categorySports;
        if (val == 'economy') return l10n.categoryEconomy;
        if (val == 'entertainment') return l10n.categoryEntertainment;
        if (val == 'politics') return l10n.categoryPolitics;
        return val;
      }).toList();
      return DefaultTabController(
      length: _tabValues.length,
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
                hintText: AppLocalizations.of(context)!.searchHint,
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
                    switch (d.id) {
                      case 'pending':
                        statu = Statu.statusPending;
                        break;
                      case 'approved':
                        statu = Statu.statusOk;
                        break;
                      case 'rejected':
                        statu = Statu.statusDenied;
                        break;
                      case 'completed':
                        statu = Statu.statusComplete;
                        break;
                      case 'pendingAi':
                        statu = Statu.statusPendingAiReview;
                        break;
                      case 'rejectedAi':
                        statu = Statu.statusRejectedByAi;
                        break;
                      case 'live':
                      default:
                        statu = Statu.statusLive;
                        break;
                    }
                    setState(() {});
                  },
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (BuildContext context) {
                    return choices.map((Choice choice) {
                      return PopupMenuItem<Choice>(
                        value: choice,
                        child: Text(choice.label(context)),
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
                tabs: _tabLabels.map((String label) => Tab(text: label)).toList(),
              ),
            ),
            preferredSize: Size.fromHeight(48.0),
          ),
        ),
        body: TabBarView(
          children: _tabValues.map((String name) {
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
  const Choice({required this.id, required this.icon});

  final String id;
  final IconData icon;

  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case 'live':
        return l10n.adminFilterLive;
      case 'pending':
        return l10n.adminFilterPending;
      case 'approved':
        return l10n.adminFilterApproved;
      case 'rejected':
        return l10n.adminFilterRejected;
      case 'completed':
        return l10n.adminFilterCompleted;
      case 'pendingAi':
        return l10n.adminFilterPendingAiReview;
      case 'rejectedAi':
        return l10n.adminFilterRejectedByAi;
      default:
        return id;
    }
  }
}

const List<Choice> choices = <Choice>[
  Choice(id: 'live', icon: Icons.directions_bike),
  Choice(id: 'pending', icon: Icons.directions_bike),
  Choice(id: 'approved', icon: Icons.directions_boat),
  Choice(id: 'rejected', icon: Icons.directions_bus),
  Choice(id: 'completed', icon: Icons.directions_railway),
  Choice(id: 'pendingAi', icon: Icons.pending_actions),
  Choice(id: 'rejectedAi', icon: Icons.block),
];

