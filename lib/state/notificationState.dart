import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/model/notificationModel.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/state/appState.dart';
import '../helper/locator.dart';
import '../helper/push_notification_service.dart';

class NotificationState extends AppState {
  // String fcmToken;
  // FeedModel notificationTweetModel;

  // FcmNotificationModel notification;
  // String notificationSenderId;
  dabase.Query? query;
  List<UserModel> userList = [];

  List<NotificationModel>? _notificationList;

  addNotificationList(NotificationModel model) {
    _notificationList ??= <NotificationModel>[];

    if (!_notificationList!.any((element) => element.id == model.id)) {
      _notificationList!.insert(0, model);
    }
  }

  List<NotificationModel> get notificationList => _notificationList ?? [];

  /// [Intitilise firebase notification kDatabase]
  Future<bool> databaseInit(String userId) {
    try {
      final q = query;
      if (q != null) {
        q.onValue.drain();
        query = null;
        _notificationList = null;
      }
      query = kDatabase.child("notification").child(userId);
      final newQuery = query!;
      newQuery.onChildAdded.listen(_onNotificationAdded);
      newQuery.onChildChanged.listen(_onNotificationChanged);
      newQuery.onChildRemoved.listen(_onNotificationRemoved);

      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  /// get [Notification list] from firebase realtime database
  void getDataFromDatabase(String userId) {
    bool isBusy = false;
    try {
      if (_notificationList != null) {
        return;
      }
      isBusy = true;
      kDatabase
          .child('notification')
          .child(userId)
          .once()
          .then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          var map = snapshot.value as Map<dynamic, dynamic>;
          if (map != null) {
            map.forEach((tweetKey, value) {
              var map = value as Map<dynamic, dynamic>;
              var model = NotificationModel.fromJson(tweetKey, map);
              addNotificationList(model);
            });
            _notificationList!
                .sort((x, y) => (x.timeStamp ?? DateTime(0)).compareTo(y.timeStamp ?? DateTime(0)));
          }
        }
        isBusy = false;
      });
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// get `Tweet` present in notification
  Future<FeedModel?> getTweetDetail(String tweetId) async {
    var event = await kDatabase.child('tweet').child(tweetId).once();
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      var _tweetDetail = FeedModel.fromJson(map);
      _tweetDetail.key = event.snapshot.key;
      return _tweetDetail;
    }
    return null;
  }

  /// get user who liked your tweet
  Future<UserModel?> getuserDetail(String userId) async {
    if (userList.isNotEmpty && userList.any((x) => x.userId == userId)) {
      return userList.firstWhere((x) => x.userId == userId);
    }
    var event = await kDatabase.child('profile').child(userId).once();

    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      var user = UserModel.fromJson(map);
      user.key = event.snapshot.key;
      userList.add(user);
      return user;
    }
    return null;
  }

  /// Remove notification if related Tweet is not found or deleted
  void removeNotification(String userId, String tweetkey) async {
    kDatabase.child('notification').child(userId).child(tweetkey).remove();
  }

  /// Trigger when somneone like your tweet
  void _onNotificationAdded(DatabaseEvent event) {
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      var model = NotificationModel.fromJson(event.snapshot.key ?? '', map);

      addNotificationList(model);
      // added notification to list
      print("Notification added");
      notifyListeners();
    }
  }

  /// Trigger when someone changed his like preference
  void _onNotificationChanged(DatabaseEvent event) {
    if (event.snapshot.value != null) {
      notifyListeners();
      print("Notification changed");
    }
  }

  /// Trigger when someone undo his like on tweet
  void _onNotificationRemoved(DatabaseEvent event) {
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      var model = NotificationModel.fromJson(event.snapshot.key ?? '', map);
      // remove notification from list
      _notificationList?.removeWhere((x) => x.tweetKey == model.tweetKey);
      notifyListeners();
      print("Notification Removed");
    }
  }

  /// Initilise push notification services
  void initfirebaseService() {
    if (!getIt.isRegistered<PushNotificationService>()) {
      getIt.registerSingleton<PushNotificationService>(
          PushNotificationService(FirebaseMessaging.instance));
    }
  }

  @override
  void dispose() {
    getIt.unregister<PushNotificationService>();
    super.dispose();
  }
}
