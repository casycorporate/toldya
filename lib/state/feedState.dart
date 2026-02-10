import 'dart:async';
import 'dart:io';
import 'package:bendemistim/model/userPegModel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/topicMap.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/state/appState.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:path/path.dart' as Path;

class FeedState extends AppState {
  bool isBusy = false;
  Map<String, List<FeedModel>> tweetReplyMap = {};
  FeedModel? _toldyaToReplyModel;

  FeedModel? get toldyaToReplyModel => _toldyaToReplyModel;

  set setToldyaToReply(FeedModel model) {
    _toldyaToReplyModel = model;
  }

  List<FeedModel>? _commentlist;

  List<FeedModel>? _feedlist;
  List<FeedModel>? _filterfeedlist;
  dabase.Query? _feedQuery;
  List<FeedModel>? _tweetDetailModelList;
  List<String>? _userfollowingList;

  List<String>? get followingList => _userfollowingList;

  List<FeedModel>? get tweetDetailModel => _tweetDetailModelList;

  /// `feedlist` always [contain all tweets] fetched from firebase database
  List<FeedModel>? get feedlist {
    if (_feedlist == null) {
      return null;
    } else {
      _feedlist!.sort((a,b)=>(sumOfVote(a.likeList ?? [])+sumOfVote(a.unlikeList ?? [])).compareTo((sumOfVote(b.likeList ?? [])+sumOfVote(b.unlikeList ?? []))));
      return List.from(_feedlist!.reversed);
    }
  }

  /// contain tweet list for home page
  List<FeedModel> getTweetListByFollow(UserModel? userModel) {
    if (userModel == null) {
      return [];
    }

    if (!isBusy && feedlist != null && feedlist!.isNotEmpty) {
      final list = feedlist!.where((x) {
        if (x.parentkey != null &&
            x.childRetwetkey == null &&
            x.user?.userId != userModel.userId) {
          return false;
        }
        final isPublished = x.statu == Statu.statusLive || x.statu == Statu.statusLocked;
        if (!isPublished) return false;
        final fl = userModel.followingList;
        if (fl != null && fl.contains(x.user?.userId)) {
          return true;
        }
        return false;
      }).toList();
      return list;
    }
    return [];
  }

  /// contain tweet list for home page
  List<FeedModel> getTweetList(UserModel? userModel) {
    if (userModel == null) return [];
    if (!isBusy && feedlist != null && feedlist!.isNotEmpty) {
      return feedlist!.where((x) {
        if (x.parentkey != null &&
            x.statu == Statu.statusLive &&
            x.childRetwetkey == null &&
            x.user?.userId != userModel.userId) {
          return false;
        }
        return x.statu == Statu.statusLive || x.statu == Statu.statusLocked;
      }).toList();
    }
    return [];
  }

  List<FeedModel> getTweetListByTopic(UserModel? userModel, List<String> inBlackList, String searchWord, int statu,
      {String topic_val = "Akış"}) {
    if (userModel == null || feedlist == null) return [];
    List<FeedModel> filterList = feedlist!;
    if (!isBusy && feedlist!.isNotEmpty) {
      if (searchWord.isNotEmpty) {
        filterList = filterList.where((x) {
          return (x.description != null &&
                  x.description!
                      .toLowerCase()
                      .contains(searchWord.toLowerCase())) ||
              (x.user?.displayName != null &&
                  x.user!.displayName!
                      .toLowerCase()
                      .contains(searchWord.toLowerCase())) ||
              (x.user?.userName != null &&
                  x.user!.userName!
                      .toLowerCase()
                      .contains(searchWord.toLowerCase()));
        }).toList();
      }
      final list = filterList.where((x) {
        if (x.parentkey != null &&
            x.childRetwetkey == null &&
            x.user?.userId != userModel.userId) {
          return false;
        }
        if (inBlackList.contains(x.user?.userId)) {
          return false;
        }
        final isPublished = x.statu == Statu.statusLive || x.statu == Statu.statusLocked;
        if (statu == Statu.statusLive && isPublished) {
          if (topic_val == topic.gundem) return true;
          if (topic_val == topic.followList) {
            return userModel.followingList?.contains(x.user?.userId) ?? false;
          }
          if (topic_val == topic.favList) {
            return x.favList?.contains(userModel.userId) ?? false;
          }
          return x.topic == topic_val;
        }
        if (x.statu == statu) {
          if (topic_val == topic.gundem) return true;
          if (topic_val == topic.followList) {
            return userModel.followingList?.contains(x.user?.userId) ?? false;
          }
          if (topic_val == topic.favList) {
            return x.favList?.contains(userModel.userId) ?? false;
          }
          return x.topic == topic_val;
        }
        return false;
      }).toList();
      return list;
    }
    return [];
  }

