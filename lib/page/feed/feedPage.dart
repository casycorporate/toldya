import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/topicMap.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/state/searchState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';
import 'package:bendemistim/widgets/newWidget/emptyList.dart';
import 'package:bendemistim/widgets/tweet/tweet.dart';
import 'package:bendemistim/widgets/tweet/widgets/tweetBottomSheet.dart';
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
        Navigator.of(context).pushNamed('/CreateFeedPage/tweet');
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
    final List<String> _tabs = topic.topicMap.values.toList();
    List<FeedModel> list = [];
    _tabs.insert(0, topic.gundem);
    _tabs.insert(1, topic.favList);
    _tabs.insert(2, topic.followList);
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              widget.scaffoldKey?.currentState?.openDrawer();
            },
          ),
          title: Container(
              height: 50,
              padding: EdgeInsets.symmetric(vertical: 5),
              child: TextField(
                textInputAction: TextInputAction.search,
                onChanged: (text) {
                  // list.remove(list.first);sinanylmaz07@gmail.com
                },
                controller: textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  hintText: 'Arama..',
                  fillColor: AppColor.extraLightGrey,
                  filled: true,
                  focusColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
              )),
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          actions: [
            authstate.isbusy || authstate.userModel == null
                ? SizedBox.shrink()
                : authstate.userModel?.role == Role.adminRole
                    ? PopupMenuButton<Choice>(
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
                        itemBuilder: (BuildContext context) {
                          return choices.map((Choice choice) {
                            return PopupMenuItem<Choice>(
                              value: choice,
                              child: Text(choice.title),
                            );
                          }).toList();
                        },
                      )
                    : IconButton(
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
                              ? AppColor.darkGrey
                              : AppColor.primary,
                        ),
                      )
          ],
          bottom: PreferredSize(
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColor.extraLightGrey, width: 1)),
              ),
              child: TabBar(
                indicatorColor: AppColor.primary,
                indicatorWeight: 3,
                unselectedLabelColor: AppColor.darkGrey,
                labelColor: AppColor.primary,
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
              list = state.getTweetListByTopic(
                authstate.userModel,searchState.getUserInBlackList(authstate.userModel),
                textController.text,
                statu,
                topic_val: topic.getKeyFromVal(name) == null.toString()
                    ? name
                    : topic.getKeyFromVal(name),
              );
              return RefreshIndicator(
                  color: AppColor.primary,
                  child: CustomScrollView(
                    key: PageStorageKey<String>(name),
                    physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: <Widget>[
                      SliverToBoxAdapter(child: SizedBox(height: 8)),
                      state.isBusy && list == null
                          ? SliverToBoxAdapter(
                              child: Container(
                                height: fullHeight(context) - 135,
                                child: CustomScreenLoader(
                                  height: double.infinity,
                                  width: fullWidth(context),
                                  backgroundColor: ToldyaColor.mystic,
                                ),
                              ),
                            )
                          : !state.isBusy && list.isEmpty
                              ? SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 24),
                                    child: EmptyList(
                                      'Henüz bir tahmin yok',
                                      subTitle:
                                          'Yeni tahminler burada görünecek.\nAltta bulunan butona dokunarak tahmin oluşturabilirsiniz.',
                                    ),
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final model = list[index];
                                      return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.04),
                                                blurRadius: 12,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Toldya(
                                                model: model,
                                                trailing: ToldyaBottomSheet()
                                                    .toldyaOptionIcon(context,
                                                        model: model,
                                                        type: ToldyaType.Toldya,
                                                        scaffoldKey:
                                                            widget.scaffoldKey ?? GlobalKey<ScaffoldState>()),
                                            ),
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
      ),
    );
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

