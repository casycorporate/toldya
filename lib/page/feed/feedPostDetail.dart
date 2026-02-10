import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/tweet/tweet.dart';
import 'package:bendemistim/widgets/tweet/widgets/tweetBottomSheet.dart';
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
    // var state = Provider.of<FeedState>(context, listen: false);
    // state.getpostDetailFromDatabase(postId);
    super.initState();
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        var state = Provider.of<FeedState>(context, listen: false);
        final last = state.tweetDetailModel?.last;
        if (last != null) state.setToldyaToReply = last;
        Navigator.of(context).pushNamed('/ComposeTweetPage/' + postId);
      },
      child: Icon(Icons.add),
    );
  }

  Widget _commentRow(FeedModel model) {
    return Toldya(
      model: model,
      type: ToldyaType.Reply,
      trailing: ToldyaBottomSheet().toldyaOptionIcon(context,
          scaffoldKey: scaffoldKey, model: model, type: ToldyaType.Reply),
    );
  }

  Widget _tweetDetail(FeedModel model) {
    return Toldya(
      model: model,
      type: ToldyaType.Detail,
      trailing: ToldyaBottomSheet().toldyaOptionIcon(context,
          scaffoldKey: scaffoldKey, model: model, type: ToldyaType.Detail),
    );
  }

  // void addLikeToComment(String commentId) {
  //   var state = Provider.of<FeedState>(context, listen: false);
  //   var authState = Provider.of<AuthState>(context, listen: false);
  //   state.addLikeToTweet(state.tweetDetailModel.last, authState.userId,1);
  // }

  void openImage() async {
    Navigator.pushNamed(context, '/ImageViewPge');
  }

  void deleteToldya(ToldyaType type, String toldyaId, {String parentkey = ''}) {
    var state = Provider.of<FeedState>(context, listen: false);
    state.deleteToldya(toldyaId, type, parentkey: parentkey);
    Navigator.of(context).pop();
    if (type == ToldyaType.Detail) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    return WillPopScope(
      onWillPop: () async {
        Provider.of<FeedState>(context, listen: false)
            .removeLastTweetDetail(postId);
        return Future.value(true);
      },
      child: Scaffold(
        key: scaffoldKey,
        floatingActionButton: _floatingActionButton(),
        backgroundColor: ToldyaColor.mystic,
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              elevation: 0,
              title: customTitleText('Tahmin Detayı'),
              iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
              backgroundColor: Colors.white,
              bottom: PreferredSize(
                child: Container(
                  color: AppColor.extraLightGrey,
                  height: 1.0,
                ),
                preferredSize: Size.fromHeight(0.0),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  if ((state.tweetDetailModel?.length ?? 0) > 0)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
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
                          child: _tweetDetail(state.tweetDetailModel!.last),
                        ),
                      ),
                    ),
                  if ((state.tweetDetailModel?.length ?? 0) > 0)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'Yorumlar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                state.tweetReplyMap == null ||
                        state.tweetReplyMap.isEmpty ||
                        state.tweetReplyMap[postId] == null
                    ? [
                        Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'Henüz yorum yok',
                              style: TextStyle(
                                color: ToldyaColor.paleSky,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      ]
                    : (state.tweetReplyMap[postId] ?? [])
                        .map((x) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
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
            SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