  void getTweetListByTopicAndSearch(UserModel? userModel, String searchWord,
      {String topic_val = "Akış"}) {
    if (userModel == null || feedlist == null) {
      _feedlist = [];
      return;
    }
    List<FeedModel> filterList = feedlist!;
    if (!isBusy && feedlist!.isNotEmpty) {
      if (searchWord.isNotEmpty) {
        filterList = filterList.where((x) {
          return (x.description != null &&
                  x.description!
                      .toLowerCase()
                      .contains(searchWord.toLowerCase())) ||
              (x.user?.displayName != null &&
                  x.user!.displayName!
                      .toLowerCase()
                      .contains(searchWord.toLowerCase())) ||
              (x.user?.userName != null &&
                  x.user!.userName!
                      .toLowerCase()
                      .contains(searchWord.toLowerCase()));
        }).toList();
      }
      final list = filterList.where((x) {
        if (x.parentkey != null &&
            x.childRetwetkey == null &&
            x.user?.userId != userModel.userId) {
          return false;
        }
        final isPublished = x.statu == Statu.statusLive || x.statu == Statu.statusLocked;
        if (isPublished) {
          if (topic_val == topic.gundem) return true;
          if (topic_val == topic.followList) {
            return userModel.followingList?.contains(x.user?.userId) ?? false;
          }
          return x.topic == topic_val;
        }
        return false;
      }).toList();
      _feedlist = list;
    } else {
      _feedlist = [];
    }
  }

  /// set tweet for detail tweet page
  /// Setter call when tweet is tapped to view detail
  /// Add Tweet detail is added in _tweetDetailModelList
  /// It makes `Fwitter` to view nested Tweets
  set setFeedModel(FeedModel model) {
    if (_tweetDetailModelList == null) {
      _tweetDetailModelList = [];
    }

    /// [Skip if any duplicate tweet already present]
    if (_tweetDetailModelList!.length >= 0) {
      _tweetDetailModelList!.add(model);
      cprint(
          "Detail Tweet added. Total Tweet: ${_tweetDetailModelList!.length}");
      notifyListeners();
    }
  }

  /// `remove` last Tweet from tweet detail page stack
  /// Function called when navigating back from a Tweet detail
  /// `_tweetDetailModelList` is map which contain lists of commment Tweet list
  /// After removing Tweet from Tweet detail Page stack its commnets tweet is also removed from `_tweetDetailModelList`
  void removeLastTweetDetail(String tweetKey) {
    if (_tweetDetailModelList != null && _tweetDetailModelList!.length > 0) {
      FeedModel removeTweet =
          _tweetDetailModelList!.lastWhere((x) => x.key == tweetKey);
      _tweetDetailModelList!.remove(removeTweet);
      tweetReplyMap.removeWhere((key, value) => key == tweetKey);
      cprint(
          "Last Tweet removed from stack. Remaining Tweet: ${_tweetDetailModelList!.length}");
    }
  }

  /// [clear all tweets] if any tweet present in tweet detail page or comment tweet
  void clearAllDetailAndReplyToldyaStack() {
    if (_tweetDetailModelList != null) {
      _tweetDetailModelList!.clear();
    }
    tweetReplyMap.clear();
    cprint('Empty tweets from stack');
  }

