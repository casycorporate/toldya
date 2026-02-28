import 'package:flutter/material.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/widgets/tweet/tweet.dart';
import 'package:bendemistim/widgets/tweet/widgets/unavailableTweet.dart';
import 'package:provider/provider.dart';

class ParentToldyaWidget extends StatelessWidget {
  ParentToldyaWidget(
      {Key? key, required this.childRetoldyaKey, required this.type, this.isImageAvailable = false, this.trailing = const SizedBox.shrink()})
      : super(key: key);

  final String childRetoldyaKey;
  final ToldyaType type;
  final Widget trailing;
  final bool isImageAvailable;

  void onTweetPressed(BuildContext context, FeedModel model) {
    var feedstate = Provider.of<FeedState>(context, listen: false);
    feedstate.getpostDetailFromDatabase(model.key ?? '', model: model);
    Navigator.of(context).pushNamed('/FeedPostDetail/' + (model.key ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    var feedstate = Provider.of<FeedState>(context, listen: false);
    return FutureBuilder(
        future: feedstate.fetchToldya(childRetoldyaKey),
        builder: (context, AsyncSnapshot<FeedModel?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Toldya(
              model: snapshot.data!,
              type: ToldyaType.ParentToldya,
              trailing: trailing
            );
          }
          if ((snapshot.connectionState == ConnectionState.done ||
                  snapshot.connectionState == ConnectionState.waiting) &&
              !snapshot.hasData) {
            return UnavailableToldya(
              snapshot: snapshot,
              type: type,
            );
          } else {
            return SizedBox.shrink();
          }
        },
      );
  }
}