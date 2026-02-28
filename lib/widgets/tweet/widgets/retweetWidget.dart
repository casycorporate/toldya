import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customUrlText.dart';
import 'package:bendemistim/widgets/newWidget/rippleButton.dart';
import 'package:bendemistim/widgets/newWidget/title_text.dart';
import 'package:bendemistim/widgets/tweet/widgets/tweetImage.dart';
import 'package:bendemistim/widgets/tweet/widgets/unavailableTweet.dart';
import 'package:provider/provider.dart';

class RetoldyaWidget extends StatelessWidget {
  const RetoldyaWidget(
      {Key? key, required this.childRetoldyaKey, required this.type, this.isImageAvailable = false})
      : super(key: key);

  final String childRetoldyaKey;
  final bool isImageAvailable;
  final ToldyaType type;

  Widget _tweet(BuildContext context, FeedModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: fullWidth(context) - 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                width: 25,
                height: 25,
                child: customProfileImage(context, model.user?.profilePic, userId: model.user?.userId),
              ),
              SizedBox(width: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: 0, maxWidth: fullWidth(context) * .5),
                child: TitleText(
                  model.user?.displayName ?? '',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 3),
              (model.user?.isVerified ?? false)
                  ? customIcon(
                      context,
                      icon: AppIcon.blueTick,
                      istwitterIcon: true,
                      iconColor: AppColor.primary,
                      size: 13,
                      paddingIcon: 3,
                    )
                  : SizedBox(width: 0),
              SizedBox(
                width: (model.user?.isVerified ?? false) ? 5 : 0,
              ),
              Flexible(
                child: customText(
                  '${model.user?.userName ?? ''}',
                  style: userNameStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4),
              customText('· ${getChatTime(model.createdAt ?? '')}',
                  style: userNameStyle),
            ],
          ),
        ),
        model.description == null
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: UrlText(
                  text: model.description ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  urlStyle: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.w400),
                ),
              ),
        SizedBox(height: model.imagePath == null ? 8 : 0),
        ToldyaImage(model: model, type: type, isRetweetImage: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var feedstate = Provider.of<FeedState>(context, listen: false);
    return FutureBuilder(
      future: feedstate.fetchToldya(childRetoldyaKey),
      builder: (context, AsyncSnapshot<FeedModel?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Container(
            margin: EdgeInsets.only(
                left: type == ToldyaType.Toldya || type == ToldyaType.ParentToldya
                    ? 70
                    : 12,
                right: 16,
                top: isImageAvailable ? 8 : 5),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.extraLightGrey, width: .5),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: RippleButton(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              onPressed: () {
                final data = snapshot.data!;
                feedstate.getpostDetailFromDatabase(data.key ?? '', model: data);
                Navigator.of(context)
                    .pushNamed('/FeedPostDetail/' + (data.key ?? ''));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: _tweet(context, snapshot.data!),
              ),
            ),
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
