import 'package:bendemistim/model/userPegModel.dart';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/model/notificationModel.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/state/notificationState.dart';
import 'package:bendemistim/widgets/customAppBar.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customUrlText.dart';
import 'package:bendemistim/widgets/newWidget/emptyList.dart';
import 'package:bendemistim/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key? key, this.scaffoldKey}) : super(key: key);

  /// scaffoldKey used to open sidebaar drawer
  final GlobalKey<ScaffoldState>? scaffoldKey;

  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var state = Provider.of<NotificationState>(context, listen: false);
      var authstate = Provider.of<AuthState>(context, listen: false);
      state.getDataFromDatabase(authstate.userId);
    });
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/NotificationPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ToldyaColor.mystic,
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey,
        title: customTitleText(
          'Bildirimler',
        ),
        //icon: AppIcon.settings,
        //onActionPressed: onSettingIconPressed,
      ),
      body: NotificationPageBody(),
    );
  }
}

class NotificationPageBody extends StatelessWidget {
  const NotificationPageBody({Key? key}) : super(key: key);

  Widget _notificationRow(BuildContext context, NotificationModel model) {
    var state = Provider.of<NotificationState>(context);
    return FutureBuilder<FeedModel?>(
      future: state.getTweetDetail(model.tweetKey ?? ''),
      builder: (BuildContext context, AsyncSnapshot<FeedModel?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return NotificationTile(
            model: snapshot.data!,
          );
        } else if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return SizedBox(
            height: 4,
            child: LinearProgressIndicator(),
          );
        } else {
          var authstate = Provider.of<AuthState>(context);
          state.removeNotification(authstate.userId, model.tweetKey ?? '');
          return SizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<NotificationState>(context);
    var list = state.notificationList;
    if (state?.isbusy ?? true && (list == null || list.isEmpty)) {
      return SizedBox(
        height: 3,
        child: LinearProgressIndicator(),
      );
    } else if (list == null || list.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: EmptyList(
          'Henüz bir Bildirim yok',
          subTitle: 'Yeni bildirim bulunduğunda burada görünürler.',
          // 'No Notification available yet',
          // subTitle: 'When new notifiction found, they\'ll show up here.',
        ),
      );
    }
    return ListView.builder(
      addAutomaticKeepAlives: true,
      itemBuilder: (context, index) => _notificationRow(context, list![index]),
      itemCount: list!.length,
    );
  }
}

class NotificationTile extends StatelessWidget {
  final FeedModel model;
  const NotificationTile({Key? key, required this.model}) : super(key: key);
  Widget _userList(BuildContext context, List<UserPegModel> list) {
    // List<String> names = [];
    // list=list.toSet().toList();//aynı olan kullanıcılar(hem like hem dislike) teke indirilir
    final ids = list.map((e) => e.userId).toSet();
    list.retainWhere((x) => ids.remove(x.userId));
    var length = list.length;
    List<Widget> avaterList = [];
    final int noOfUser = list.length;
    var state = Provider.of<NotificationState>(context);
    if (list != null && list.length > 5) {
      list = list.take(5).toList();
    }
    avaterList = list.map((userId) {
      return _userAvater(userId.userId, state, (name) {
        // names.add(name);
      });
    }).toList();
    if (noOfUser > 5) {
      avaterList.add(
        Text(
          " +${noOfUser - 5}",
          style: subtitleStyle.copyWith(fontSize: 16),
        ),
      );
    }

    var col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(width: 20),
            customIcon(context,
                icon: AppIcon.heartFill,
                iconColor: ToldyaColor.ceriseRed,
                istwitterIcon: true,
                size: 25),
            SizedBox(width: 10),
            Row(children: avaterList),
          ],
        ),
        // names.length > 0 ? Text(names[0]) : SizedBox(),
        Padding(
          padding: EdgeInsets.only(left: 60, bottom: 5, top: 5),
          child: TitleText(
            '$length kişi paylaşımınıza oy verdi',
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
    return col;
  }

  Widget _userAvater(
      String userId, NotificationState state, ValueChanged<String> name) {
    return FutureBuilder<UserModel?>(
      future: state.getuserDetail(userId),
      builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          name(data.displayName ?? '');
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/ProfilePage/' + (data.userId ?? ''));
              },
              child: customImage(context, data.profilePic ?? '', height: 30),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var description = (model.description?.length ?? 0) > 150
        ? (model.description?.substring(0, 150) ?? '') + '...'
        : model.description ?? '';
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          color: ToldyaColor.white,
          child: ListTile(
            onTap: () {
              var state = Provider.of<FeedState>(context, listen: false);
              state.getpostDetailFromDatabase(model.key ?? '', model: model);
              Navigator.of(context).pushNamed('/FeedPostDetail/${model.key ?? ''}');
            },
            title: _userList(context, (model.likeList ?? []) + (model.unlikeList ?? [])),
            subtitle: Padding(
              padding: EdgeInsets.only(left: 60),
              child: UrlText(
                text: description ?? '',
                style: TextStyle(
                  color: AppColor.darkGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        Divider(height: 0, thickness: .6)
      ],
    );
  }
}
