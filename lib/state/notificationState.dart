import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toldya/helper/network_utils.dart';
import 'package:toldya/helper/utility.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/model/notificationModel.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/state/appState.dart';
import '../helper/locator.dart';
import '../helper/push_notification_service.dart';

class NotificationState extends AppState {
  dabase.Query? query;
  List<UserModel> userList = [];

  List<NotificationModel>? _notificationList;
  DateTime? _lastSeenAt;
  bool isBusy = false;
  String? _notificationError;

  String? get notificationError => _notificationError;

  void clearNotificationError() {
    _notificationError = null;
    notifyListeners();
  }

  addNotificationList(NotificationModel model) {
    _notificationList ??= <NotificationModel>[];

    if (!_notificationList!.any((element) => element.id == model.id)) {
      _notificationList!.insert(0, model);
    }
  }

  List<NotificationModel> get notificationList => _notificationList ?? [];

  /// Okunmamış bildirim sayısı: lastSeenAt'tan sonra gelenler. lastSeenAt yoksa tümü okunmamış.
  int get unreadCount {
    final list = _notificationList ?? [];
    final seen = _lastSeenAt;
    if (seen == null) return list.length;
    return list.where((n) => (n.timeStamp ?? DateTime(0)).isAfter(seen)).length;
  }

  static const String _lastSeenKeyPrefix = 'notification_last_seen_';

  Future<void> _loadLastSeenAt(String userId) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString('$_lastSeenKeyPrefix$userId');
      if (value != null) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) {
          _lastSeenAt = parsed;
          notifyListeners();
        }
      }
    } catch (e) {
      cprint(e, errorIn: '_loadLastSeenAt');
    }
  }

  /// Bildirim listesi sayfası açıldığında çağrılır; o ana kadarki tüm bildirimler okundu kabul edilir.
  Future<void> markAllAsSeen(String userId) async {
    if (userId.isEmpty) return;
    _lastSeenAt = DateTime.now();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_lastSeenKeyPrefix$userId', _lastSeenAt!.toIso8601String());
    } catch (e) {
      cprint(e, errorIn: 'markAllAsSeen');
    }
    notifyListeners();
  }

  /// [Intitilise firebase notification kDatabase]
  /// Listener'lar kurulduktan sonra _loadLastSeenAt çağrılır; böylece uygulama açılışında badge doğru hesaplanır.
  Future<bool> databaseInit(String userId) async {
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

      await _loadLastSeenAt(userId);
      return true;
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return false;
    }
  }

  /// get [Notification list] from firebase realtime database
  /// Does not clear _notificationList at start; keeps previous data until new data or error.
  void getDataFromDatabase(String userId) {
    _notificationError = null;
    isBusy = true;
    notifyListeners();
    runWithTimeoutAndRetry(() => kDatabase.child('notification').child(userId).once())
        .then((DatabaseEvent event) async {
      final snapshot = event.snapshot;
      final newList = <NotificationModel>[];
      if (snapshot.value != null) {
        var map = snapshot.value as Map<dynamic, dynamic>;
        if (map != null) {
          map.forEach((toldyaKey, value) {
            var mapVal = value as Map<dynamic, dynamic>;
            var model = NotificationModel.fromJson(toldyaKey.toString(), mapVal);
            newList.add(model);
          });
          newList.sort((x, y) => (x.timeStamp ?? DateTime(0)).compareTo(y.timeStamp ?? DateTime(0)));
        }
      }
      _notificationList = newList;
      isBusy = false;
      await _loadLastSeenAt(userId);
      notifyListeners();
    }).catchError((error) {
      isBusy = false;
      _notificationError = error?.toString() ?? 'Failed to load notifications';
      cprint(error, errorIn: 'getDataFromDatabase');
      notifyListeners();
    });
  }

  /// get `Tweet` present in notification
  Future<FeedModel?> getToldyaDetail(String toldyaId) async {
    var event = await kDatabase.child('toldya').child(toldyaId).once();
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      var _toldyaDetail = FeedModel.fromJson(map);
      _toldyaDetail.key = event.snapshot.key;
      return _toldyaDetail;
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
  void removeNotification(String userId, String toldyaKey) async {
    kDatabase.child('notification').child(userId).child(toldyaKey).remove();
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
      _notificationList?.removeWhere((x) => x.toldyaKey == model.toldyaKey);
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
