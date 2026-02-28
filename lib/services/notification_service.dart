import 'dart:io';

import 'package:bendemistim/helper/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level handler for FCM background messages (app terminated/background).
/// Must be top-level or static to be used with [FirebaseMessaging.onBackgroundMessage].
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data.isNotEmpty) {
    cprint('Background message data: ${message.data}', event: 'FCM_BACKGROUND');
  }
}

/// FCM tabanlı bildirim servisi: izin, token, foreground heads-up,
/// background/terminated yönlendirme (deep linking).
class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  static GlobalKey<NavigatorState>? navigatorKey;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'Bildirimler';

  bool _initialized = false;

  /// Uygulama başlarken runApp öncesinde çağrılmalı.
  /// [navigatorKeyParam] MaterialApp'e verilen navigatorKey ile aynı olmalı.
  static Future<void> init(GlobalKey<NavigatorState>? navigatorKeyParam) async {
    navigatorKey = navigatorKeyParam;
    await instance._init();
  }

  Future<void> _init() async {
    if (_initialized) return;

    await _requestPermission();
    await _initLocalNotifications();
    await _refreshAndPersistToken();
    _setupForegroundHandler();
    _setupBackgroundOpenedHandler();
    _setupInitialMessageHandler();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _initialized = true;
    cprint('NotificationService initialized', event: 'FCM_INIT');
  }

  /// Firebase bildirim izinlerini ister (iOS/Android).
  Future<bool> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    cprint('FCM permission granted: $granted', event: 'FCM_PERMISSION');
    return granted;
  }

  /// İzin al (dışarıdan da çağrılabilir).
  Future<bool> requestPermission() async => _requestPermission();

  /// FCM cihaz token'ını al, konsola yaz ve (giriş yapılmışsa) veritabanına kaydet.
  Future<String?> getTokenAndPersist() async => _refreshAndPersistToken();

  Future<String?> _refreshAndPersistToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('[FCM] Device token: $token');
        cprint('FCM token: $token', event: 'FCM_TOKEN');

        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null && uid.isNotEmpty) {
          await FirebaseDatabase.instance
              .ref()
              .child('profile')
              .child(uid)
              .update({'fcmToken': token});
          cprint('FCM token saved to profile/$uid', event: 'FCM_TOKEN_SAVED');
        }
      }
      return token;
    } catch (e) {
      cprint(e, errorIn: 'getTokenAndPersist');
      return null;
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher_foreground');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    if (Platform.isAndroid) {
      final channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Uygulama bildirimleri',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      try {
        final parts = payload.split('|');
        if (parts.length >= 2) {
          final type = parts[0];
          final id = parts.length > 2 ? parts.sublist(1).join('|') : parts[1];
          handleNotificationNavigation({'type': type, 'id': id});
        }
      } catch (_) {}
    }
  }

  /// Foreground: FCM mesajı gelince heads-up yerel bildirim göster.
  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      cprint('FCM foreground message: ${message.notification?.title}',
          event: 'FCM_FOREGROUND');

      final title = message.notification?.title ?? 'Bildirim';
      final body = message.notification?.body ?? '';
      final data = message.data;

      _showHeadsUpNotification(
        title: title,
        body: body,
        payload: data.isNotEmpty ? _dataToPayload(data) : null,
      );
    });
  }

  String? _dataToPayload(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? '';
    final id = data['id']?.toString() ?? data['toldyaId']?.toString() ?? '';
    if (type.isEmpty) return null;
    return '$type|$id';
  }

  Future<void> _showHeadsUpNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Uygulama bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(0x7FFFFFFF),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Arka plan: Kullanıcı bildirime tıkladığında uygulama açılır ve bu tetiklenir.
  void _setupBackgroundOpenedHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      cprint('FCM opened from background: ${message.data}', event: 'FCM_OPENED');
      if (message.data.isNotEmpty) {
        handleNotificationNavigation(message.data);
      }
    });
  }

  /// Terminated: Uygulama kapalıyken bildirimle açıldığında ilk mesajı işle.
  void _setupInitialMessageHandler() {
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null && message.data.isNotEmpty) {
        cprint('FCM initial message (terminated): ${message.data}',
            event: 'FCM_INITIAL');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          handleNotificationNavigation(message.data);
        });
      }
    });
  }

  /// Payload'taki [data] ile type/id'e göre ilgili sayfaya yönlendirir.
  /// [data]: { "type": "prediction_result" | "new_follower" | ..., "id": "..." }
  static void handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? '';
    final id = data['id']?.toString() ??
        data['toldyaId']?.toString() ??
        data['senderId']?.toString() ??
        '';

    final key = navigatorKey;
    if (key?.currentState == null) return;

    final navigator = key!.currentState!;

    switch (type) {
      case 'prediction_result':
        if (id.isNotEmpty) {
          navigator.pushNamed('/FeedPostDetail/$id');
        }
        break;
      case 'new_follower':
        if (id.isNotEmpty) {
          navigator.pushNamed('/ProfilePage/$id');
        }
        break;
      case 'NotificationType.Mention':
      case 'Mention':
        if (id.isNotEmpty) {
          navigator.pushNamed('/FeedPostDetail/$id');
        }
        break;
      case 'NotificationType.Message':
      case 'Message':
        navigator.pushNamed('/ChatScreenPage');
        break;
      default:
        if (id.isNotEmpty) {
          navigator.pushNamed('/FeedPostDetail/$id');
        }
        break;
    }
  }
}
