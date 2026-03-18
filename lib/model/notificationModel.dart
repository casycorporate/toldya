import 'dart:convert';

import 'package:toldya/model/user.dart';


class NotificationModel {
  String? id;
  String? toldyaKey;
  String? updatedAt;
  String? createdAt;
  String? type;
  Map<String, dynamic>? data;

  NotificationModel({
    this.id,
    this.toldyaKey,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.data,
  });

  NotificationModel.fromJson(String toldyaId, Map<dynamic, dynamic> map) {
    id = toldyaId;
    Map<String, dynamic> data = {};
    if (map.containsKey('data')) {
      data = json.decode(json.encode(map["data"])) as Map<String, dynamic>;
    }
    toldyaKey = toldyaId;
    updatedAt = map["updatedAt"];
    type = map["type"];
    createdAt = map["createdAt"];
    this.data = data;
  }
}

extension NotificationModelHelper on NotificationModel {
  UserModel get user => UserModel.fromJson(data ?? {});

  DateTime? get timeStamp => updatedAt != null || createdAt != null
      ? DateTime.tryParse(updatedAt ?? createdAt ?? '')
      : null;

  /// Standard navigation contract (preferred):
  /// - data.type: "toldya" | "profile" | ...
  /// - data.id: target id
  /// Backward compatible with older fields: toldyaId, parentKey, followerId.
  String get navType {
    final t = (data?['type'] ?? data?['navType'] ?? type)?.toString() ?? '';
    if (t.isNotEmpty) return t;
    return type?.toString() ?? '';
  }

  String get navId {
    final id = data?['id']?.toString();
    if (id != null && id.isNotEmpty) return id;
    final legacyParent = data?['parentKey']?.toString();
    if (legacyParent != null && legacyParent.isNotEmpty) return legacyParent;
    final legacyToldya = data?['toldyaId']?.toString();
    if (legacyToldya != null && legacyToldya.isNotEmpty) return legacyToldya;
    final legacyFollower = data?['followerId']?.toString();
    if (legacyFollower != null && legacyFollower.isNotEmpty) return legacyFollower;
    return toldyaKey?.toString() ?? '';
  }
}
