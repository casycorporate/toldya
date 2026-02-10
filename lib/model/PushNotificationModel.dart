import 'dart:convert';

class PushNotificationModel {
  PushNotificationModel({
    this.id = '',
    this.type = '',
    this.receiverId = '',
    this.senderId = '',
    this.title = '',
    this.body = '',
    this.tweetId = '',
  });

  final String id;
  final String type;
  final String receiverId;
  final String senderId;
  final String title;
  final String body;
  final String tweetId;

  factory PushNotificationModel.fromRawJson(String str) =>
      PushNotificationModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PushNotificationModel.fromJson(Map<dynamic, dynamic> json) =>
      PushNotificationModel(
        id: json["id"]?.toString() ?? '',
        type: json["type"]?.toString() ?? '',
        receiverId: json["receiverId"]?.toString() ?? '',
        senderId: json["senderId"]?.toString() ?? '',
        title: json["title"]?.toString() ?? '',
        body: json["body"]?.toString() ?? '',
        tweetId: json["tweetId"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "receiverId": receiverId,
    "senderId": senderId,
    "title": title,
    "body": body,
    "tweetId": tweetId,
  };
}

class Notification {
  Notification({
    this.body = '',
    this.title = '',
  });

  final String body;
  final String title;

  factory Notification.fromRawJson(String str) =>
      Notification.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Notification.fromJson(Map<dynamic, dynamic> json) => Notification(
    body: json["body"]?.toString() ?? '',
    title: json["title"]?.toString() ?? '',
  );

  Map<dynamic, dynamic> toJson() => {
    "body": body,
    "title": title,
  };
}