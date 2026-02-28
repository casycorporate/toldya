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
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';
import 'package:bendemistim/widgets/newWidget/emptyList.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: widget.scaffoldKey != null
            ? Padding(
                padding: EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () => widget.scaffoldKey!.currentState?.openDrawer(),
                  child: customProfileImage(
                    context,
                    Provider.of<AuthState>(context).userModel?.profilePic,
                    userId: Provider.of<AuthState>(context).userModel?.userId,
                    height: 30,
                  ),
                ),
              )
            : BackButton(color: Colors.white),
        title: Text(
          'Bildirimler',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
        titleSpacing: 0,
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
      future: state.getToldyaDetail(model.toldyaKey ?? ''),
      builder: (BuildContext context, AsyncSnapshot<FeedModel?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return NotificationTile(
            model: snapshot.data!,
          );
        } else if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: CustomScreenLoader(
                height: 36,
                width: 36,
                backgroundColor: Colors.transparent,
              ),
            ),
          );
        } else {
          var authstate = Provider.of<AuthState>(context);
          state.removeNotification(authstate.userId, model.toldyaKey ?? '');
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
      return Center(
        child: CustomScreenLoader(
          height: 80,
          width: 80,
          backgroundColor: Colors.transparent,
        ),
      );
    } else if (list == null || list.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding * 2),
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
      padding: EdgeInsets.symmetric(vertical: spacing8),
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding, vertical: spacing4),
        child: _notificationRow(context, list![index]),
      ),
      itemCount: list!.length,
    );
  }
}

class NotificationTile extends StatelessWidget {
  final FeedModel model;
  const NotificationTile({Key? key, required this.model}) : super(key: key);

  static const double _avatarSize = 32.0;
  static const double _overlap = 10.0; // ~30% overlap
  static const double _avatarBorderWidth = 1.0;
  static const double _heartBadgeSize = 18.0; // rozet için ayrılan alan

  Widget _buildOverlappingAvatars(
    BuildContext context,
    List<UserPegModel> list,
  ) {
    var displayList = List<UserPegModel>.from(list);
    final noOfUser = displayList.length;
    final state = Provider.of<NotificationState>(context);
    if (displayList.length > 5) displayList = displayList.take(5).toList();

    final avatarWidgets = displayList.asMap().entries.map((entry) {
      final i = entry.key;
      final userId = entry.value.userId;
      return Transform.translate(
        offset: Offset(i * (_avatarSize - _overlap), 0),
        child: _userAvatar(
          context,
          userId,
          state,
          (name) {},
          borderColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      );
    }).toList();

    // Genişlik: avatarlar + kalp rozeti (overflow olmaması için)
    final contentWidth = (displayList.length * (_avatarSize - _overlap)) + _overlap;
    final extraForBadge = displayList.isNotEmpty ? _heartBadgeSize : 0.0;
    final extraForCount = noOfUser > 5 ? 20.0 : 0.0;
    final totalWidth = contentWidth + extraForBadge + extraForCount;

    return SizedBox(
      width: totalWidth,
      height: _avatarSize + 14,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...avatarWidgets,
              if (noOfUser > 5)
                Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    '+${noOfUser - 5}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          // Kalp rozeti: son avatarın sağ alt köşesine binen mini rozet
          if (displayList.isNotEmpty)
            Positioned(
              right: extraForBadge + extraForCount,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.favorite,
                  size: 12,
                  color: ToldyaColor.ceriseRed,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _userAvatar(
    BuildContext context,
    String userId,
    NotificationState state,
    ValueChanged<String> name, {
    Color? borderColor,
  }) {
    return FutureBuilder<UserModel?>(
      future: state.getuserDetail(userId),
      builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          name(data.displayName ?? '');
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/ProfilePage/${data.userId ?? ''}');
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor ?? Colors.grey.shade800,
                  width: _avatarBorderWidth,
                ),
              ),
              child: customProfileImage(
                context,
                data.profilePic,
                userId: data.userId,
                height: _avatarSize,
              ),
            ),
          );
        }
        return SizedBox(width: _avatarSize, height: _avatarSize);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawList = (model.likeList ?? []) + (model.unlikeList ?? []);
    final seen = <String>{};
    final list = rawList.where((x) => seen.add(x.userId)).toList();
    final length = list.length;
    final description = model.description ?? '';

    return InkWell(
      onTap: () {
        final state = Provider.of<FeedState>(context, listen: false);
        state.getpostDetailFromDatabase(model.key ?? '', model: model);
        Navigator.of(context).pushNamed('/FeedPostDetail/${model.key ?? ''}');
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverlappingAvatars(context, list),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$length kişi paylaşımınıza oy verdi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 12),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