  /// [Subscribe Tweets] firebase Database
  Future<bool> databaseInit() {
    try {
      if (_feedQuery == null) {
        _feedQuery = kDatabase.child("tweet");
        _feedQuery!.onChildAdded.listen(_onTweetAdded);
        _feedQuery!.onValue.listen(_onTweetChanged);
        _feedQuery!.onChildRemoved.listen(_onTweetRemoved);
      }

      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  /// get [Tweet list] from firebase realtime database
  void getDataFromDatabase() {
    try {
      isBusy = true;
      _feedlist = null;
      notifyListeners();
      kDatabase.child('tweet').once().then((snapshot) {
        _feedlist = <FeedModel>[];
        if (snapshot.snapshot.value != null) {
          final map = Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map);
          map.forEach((key, value) {
            var model = FeedModel.fromJson(Map<String, dynamic>.from(value as Map));
            model.key = key.toString();
            if (model.isValidTweet) {
              _feedlist!.add(model);
            }
          });
          _feedlist!.sort((x, y) => DateTime.parse(x.createdAt ?? '')
              .compareTo(DateTime.parse(y.createdAt ?? '')));
        } else {
          _feedlist = null;
        }
        isBusy = false;
        notifyListeners();
      });
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// get [Tweet Detail] from firebase realtime kDatabase
  /// If model is null then fetch tweet from firebase
  /// [getpostDetailFromDatabase] is used to set prepare Tweetr to display Tweet detail
  /// After getting tweet detail fetch tweet coments from firebase
  void getpostDetailFromDatabase(String postID, {FeedModel? model}) async {
    try {
      FeedModel? _tweetDetail;
      if (model != null) {
        _tweetDetail = model;
        setFeedModel = _tweetDetail;
      } else {
        await kDatabase
            .child('tweet')
            .child(postID)
            .once()
            .then((snapshot) {
          if (snapshot.snapshot.value != null) {
            final map = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
            _tweetDetail = FeedModel.fromJson(map);
            _tweetDetail!.key = snapshot.snapshot.key ?? '';
            setFeedModel = _tweetDetail!;
          }
        });
      }

      if (_tweetDetail != null) {
        _commentlist = <FeedModel>[];
        final replyList = _tweetDetail!.replyTweetKeyList;
        if (replyList != null && replyList.isNotEmpty) {
          for (final x in replyList) {
            if (x == null) continue;
            kDatabase
                .child('tweet')
                .child(x)
                .once()
                .then((snapshot) {
              if (snapshot.snapshot.value != null) {
                var commentmodel = FeedModel.fromJson(Map<String, dynamic>.from(snapshot.snapshot.value as Map));
                var key = snapshot.snapshot.key ?? '';
                commentmodel.key = key;
                if (!_commentlist!.any((c) => c.key == key)) {
                  _commentlist!.add(commentmodel);
                }
              }
              if (x == replyList.last) {
                _commentlist!.sort((a, b) => DateTime.parse(b.createdAt ?? '')
                    .compareTo(DateTime.parse(a.createdAt ?? '')));
                tweetReplyMap.putIfAbsent(postID, () => _commentlist!);
                notifyListeners();
              }
            });
          }
        } else {
          tweetReplyMap.putIfAbsent(postID, () => _commentlist!);
          notifyListeners();
        }
      }
    } catch (error) {
      cprint(error, errorIn: 'getpostDetailFromDatabase');
    }
  }

  /// Fetch `Retweet` model from firebase realtime kDatabase.
  /// Retweet itself  is a type of `Tweet`
  Future<FeedModel?> fetchTweet(String postID) async {
    FeedModel? _tweetDetail;

    if (feedlist != null && feedlist!.any((x) => x.key == postID)) {
      _tweetDetail = feedlist!.firstWhere((x) => x.key == postID);
    } else {
      cprint("Fetched from DB: " + postID);
      final snapshot = await kDatabase.child('tweet').child(postID).once();
      if (snapshot.snapshot.value != null) {
        final map = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        _tweetDetail = FeedModel.fromJson(map);
        _tweetDetail!.key = snapshot.snapshot.key ?? '';
      } else {
        cprint("Fetched null value from  DB");
      }
    }
    return _tweetDetail;
  }

  /// create [New Tweet]
  createToldya(FeedModel model) {
    ///  Create toldya in [Firebase kDatabase]
    isBusy = true;
    notifyListeners();
    try {
      kDatabase.child('tweet').push().set(model.toJson());
    } catch (error) {
      cprint(error, errorIn: 'createToldya');
    }
    isBusy = false;
    notifyListeners();
  }

  ///  It will create tweet in [Firebase kDatabase] just like other normal tweet.
  ///  update retweet count for retweet model
  createReToldya(FeedModel model) {
    try {
      createToldya(model);
      final reply = _toldyaToReplyModel;
      if (reply != null) {
        reply.retweetCount = (reply.retweetCount ?? 0) + 1;
        updateToldya(reply);
      }
    } catch (error) {
      cprint(error, errorIn: 'createReToldya');
    }
  }



  /// [Delete tweet] in Firebase kDatabase
  /// Remove Tweet if present in home page Tweet list
  /// Remove Tweet if present in Tweet detail page or in comment
  deleteToldya(String toldyaId, ToldyaType type, {String? parentkey}) {
    try {
      /// Delete tweet if it is in nested tweet detail page
      kDatabase.child('tweet').child(toldyaId).remove().then((_) {
        if (type == ToldyaType.Detail &&
            _tweetDetailModelList != null &&
            _tweetDetailModelList!.length > 0) {
          _tweetDetailModelList!.removeWhere((x) => x.key == toldyaId);
          if (_tweetDetailModelList!.isEmpty) {
            _tweetDetailModelList = null;
          }

          cprint('Tweet deleted from nested tweet detail page tweet');
        }
      });
    } catch (error) {
      cprint(error, errorIn: 'deleteToldya');
    }
  }

  /// upload [file] to firebase storage and return its  path url
  Future<String?> uploadFile(File file) async {
    try {
      isBusy = true;
      notifyListeners();
      var storageReference = FirebaseStorage.instance
          .ref()
          .child("tweetImage")
          .child(Path.basename(file.path));
      await storageReference.putFile(file);

      var url = await storageReference.getDownloadURL();
      return url;
    } catch (error) {
      cprint(error, errorIn: 'uploadFile');
      return null;
    }
  }

  /// [Delete file] from firebase storage
  Future<void> deleteFile(String url, String baseUrl) async {
    try {
      var filePath = url.split(".com/o/")[1];
      filePath = filePath.replaceAll(new RegExp(r'%2F'), '/');
      filePath = filePath.replaceAll(new RegExp(r'(\?alt).*'), '');
      //  filePath = filePath.replaceAll('tweetImage/', '');
      cprint('[Path]' + filePath);
      var storageReference = FirebaseStorage.instance.ref();
      await storageReference.child(filePath).delete().catchError((val) {
        cprint('[Error]' + val);
      }).then((_) {
        cprint('[Sucess] Image deleted');
      });
    } catch (error) {
      cprint(error, errorIn: 'deleteFile');
    }
  }

  /// [update] tweet
  updateToldya(FeedModel model) async {
    await kDatabase.child('tweet').child(model.key ?? '').set(model.toJson());
  }

  /// Pari-Mutuel: Kazananlara token dağıtımı
  /// Kazanç = (Kişisel Bahis / Kazanan Tarafın Toplam Bahsi) × (Toplam Havuz × (1 - komisyon))
  Future<void> distributeWinnings(FeedModel model, AuthState authState) async {
    if (model.distributionDone == true) return;
    final winningList = model.feedResult == FeedResult.feedResultlike
        ? (model.likeList ?? [])
        : (model.unlikeList ?? []);
    if (winningList.isEmpty) return;
    final totalPool = sumOfVote(model.likeList ?? []) + sumOfVote(model.unlikeList ?? []);
    if (totalPool == 0) return;
    final distributablePool = (totalPool * (1 - AppIcon.commissionRate)).round();
    final winningTotal = sumOfVote(winningList);
    if (winningTotal == 0) return;
    for (final element in winningList) {
      final userPeg = element.pegCount ?? 0;
      if (userPeg <= 0) continue;
      final payout = ((userPeg / winningTotal) * distributablePool).round();
      final user = await authState.getuserDetail(element.userId ?? '');
      if (user != null) {
        user.pegCount = (user.pegCount ?? 0) + payout;
        authState.createUser(user);
      }
    }
    if (model.userId != null) {
      final predictor = await authState.getuserDetail(model.userId!);
      if (predictor != null) {
        predictor.predictorScore = (predictor.predictorScore ?? 0) + 1;
        authState.createUser(predictor);
      }
    }
    model.distributionDone = true;
    await updateToldya(model);
  }

  /// Add/Remove like on a Tweet
  /// [postId] is tweet id, [userId] is user's id who like/unlike Tweet
  addLikeToToldya(FeedModel model, String userId, int count) {
    try {
      // if (tweet.likeList != null &&
      //     tweet.likeList.length > 0 &&
      //     tweet.likeList.any((id) => id == userId)) {
      //   // If user wants to undo/remove his like on tweet
      //   tweet.likeList.removeWhere((id) => id == userId);
      //   tweet.likeCount -= 1;
      // } else {
      //   // If user like Tweet
      //   if (tweet.likeList == null) {
      //     tweet.likeList = [];
      //   }
      //   tweet.likeList.add(userId);
      //   tweet.likeCount += count;
      // }

      model.likeList ??= [];
      final likeList = model.likeList!;
      final idx = likeList.indexWhere((element) => element.userId == userId);
      if (idx >= 0) {
        final el = likeList[idx];
        el.pegCount = (el.pegCount ?? 0) + count;
      } else {
        likeList.add(UserPegModel(userId: userId, pegCount: count));
      }
      kDatabase
          .child('tweet')
          .child(model.key ?? '')
          .child('likeList')
          .set(likeList.map((e) => e.toJson()).toList());
      kDatabase
          .child('tweet')
          .child(model.key ?? '')
          .child('likeCount')
          .set(model.likeCount);

      kDatabase.child('notification').child(model.userId ?? '').child(model.key ?? '').set({
        'type': likeList.isEmpty
            ? null
            : NotificationType.Like.toString(),
        'updatedAt': likeList.isEmpty
            ? null
            : DateTime.now().toUtc().toString(),
      });
    } catch (error) {
      cprint(error, errorIn: 'addLikeToToldya');
    }
  }

  /// Add/Remove unlike on a Toldya
  addunLikeToToldya(FeedModel model, String userId, int count) {
    try {
      // if (tweet.unlikeList != null &&
      //     tweet.unlikeList.length > 0 &&
      //     tweet.unlikeList.any((id) => id == userId)) {
      //   // If user wants to undo/remove his like on tweet
      //   tweet.unlikeList.removeWhere((id) => id == userId);
      //   tweet.unlikeCount -= 1;
      // } else {
      //   // If user like Tweet
      //   if (tweet.unlikeList == null) {
      //     tweet.unlikeList = [];
      //   }
      //   tweet.unlikeList.add(userId);
      //   tweet.unlikeCount += count;
      // }

      model.unlikeList ??= [];
      final unlikeList = model.unlikeList!;
      final idx = unlikeList.indexWhere((element) => element.userId == userId);
      if (idx >= 0) {
        final el = unlikeList[idx];
        el.pegCount = (el.pegCount ?? 0) + count;
      } else {
        unlikeList.add(UserPegModel(userId: userId, pegCount: count));
      }
      model.unlikeCount = (model.unlikeCount ?? 0) + count;
      kDatabase
          .child('tweet')
          .child(model.key ?? '')
          .child('unlikeList')
          .set(unlikeList.map((e) => e.toJson()).toList());
      kDatabase
          .child('tweet')
          .child(model.key ?? '')
          .child('unlikeCount')
          .set(model.unlikeCount);

      kDatabase.child('notification').child(model.userId ?? '').child(model.key ?? '').set({
        'type': unlikeList.isEmpty
            ? null
            : NotificationType.UnLike.toString(),
        'updatedAt': unlikeList.isEmpty
            ? null
            : DateTime.now().toUtc().toString(),
      });
    } catch (error) {
      cprint(error, errorIn: 'addunLikeToToldya');
    }
  }

  /// Bahis işlemini backend (placeBet Callable) üzerinden yapar; limit ve bakiye kontrolü sunucuda.
  /// Başarıda authState bakiye güncellenir ve yerel feed listesi güncellenir.
  Future<void> placeBet(AuthState authState, FeedModel model, String userId, int amount, int commentFlag) async {
    final callable = FirebaseFunctions.instance.httpsCallable("placeBet");
    final side = commentFlag == 0 ? 1 : 2; // 1 = Evet (like), 2 = Hayır (unlike)
    final result = await callable.call(<String, dynamic>{
      "tweetId": model.key,
      "side": side,
      "amount": amount,
    });
    final data = result.data as Map<dynamic, dynamic>?;
    if (data == null || data["ok"] != true) {
      throw FirebaseFunctionsException(
        code: "unknown",
        message: "Bahis kabul edilemedi.",
      );
    }
    final newBalance = data["newBalance"] as int? ?? 0;
    final newStashBalance = data["newStashBalance"] as int? ?? 0;
    authState.updateBalanceFromBet(newBalance, newStashBalance);
    _updateLocalFeedModelAfterBet(model.key, userId, amount, commentFlag == 0);
    notifyListeners();
  }

  void _updateLocalFeedModelAfterBet(String? tweetKey, String userId, int amount, bool isLike) {
    if (tweetKey == null || _feedlist == null) return;
    for (final f in _feedlist!) {
      if (f.key == tweetKey) {
        if (isLike) {
          f.likeList ??= [];
          final idx = f.likeList!.indexWhere((e) => e.userId == userId);
          if (idx >= 0) {
            f.likeList![idx].pegCount = (f.likeList![idx].pegCount) + amount;
          } else {
            f.likeList!.add(UserPegModel(userId: userId, pegCount: amount));
          }
        } else {
          f.unlikeList ??= [];
          final idx = f.unlikeList!.indexWhere((e) => e.userId == userId);
          if (idx >= 0) {
            f.unlikeList![idx].pegCount = (f.unlikeList![idx].pegCount) + amount;
          } else {
            f.unlikeList!.add(UserPegModel(userId: userId, pegCount: amount));
          }
        }
        break;
      }
    }
  }

  addDisputeToToldya(FeedModel model, String userId) {
    try {
      model.disputeUserIds ??= [];
      if (model.disputeUserIds!.contains(userId)) return;
      model.disputeUserIds!.add(userId);
      kDatabase
          .child('tweet')
          .child(model.key ?? '')
          .child('disputeUserIds')
          .set(model.disputeUserIds);
    } catch (error) {
      cprint(error, errorIn: 'addDisputeToToldya');
    }
  }

  addReportToToldya(FeedModel model, String userId) {
    try {
      model.reportList ??= [];
      if (model.reportList!.any((id) => id == userId)) {
        model.reportList!.removeWhere((id) => id == userId);
      } else {
        model.reportList!.add(userId);
      }

      kDatabase
          .child('tweet')
          .child(model.key ?? '')
          .child('reportList')
          .set(model.reportList);
    } catch (error) {
      cprint(error, errorIn: 'addReportToToldya');
    }
  }

  addFavToToldya(FeedModel model, String userId) {
    try {
      model.favList ??= [];
      if (model.favList!.any((id) => id == userId)) {
        model.favList!.removeWhere((id) => id == userId);
      } else {
        model.favList!.add(userId);
      }

      kDatabase
          .child('tweet')
          .child(model.key ?? '')
          .child('favList')
          .set(model.favList);
    } catch (error) {
      cprint(error, errorIn: 'addFavToToldya');
    }
  }

  /// Add [new comment tweet] to any tweet
  /// Comment is a Tweet itself
  addcommentToPost(FeedModel replyTweet) {
    try {
      isBusy = true;
      notifyListeners();
      final toReply = _toldyaToReplyModel;
      final feedlist = _feedlist;
      if (toReply != null &&
          toReply.key != null &&
          feedlist != null &&
          feedlist.isNotEmpty &&
          feedlist.any((x) => x.key == toReply.key)) {
        FeedModel parentToldya = feedlist.firstWhere((x) => x.key == toReply.key);
        var json = replyTweet.toJson();
        kDatabase.child('tweet').push().set(json).then((value) {
          final lastKey = feedlist.isNotEmpty ? feedlist.last.key : null;
          if (lastKey != null) {
            (parentToldya.replyTweetKeyList ??= []).add(lastKey);
          }
          updateToldya(parentToldya);
        });
      }
    } catch (error) {
      cprint(error, errorIn: 'addcommentToPost');
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when any tweet changes or update
  /// When any tweet changes it update it in UI
  /// No matter if Tweet is in home page or in detail page or in comment section.
  _onTweetChanged(DatabaseEvent event) {
    final value = event.snapshot.value;
    if (value == null) return;
    final map = Map<String, dynamic>.from(value as Map);
    var model = FeedModel.fromJson(map);
    model.key = event.snapshot.key ?? '';
    final feedlist = _feedlist;
    if (feedlist != null && feedlist.any((x) => x.key == model.key)) {
      var oldEntry = feedlist.lastWhere((entry) => entry.key == event.snapshot.key);
      final idx = feedlist.indexOf(oldEntry);
      if (idx >= 0) feedlist[idx] = model;
    }

    final detailList = _tweetDetailModelList;
    if (detailList != null && detailList.isNotEmpty) {
      if (detailList.any((x) => x.key == model.key)) {
        var oldEntry = detailList.lastWhere((entry) => entry.key == event.snapshot.key);
        final idx = detailList.indexOf(oldEntry);
        if (idx >= 0) detailList[idx] = model;
      }
      final parentKey = model.parentkey;
      if (parentKey != null) {
        var list = tweetReplyMap[parentKey];
        if (list != null && list.isNotEmpty) {
          final idx = list.indexWhere((x) => x.key == model.key);
          if (idx >= 0) list[idx] = model;
        } else {
          tweetReplyMap[parentKey] = [model];
        }
      }
    }
    if (event.snapshot != null) {
      cprint('Tweet updated');
      isBusy = false;
      notifyListeners();
    }
  }

  /// Trigger when new tweet added
  /// It will add new Tweet in home page list.
  /// IF Tweet is comment it will be added in comment section too.
  _onTweetAdded(DatabaseEvent event) {
    final value = event.snapshot.value;
    if (value == null) return;
    final map = Map<String, dynamic>.from(value as Map);
    FeedModel tweet = FeedModel.fromJson(map);
    tweet.key = event.snapshot.key ?? '';

    _onCommentAdded(tweet);
    _feedlist ??= <FeedModel>[];
    if ((_feedlist!.isEmpty || _feedlist!.any((x) => x.key != tweet.key)) &&
        tweet.isValidTweet) {
      _feedlist!.add(tweet);
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when comment tweet added
  /// Check if Tweet is a comment
  /// If Yes it will add tweet in comment list.
  /// add [new tweet] comment to comment list
  _onCommentAdded(FeedModel tweet) {
    if (tweet.childRetwetkey != null) return;
    final parentKey = tweet.parentkey;
    if (parentKey != null) {
      (tweetReplyMap[parentKey] ??= []).add(tweet);
      cprint('Comment Added');
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when Tweet `Deleted`
  /// It removed Tweet from home page list, Tweet detail page list and from comment section if present
  _onTweetRemoved(DatabaseEvent event) async {
    final value = event.snapshot.value;
    if (value == null) return;
    final map = Map<String, dynamic>.from(value as Map);
    FeedModel tweet = FeedModel.fromJson(map);
    tweet.key = event.snapshot.key ?? '';
    var tweetId = tweet.key ?? '';
    var parentkey = tweet.parentkey;

    ///  Delete tweet in [Home Page]
    try {
      FeedModel? deletedTweet;
      final feedlist = _feedlist;
      if (feedlist != null &&
          feedlist.isNotEmpty &&
          tweetId.isNotEmpty &&
          feedlist.any((x) => x.key == tweetId)) {
        /// Delete tweet if it is in home page tweet.
        deletedTweet = feedlist.firstWhere((x) => x.key == tweetId);
        _feedlist!.remove(deletedTweet);

        final dpk = deletedTweet.parentkey;
        if (dpk != null &&
            _feedlist!.isNotEmpty &&
            _feedlist!.any((x) => x.key == dpk)) {
          // Decrease parent Tweet comment count and update
          var parentModel = _feedlist!.firstWhere((x) => x.key == dpk);
          (parentModel.replyTweetKeyList ??= []).remove(deletedTweet.key);
          parentModel.commentCount =
              (parentModel.replyTweetKeyList ?? []).length;
          updateToldya(parentModel);
        }
        if (_feedlist!.isEmpty) {
          _feedlist = null;
        }
        cprint('Tweet deleted from home page tweet list');
      }

      /// [Delete tweet] if it is in nested tweet detail comment section page
      if (parentkey != null &&
          parentkey.isNotEmpty &&
          tweetReplyMap.isNotEmpty &&
          tweetReplyMap.containsKey(parentkey)) {
        final replyList = tweetReplyMap[parentkey];
        if (replyList != null &&
            replyList.isNotEmpty &&
            replyList.any((x) => x.key == tweetId)) {
          deletedTweet ??=
              replyList.firstWhere((x) => x.key == tweetId);
          tweetReplyMap[parentkey]!.remove(deletedTweet);
          if (tweetReplyMap[parentkey]!.isEmpty) {
            tweetReplyMap.remove(parentkey);
          }

          if (_tweetDetailModelList != null &&
              _tweetDetailModelList!.isNotEmpty &&
              _tweetDetailModelList!.any((x) => x.key == parentkey)) {
            var parentModel =
                _tweetDetailModelList!.firstWhere((x) => x.key == parentkey);
            (parentModel.replyTweetKeyList ??= []).remove(deletedTweet.key);
            parentModel.commentCount =
                (parentModel.replyTweetKeyList ?? []).length;
            cprint('Parent tweet comment count updated on child tweet removal');
            updateToldya(parentModel);
          }

          cprint('Tweet deleted from nested tweet detail comment section');
        }
      }

      if (deletedTweet == null) return;

      /// Delete tweet image from firebase storage if exist.
      if (deletedTweet.imagePath != null &&
          deletedTweet.imagePath!.isNotEmpty) {
        deleteFile(deletedTweet.imagePath!, 'tweetImage');
      }

      /// If a retweet is deleted then retweetCount of original tweet should be decrease by 1.
      if (deletedTweet.childRetwetkey != null) {
        await fetchTweet(deletedTweet.childRetwetkey!).then((retweetModel) {
          if (retweetModel == null) {
            return;
          }
          if ((retweetModel.retweetCount ?? 0) > 0) {
            retweetModel.retweetCount = (retweetModel.retweetCount ?? 0) - 1;
          }
          updateToldya(retweetModel);
        });
      }

      /// Delete notification related to deleted Tweet.
      if ((deletedTweet.likeCount ?? 0) > 0 &&
          tweet.userId != null &&
          tweet.key != null) {
        kDatabase
            .child('notification')
            .child(tweet.userId!)
            .child(tweet.key!)
            .remove();
      }
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: '_onTweetRemoved');
    }
  }
}
