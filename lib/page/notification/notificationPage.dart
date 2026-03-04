import 'package:toldya/model/userPegModel.dart';
import 'package:flutter/material.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/model/notificationModel.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/state/notificationState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/customLoader.dart';
import 'package:toldya/widgets/newWidget/emptyList.dart';
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
  static const double _heartBadgeSize = 18.0;

  Widget _buildOverlappingAvatars(
    BuildContext context,
    List<UserPegModel> list,
  ) {
    final state = Provider.of<NotificationState>(context);
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }

    // Maksimum gösterilecek avatar sayısı (geri kalanı +N şeklinde)
    const maxVisible = 4;
    final totalUserCount = list.length;
    final visibleUsers = List<UserPegModel>.from(list.take(maxVisible));
    final extraCount = totalUserCount - visibleUsers.length;

    // Stack genişliği: avatarlar + opsiyonel "+N" balonu için alan
    final avatarTrackWidth =
        _avatarSize + (visibleUsers.length - 1) * (_avatarSize - _overlap);
    final extraBubbleWidth = extraCount > 0 ? 26.0 : 0.0;
    final totalWidth = avatarTrackWidth + extraBubbleWidth;

    return SizedBox(
      width: totalWidth,
      height: _avatarSize + 10,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visibleUsers.length; i++)
            Positioned(
              left: i * (_avatarSize - _overlap),
              top: 0,
              child: _userAvatar(
                context,
                visibleUsers[i].userId,
                state,
                (name) {},
                borderColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: avatarTrackWidth - _overlap + 4,
              top: (_avatarSize - 22) / 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                alignment: Alignment.center,
                child: Text(
                  '+$extraCount',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          // Kalp rozeti: son avatarın sağ alt köşesine binen mini rozet
          Positioned(
            left: (visibleUsers.length - 1) * (_avatarSize - _overlap) +
                _avatarSize -
                (_heartBadgeSize * 0.65),
            bottom: -2,
            child: Container(
              width: _heartBadgeSize,
              height: _heartBadgeSize,
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
                size: 11,
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              offset: const Offset(0, 10),
              blurRadius: 24,
              spreadRadius: -8,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverlappingAvatars(context, list),
            const SizedBox(width: 14),
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
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      height: 1.4,
                    ),
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
