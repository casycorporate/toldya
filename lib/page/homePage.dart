import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/page/feed/feedPage.dart';
import 'package:bendemistim/page/message/chatListPage.dart';
import 'package:bendemistim/page/profile/profilePage.dart';
import 'package:bendemistim/state/appState.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/state/chats/chatState.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/state/notificationState.dart';
import 'package:bendemistim/state/searchState.dart';
import 'package:bendemistim/widgets/bottomMenuBar/bottomMenuBar.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:provider/provider.dart';
import '../helper/locator.dart';
import '../helper/push_notification_service.dart';
import '../model/PushNotificationModel.dart';
import 'common/sidebar.dart';
import 'notification/notificationPage.dart';
import 'search/SearchPage.dart';


class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  int pageIndex = 0;
  late StreamSubscription<PushNotificationModel> pushNotificationSubscription;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var state = Provider.of<AppState>(context, listen: false);
      state.setpageIndex = 0;
      initToldyas();
      initProfile();
      initSearch();
      initNotificaiton();
      initChat();
    });

    super.initState();
  }

  void initToldyas() {
    var state = Provider.of<FeedState>(context, listen: false);
    state.databaseInit();
    state.getDataFromDatabase();
  }

  void initProfile() {
    var state = Provider.of<AuthState>(context, listen: false);
    state.databaseInit();
  }

  void initSearch() {
    var searchState = Provider.of<SearchState>(context, listen: false);
    searchState.getDataFromDatabase();
  }

  void initNotificaiton() {
    var state = Provider.of<NotificationState>(context, listen: false);
    var authstate = Provider.of<AuthState>(context, listen: false);
    state.databaseInit(authstate.userId);
    state.initfirebaseService();
    pushNotificationSubscription = getIt<PushNotificationService>()
        .pushNotificationResponseStream
        .listen(listenPushNotification);
  }

  void listenPushNotification(PushNotificationModel model) {
    final authstate = Provider.of<AuthState>(context, listen: false);
    var state = Provider.of<NotificationState>(context, listen: false);

    /// Check if user recieve chat notification
    /// Redirect to chat screen
    /// `model.data.senderId` is a user id who sends you a message
    /// `model.data.receiverId` is a your user id.
    if (model.type == NotificationType.Message.toString() &&
        model.receiverId == authstate.user?.uid) {
      /// Get sender profile detail from firebase
      state.getuserDetail(model.senderId).then((user) {
        if (user == null) return;
        final chatState = Provider.of<ChatState>(context, listen: false);
        chatState.setChatUser = user;
        Navigator.pushNamed(context, '/ChatScreenPage');
      });
    }

    /// Checks for user tag tweet notification
    /// Redirect user to tweet detail if
    /// Tweet contains
    /// If you are mentioned in tweet then it redirect to user profile who mentioed you in a tweet
    /// You can check that tweet on his profile timeline
    /// `model.data.senderId` is user id who tagged you in a tweet
    else if (model.type == NotificationType.Mention.toString() &&
        model.receiverId == authstate.user?.uid) {
      var feedstate = Provider.of<FeedState>(context, listen: false);
      feedstate.getpostDetailFromDatabase(model.toldyaId);
      Navigator.of(context).pushNamed('/FeedPostDetail/' + model.toldyaId);
       // Navigator.push(context, FeedPostDetail.getRoute(model.toldyaId));
    }
  }

  void initChat() {
    final chatState = Provider.of<ChatState>(context, listen: false);
    final state = Provider.of<AuthState>(context, listen: false);
    chatState.databaseInit(state.userId, state.userId);

    /// It will update fcm token in database
    /// fcm token is required to send firebase notification
    // state.updateFCMToken();

    /// It get fcm server key
    /// Server key is required to configure firebase notification
    /// Without fcm server notification can not be sent
    chatState.getFCMServerKey();
  }

  /// On app launch it checks if app is launch by tapping on notification from notification tray
  /// If yes, it checks for  which type of notification is recieve
  /// If notification type is `NotificationType.Message` then chat screen will open
  /// If notification type is `NotificationType.Mention` then user profile will open who taged you in a tweet
  ///
  // void _checkNotification() {
  //   final authstate = Provider.of<AuthState>(context, listen: false);
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     var state = Provider.of<NotificationState>(context, listen: false);
  //
  //     /// Check if user recieve chat notification from firebase
  //     /// Redirect to chat screen
  //     /// `notificationSenderId` is a user id who sends you a message
  //     /// `notificationReciverId` is a your user id.
  //     if (state.notificationType == NotificationType.Message &&
  //         state.notificationReciverId == authstate.userModel.userId) {
  //       state.setNotificationType = null;
  //       state.getuserDetail(state.notificationSenderId).then((user) {
  //         cprint("Opening user chat screen");
  //         final chatState = Provider.of<ChatState>(context, listen: false);
  //         chatState.setChatUser = user;
  //         Navigator.pushNamed(context, '/ChatScreenPage');
  //       });
  //     }
  //
  //     /// Checks for user tag tweet notification
  //     /// If you are mentioned in tweet then it redirect to user profile who mentioed you in a tweet
  //     /// You can check that tweet on his profile timeline
  //     /// `notificationSenderId` is user id who tagged you in a tweet
  //     else if (state.notificationType == NotificationType.Mention &&
  //         state.notificationReciverId == authstate.userModel.userId) {
  //       state.setNotificationType = null;
  //       Navigator.of(context)
  //           .pushNamed('/ProfilePage/' + state.notificationSenderId);
  //     }
  //   });
  // }

  Widget _body() {
    return SafeArea(
      child: _getPage(Provider.of<AppState>(context).pageIndex),
    );
  }

  List<Widget> _buildScreens() {
    return [
      FeedPage(
        scaffoldKey: _scaffoldKey,
        refreshIndicatorKey: refreshIndicatorKey,
      ),
      SearchPage(scaffoldKey: _scaffoldKey),
      NotificationPage(scaffoldKey: _scaffoldKey),
      ChatListPage(scaffoldKey: _scaffoldKey),
      FeedPage(scaffoldKey: _scaffoldKey),
    ];
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return FeedPage(
          scaffoldKey: _scaffoldKey,
          refreshIndicatorKey: refreshIndicatorKey,
        );
        break;
      case 1:
        return SearchPage(scaffoldKey: _scaffoldKey);
        break;
      case 2:
        return NotificationPage(scaffoldKey: _scaffoldKey);
        break;
      case 3:
        return ProfilePage();
        break;
      default:
        return FeedPage(scaffoldKey: _scaffoldKey);
        break;
    }
  }

  Widget _floatingActionButton(BuildContext context) {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppNeon.green,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(),
        child: InkWell(
          customBorder: CircleBorder(),
          onTap: () => Navigator.of(context).pushNamed('/CreateFeedPage/toldya'),
          child: Center(
            child: Icon(
              Icons.bolt,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom==0.0;
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: showFab ? _floatingActionButton(context) : null,
      bottomNavigationBar: BottomMenubar(),
      drawer: SidebarMenu(),
      body: _body(),
    );
  }
}
