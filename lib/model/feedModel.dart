import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/model/userPegModel.dart';

class FeedModel {
  String? key;
  String? parentkey;
  String? childRetwetkey;
  String? description;
  String? userId;
  int? likeCount;
  int? statu;
  int? feedResult;
  List<UserPegModel>? likeList;
  int? unlikeCount;
  List<UserPegModel>? unlikeList;
  int? commentCount;
  int? retweetCount;
  String? createdAt;
  /// Kapanış zamanı: Bahislerin kabul edilmeyeceği an (lock-in)
  String? endDate;
  /// Sonuçlanma zamanı: Olayın gerçekleşeceği ve sonucun girileceği an
  String? resolutionDate;
  String? imagePath;
  String? topic;
  List<String>? tags;
  List<String>? replyTweetKeyList;
  UserModel? user;
  List<String>? reportList;
  List<String>? favList;
  /// Kanıt kaynağı (Oracle): Bahsin neye göre sonuçlanacağı
  String? oracleSource;
  /// API URL - otomatik sonuç için (opsiyonel)
  String? oracleApiUrl;
  /// Tahminci teminatı (sembolik token)
  int? collateralAmount;
  /// İtiraz eden kullanıcı ID'leri
  List<String>? disputeUserIds;
  /// Dağıtım yapıldı mı (Pari-Mutuel ödeme tamamlandı mı)
  bool? distributionDone;
  /// AI moderasyon gerekçesi (onay veya red nedeni)
  String? aiModerationReason;

  FeedModel({this.key,
    this.description,
    this.userId,
    this.likeCount,
    this.unlikeCount,
    this.unlikeList,
    this.commentCount,
    this.retweetCount,
    this.createdAt,
    this.endDate,
    this.imagePath,
    this.likeList,
    this.tags,
    this.reportList,
    this.favList,
    this.user,
    this.topic,
    this.replyTweetKeyList,
    this.parentkey,
    this.statu,
    this.feedResult,
    this.childRetwetkey,
    this.resolutionDate,
    this.oracleSource,
    this.oracleApiUrl,
    this.collateralAmount,
    this.disputeUserIds,
    this.distributionDone,
    this.aiModerationReason});

  toJson() {
    return {
      "userId": userId,
      "description": description,
      "likeCount": likeCount,
      "unlikeCount": unlikeCount,
      "commentCount": commentCount ?? 0,
      "retweetCount": retweetCount ?? 0,
      "createdAt": createdAt,
      "endDate": endDate,
      "imagePath": imagePath,
      "likeList": likeList?.map((e) => e.toJson()).toList() ?? [],
      "unlikeList": unlikeList?.map((e) => e.toJson()).toList() ?? [],
      "tags": tags,
      "reportList": reportList,
      "favList": favList,
      "topic": topic,
      "replyTweetKeyList": replyTweetKeyList,
      "user": user?.toJson(),
      "parentkey": parentkey,
      "childRetwetkey": childRetwetkey,
      "statu": statu,
      "feedResult": feedResult,
      "resolutionDate": resolutionDate,
      "oracleSource": oracleSource,
      "oracleApiUrl": oracleApiUrl,
      "collateralAmount": collateralAmount,
      "disputeUserIds": disputeUserIds,
      "distributionDone": distributionDone ?? false,
      "aiModerationReason": aiModerationReason
    };
  }

  FeedModel.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    description = map['description'];
    userId = map['userId'];
    //  name = map['name'];
    //  profilePic = map['profilePic'];
    likeCount = map['likeCount'] ?? 0;
    unlikeCount = map['unlikeCount'] ?? 0;
    commentCount = map['commentCount'];
    retweetCount = map["retweetCount"] ?? 0;
    imagePath = map['imagePath'];
    createdAt = map['createdAt'];
    endDate = map['endDate'];
    imagePath = map['imagePath'];
    topic = map['topic'];
    statu = map['statu'];
    feedResult = map['feedResult'];
    resolutionDate = map['resolutionDate'];
    oracleSource = map['oracleSource'];
    oracleApiUrl = map['oracleApiUrl'];
    collateralAmount = map['collateralAmount'];
    distributionDone = map['distributionDone'] ?? false;
    aiModerationReason = map['aiModerationReason']?.toString();
    if (map['disputeUserIds'] != null) {
      disputeUserIds = <String>[];
      for (final value in map['disputeUserIds'] as Iterable) {
        disputeUserIds!.add(value.toString());
      }
    } else {
      disputeUserIds = [];
    }
    //  username = map['username'];
    user = map['user'] != null ? UserModel.fromJson(map['user'] as Map<dynamic, dynamic>) : null;
    parentkey = map['parentkey'];
    childRetwetkey = map['childRetwetkey'];
    if (map['tags'] != null) {
      tags = <String>[];
      (map['tags'] as Iterable).forEach((value) {
        tags!.add(value.toString());
      });
    }
    //reportlist
    if (map['reportList'] != null) {
      reportList = <String>[];
      for (final value in map['reportList'] as Iterable) {
        reportList!.add(value.toString());
      }
    } else {
      reportList = [];
    }
    //favList
    if (map['favList'] != null) {
      favList = <String>[];
      for (final value in map['favList'] as Iterable) {
        favList!.add(value.toString());
      }
    } else {
      favList = [];
    }
    if (map["likeList"] != null) {
      likeList = <UserPegModel>[];
      final list = map['likeList'];

      if (list is List) {
        for (final value in list) {
          if (value is Map) {
            likeList!.add(UserPegModel.fromJson(value));
          }
        }
      } else if (list is Map) {
        list.forEach((key, value) {
          if (value is Map) {
            likeList!.add(UserPegModel.fromJson(value));
          }
        });
      }
    } else {
      likeList = [];
      likeCount = 0;
    }
    if (map["unlikeList"] != null) {
      unlikeList = <UserPegModel>[];
      final list = map['unlikeList'];

      if (list is List) {
        for (final value in list) {
          if (value is Map) {
            unlikeList!.add(UserPegModel.fromJson(value));
          }
        }
      } else if (list is Map) {
        list.forEach((key, value) {
          if (value is Map) {
            unlikeList!.add(UserPegModel.fromJson(value));
          }
        });
      }
    } else {
      unlikeList = [];
      unlikeCount = 0;
    }

    if (map['replyTweetKeyList'] != null) {
      replyTweetKeyList = <String>[];
      for (final value in map['replyTweetKeyList'] as Iterable) {
        replyTweetKeyList!.add(value.toString());
      }
      commentCount = replyTweetKeyList!.length;
    } else {
      replyTweetKeyList = [];
      commentCount = 0;
    }
  }

  bool get isValidTweet {
    final un = this.user?.userName;
    if (un != null && un.isNotEmpty) {
      return true;
    }
    print("Invalid Tweet found. Id:- $key");
    return false;
  }
}
