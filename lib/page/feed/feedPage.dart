import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/helper/topicMap.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/state/appState.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/state/notificationState.dart';
import 'package:toldya/state/searchState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/customLoader.dart';
import 'package:toldya/widgets/newWidget/custom_shimmer.dart';
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
  static const int _kMaxTabs = 20;
  late List<ScrollController> _scrollControllers;
  late List<bool> _scrollListenerAttached;
  Timer? _idleShowBarTimer;
  static const Duration _idleShowBarDelay = Duration(seconds: 2);
  double? _lastScrollPixels;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    _scrollControllers = List.generate(_kMaxTabs, (_) => ScrollController());
    _scrollListenerAttached = List.filled(_kMaxTabs, false);
  }

  void _resetIdleShowBarTimer() {
    _idleShowBarTimer?.cancel();
    _idleShowBarTimer = Timer(_idleShowBarDelay, () {
      if (mounted) {
        Provider.of<AppState>(context, listen: false).setFeedBottomBarVisible = true;
      }
      _idleShowBarTimer = null;
    });
  }

  @override
  void dispose() {
    _idleShowBarTimer?.cancel();
    _idleShowBarTimer = null;
    for (final c in _scrollControllers) {
      c.dispose();
    }
    textController.dispose();
    super.dispose();
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
      debugPrint("[FeedDebug] FeedPage: mainList.length=${mainList.length}, feedState.feedlist?.length=${feedState.feedlist?.length}, isBusy=${feedState.isBusy}, statu=$statu");
      // Boş ekranı sadece veri yüklendikten sonra ve gerçekten tahmin yoksa göster
      final showEmptyState = !feedState.isBusy &&
          feedState.feedlist != null &&
          mainList.isEmpty;
      debugPrint("[FeedDebug] FeedPage: showEmptyState=$showEmptyState (isBusy=${feedState.isBusy}, feedlist!=null=${feedState.feedlist != null}, mainList.isEmpty=${mainList.isEmpty})");
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
          onSearchPressed: () {},
          onNotificationsPressed: () => Navigator.pushNamed(context, '/NotificationFeedPage'),
          onProfilePressed: () {
            Provider.of<AppState>(context, listen: false).setpageIndex = 1;
          },
        );
      }
      final l10n = AppLocalizations.of(context)!;
      final feedStateForScroll = Provider.of<FeedState>(context, listen: false);
      if (!_scrollListenerAttached[0]) {
        _scrollListenerAttached[0] = true;
        final c = _scrollControllers[0];
        c.addListener(() {
          if (c.hasClients &&
              feedStateForScroll.hasMoreFeed &&
              !feedStateForScroll.isLoadingMore &&
              c.position.pixels >= c.position.maxScrollExtent - 200) {
            feedStateForScroll.loadMoreFeed();
          }
          if (c.hasClients) _resetIdleShowBarTimer();
        });
      }
      final hasData = feedState.feedlist != null;
      final waitingForDb = feedState.feedlist == null;
      final refreshing = hasData && feedState.isBusy;
      final hasError = feedState.feedError != null;
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? MockupDesign.background
            : Theme.of(context).scaffoldBackgroundColor,
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification n) {
            final appState = Provider.of<AppState>(context, listen: false);
            if (n.metrics.axis == Axis.vertical &&
                (n is UserScrollNotification || n is ScrollUpdateNotification)) {
              if (appState.feedBottomBarVisible) {
                appState.setFeedBottomBarVisible = false;
              }
              _resetIdleShowBarTimer();
            }
            return false;
          },
          child: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              HapticFeedback.lightImpact();
              feedState.clearFeedError();
              feedState.getDataFromDatabase();
            },
            child: CustomScrollView(
              controller: _scrollControllers[0],
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: <Widget>[
                SliverAppBar(
                  floating: true,
                  snap: true,
                  centerTitle: true,
                  title: Text(
                    AppLocalizations.of(context)!.appTitle,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    color: Colors.white,
                    onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
                  ),
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? MockupDesign.background
                      : Theme.of(context).scaffoldBackgroundColor,
                  actions: [
                    if (authstate.userModel != null && !authstate.isbusy) ...[
                      Consumer<NotificationState>(
                        builder: (context, notifState, _) {
                          final unreadCount = notifState.unreadCount;
                          final child = IconButton(
                            icon: const Icon(Icons.notifications_none, color: Colors.white, size: 24),
                            onPressed: () => Navigator.pushNamed(context, '/NotificationFeedPage'),
                            tooltip: l10n.notificationsTitle,
                          );
                          if (unreadCount <= 0) return child;
                          return Badge(
                            isLabelVisible: true,
                            label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                            smallSize: 8,
                            backgroundColor: ToldyaDesign.no,
                            child: child,
                          );
                        },
                      ),
                      if (authstate.userModel?.role == Role.adminRole)
                        PopupMenuButton<Choice>(
                          onSelected: (d) {
                            switch (d.id) {
                              case 'pending': statu = Statu.statusPending; break;
                              case 'approved': statu = Statu.statusOk; break;
                              case 'rejected': statu = Statu.statusDenied; break;
                              case 'completed': statu = Statu.statusComplete; break;
                              case 'pendingAi': statu = Statu.statusPendingAiReview; break;
                              case 'rejectedAi': statu = Statu.statusRejectedByAi; break;
                              default: statu = Statu.statusLive;
                            }
                            setState(() {});
                          },
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          itemBuilder: (ctx) => choices.map((Choice choice) =>
                              PopupMenuItem<Choice>(value: choice, child: Text(choice.label(ctx)))).toList(),
                        )
                      else
                        IconButton(
                          onPressed: () {
                            setState(() {
                              statu = statu == Statu.statusLive ? Statu.statusOk : Statu.statusLive;
                            });
                          },
                          icon: Icon(
                            Icons.history,
                            color: statu == Statu.statusLive ? Colors.white70 : AppColor.primary,
                          ),
                        ),
                    ],
                  ],
                ),
                SliverToBoxAdapter(child: SizedBox(height: 8)),
                if (refreshing)
                  SliverToBoxAdapter(
                    child: LinearProgressIndicator(
                      backgroundColor: MockupDesign.background,
                      valueColor: AlwaysStoppedAnimation<Color>(ToldyaDesign.statusBadge),
                    ),
                  ),
                if (hasError && mainList.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.errorTryAgain, textAlign: TextAlign.center,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              feedState.clearFeedError();
                              feedState.getDataFromDatabase();
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (waitingForDb)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: fullHeight(context) - 135,
                      child: FeedShimmer(),
                    ),
                  )
                else if (mainList.isEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: fullHeight(context) - 135,
                      child: EmptyStateContent(),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final model = mainList[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: MockupDesign.card,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: PredictionCardMockup(
                              model: model,
                              scaffoldKey: widget.scaffoldKey ?? GlobalKey<ScaffoldState>(),
                            ),
                          ),
                        );
                      },
                      childCount: mainList.length,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: feedState.isLoadingMore
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.loading,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : (!feedState.hasMoreFeed && mainList.isNotEmpty)
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  l10n.endOfResults,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
    ), // NotificationListener
  ); // Scaffold
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

