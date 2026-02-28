import 'dart:async';
import 'dart:convert';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;

class FeedState extends AppState {
  bool isBusy = false;
  Map<String, List<FeedModel>> toldyaReplyMap = {};
  FeedModel? _toldyaToReplyModel;

  FeedModel? get toldyaToReplyModel => _toldyaToReplyModel;

  set setToldyaToReply(FeedModel model) {
    _toldyaToReplyModel = model;
  }

  List<FeedModel>? _commentlist;

  List<FeedModel>? _feedlist;
  List<FeedModel>? _filterfeedlist;
  dabase.Query? _feedQuery;
  List<FeedModel>? _toldyaDetailModelList;
  List<String>? _userfollowingList;

  List<String>? get followingList => _userfollowingList;

  List<FeedModel>? get toldyaDetailModel => _toldyaDetailModelList;

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
  List<FeedModel> getToldyaListByFollow(UserModel? userModel) {
    if (userModel == null) {
      return [];
    }

    if (!isBusy && feedlist != null && feedlist!.isNotEmpty) {
      final list = feedlist!.where((x) {
        if (x.parentkey != null &&
            x.childRetoldyaKey == null &&
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
  List<FeedModel> getToldyaList(UserModel? userModel) {
    if (userModel == null) return [];
    if (!isBusy && feedlist != null && feedlist!.isNotEmpty) {
      return feedlist!.where((x) {
        if (x.parentkey != null &&
            x.statu == Statu.statusLive &&
            x.childRetoldyaKey == null &&
            x.user?.userId != userModel.userId) {
          return false;
        }
        return x.statu == Statu.statusLive || x.statu == Statu.statusLocked;
      }).toList();
    }
    return [];
  }

  List<FeedModel> getToldyaListByTopic(UserModel? userModel, List<String> inBlackList, String searchWord, int statu,
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
            x.childRetoldyaKey == null &&
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

  void getToldyaListByTopicAndSearch(UserModel? userModel, String searchWord,
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
            x.childRetoldyaKey == null &&
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
  /// Add Tweet detail is added in _toldyaDetailModelList
  /// It makes `Fwitter` to view nested Tweets
  set setFeedModel(FeedModel model) {
    if (_toldyaDetailModelList == null) {
      _toldyaDetailModelList = [];
    }

    /// [Skip if any duplicate tweet already present]
    if (_toldyaDetailModelList!.length >= 0) {
      _toldyaDetailModelList!.add(model);
      cprint(
          "Detail Tweet added. Total Tweet: ${_toldyaDetailModelList!.length}");
      notifyListeners();
    }
  }

  /// `remove` last Tweet from tweet detail page stack
  /// Function called when navigating back from a Tweet detail
  /// `_toldyaDetailModelList` is map which contain lists of commment Tweet list
  /// After removing Tweet from Tweet detail Page stack its commnets tweet is also removed from `_toldyaDetailModelList`
  void removeLastToldyaDetail(String toldyaKey) {
    if (_toldyaDetailModelList != null && _toldyaDetailModelList!.length > 0) {
      FeedModel removeToldya =
          _toldyaDetailModelList!.lastWhere((x) => x.key == toldyaKey);
      _toldyaDetailModelList!.remove(removeToldya);
      toldyaReplyMap.removeWhere((key, value) => key == toldyaKey);
      cprint(
          "Last Tweet removed from stack. Remaining Tweet: ${_toldyaDetailModelList!.length}");
    }
  }

  /// [clear all tweets] if any tweet present in tweet detail page or comment tweet
  void clearAllDetailAndReplyToldyaStack() {
    if (_toldyaDetailModelList != null) {
      _toldyaDetailModelList!.clear();
    }
    toldyaReplyMap.clear();
    cprint('Empty tweets from stack');
  }

  /// [Subscribe Tweets] firebase Database
  Future<bool> databaseInit() {
    try {
      if (_feedQuery == null) {
        _feedQuery = kDatabase.child("toldya");
        _feedQuery!.onChildAdded.listen(_onToldyaAdded);
        _feedQuery!.onValue.listen(_onToldyaChanged);
        _feedQuery!.onChildRemoved.listen(_onToldyaRemoved);
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
      kDatabase.child('toldya').once().then((snapshot) {
        _feedlist = <FeedModel>[];
        if (snapshot.snapshot.value != null) {
          final map = Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map);
          map.forEach((key, value) {
            var model = FeedModel.fromJson(Map<String, dynamic>.from(value as Map));
            model.key = key.toString();
            if (model.isValidToldya) {
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
      FeedModel? _toldyaDetail;
      if (model != null) {
        _toldyaDetail = model;
        setFeedModel = _toldyaDetail;
      } else {
        await kDatabase
            .child('toldya')
            .child(postID)
            .once()
            .then((snapshot) {
          if (snapshot.snapshot.value != null) {
            final map = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
            _toldyaDetail = FeedModel.fromJson(map);
            _toldyaDetail!.key = snapshot.snapshot.key ?? '';
            setFeedModel = _toldyaDetail!;
          }
        });
      }

      if (_toldyaDetail != null) {
        _commentlist = <FeedModel>[];
        final replyList = _toldyaDetail!.replyToldyaKeyList;
        if (replyList != null && replyList.isNotEmpty) {
          for (final x in replyList) {
            if (x == null) continue;
            kDatabase
                .child('toldya')
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
                toldyaReplyMap.putIfAbsent(postID, () => _commentlist!);
                notifyListeners();
              }
            });
          }
        } else {
          toldyaReplyMap.putIfAbsent(postID, () => _commentlist!);
          notifyListeners();
        }
      }
    } catch (error) {
      cprint(error, errorIn: 'getpostDetailFromDatabase');
    }
  }

  /// Fetch `Retweet` model from firebase realtime kDatabase.
  /// Retweet itself  is a type of `Tweet`
  Future<FeedModel?> fetchToldya(String postID) async {
    FeedModel? _toldyaDetail;

    if (feedlist != null && feedlist!.any((x) => x.key == postID)) {
      _toldyaDetail = feedlist!.firstWhere((x) => x.key == postID);
    } else {
      cprint("Fetched from DB: " + postID);
      final snapshot = await kDatabase.child('toldya').child(postID).once();
      if (snapshot.snapshot.value != null) {
        final map = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        _toldyaDetail = FeedModel.fromJson(map);
        _toldyaDetail!.key = snapshot.snapshot.key ?? '';
      } else {
        cprint("Fetched null value from  DB");
      }
    }
    return _toldyaDetail;
  }

  /// create [New Tweet]
  createToldya(FeedModel model) {
    ///  Create toldya in [Firebase kDatabase]
    isBusy = true;
    notifyListeners();
    try {
      kDatabase.child('toldya').push().set(model.toJson());
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
        reply.retoldyaCount = (reply.retoldyaCount ?? 0) + 1;
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
      kDatabase.child('toldya').child(toldyaId).remove().then((_) {
        if (type == ToldyaType.Detail &&
            _toldyaDetailModelList != null &&
            _toldyaDetailModelList!.length > 0) {
          _toldyaDetailModelList!.removeWhere((x) => x.key == toldyaId);
          if (_toldyaDetailModelList!.isEmpty) {
            _toldyaDetailModelList = null;
          }

          cprint('Toldya deleted from nested toldya detail page');
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
          .child("toldyaImage")
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
    await kDatabase.child('toldya').child(model.key ?? '').set(model.toJson());
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
          .child('toldya')
          .child(model.key ?? '')
          .child('likeList')
          .set(likeList.map((e) => e.toJson()).toList());
      kDatabase
          .child('toldya')
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
          .child('toldya')
          .child(model.key ?? '')
          .child('unlikeList')
          .set(unlikeList.map((e) => e.toJson()).toList());
      kDatabase
          .child('toldya')
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
    debugPrint('[placeBet] Başlatılıyor...');
    debugPrint('[placeBet] toldyaId: ${model.key}');
    debugPrint('[placeBet] side: ${commentFlag == 0 ? 1 : 2} (commentFlag: $commentFlag)');
    debugPrint('[placeBet] amount: $amount');
    debugPrint('[placeBet] userId: $userId');
    
    // Authentication kontrolü
    final currentUser = authState.user;
    if (currentUser == null) {
      debugPrint('[placeBet] HATA: Kullanıcı giriş yapmamış!');
      throw FirebaseFunctionsException(
        code: "unauthenticated",
        message: "Giriş yapmanız gerekiyor.",
      );
    }
    debugPrint('[placeBet] Kullanıcı doğrulandı: ${currentUser.uid}');
    
    // Authentication token'ı kontrol et ve yenile
    try {
      debugPrint('[placeBet] Authentication token kontrol ediliyor...');
      final tokenResult = await currentUser.getIdTokenResult();
      debugPrint('[placeBet] Token geçerli: ${tokenResult.token?.isNotEmpty ?? false}');
      debugPrint('[placeBet] Token expiration: ${tokenResult.expirationTime}');
      
      // Token'ı yenile (eğer gerekiyorsa)
      await currentUser.getIdToken(true); // Force refresh
      debugPrint('[placeBet] Token yenilendi');
    } catch (tokenError) {
      debugPrint('[placeBet] Token hatası (devam ediliyor): $tokenError');
      // Token hatası olsa bile devam et, Cloud Functions kendi token'ını alacak
    }
    
    try {
      final side = commentFlag == 0 ? 1 : 2; // 1 = Evet (like), 2 = Hayır (unlike)
      final idToken = await currentUser.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw FirebaseFunctionsException(
          code: "unauthenticated",
          message: "Oturum bilgisi alınamadı. Lütfen tekrar giriş yapın.",
        );
      }

      // Doğrudan HTTP ile çağır (Firebase SDK callable GMS broker hatası bypass)
      final uri = Uri.parse('${AppIcon.cloudFunctionsBaseUrl}/placeBet');
      debugPrint('[placeBet] HTTP çağrılıyor: $uri');
      debugPrint('[placeBet] Parametreler: toldyaId=${model.key}, side=$side, amount=$amount');

      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'data': {
                'toldyaId': model.key,
                'side': side,
                'amount': amount,
              },
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('[placeBet] TIMEOUT: İstek zaman aşımına uğradı');
              throw FirebaseFunctionsException(
                code: "deadline-exceeded",
                message: "İstek zaman aşımına uğradı. Lütfen tekrar deneyin.",
              );
            },
          );

      final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      if (body.containsKey('error')) {
        final err = body['error'] as Map<String, dynamic>? ?? {};
        final code = (err['status'] as String?)?.toLowerCase().replaceAll('_', '-') ?? 'unknown';
        final message = err['message'] as String? ?? 'Bahis kabul edilemedi.';
        debugPrint('[placeBet] Sunucu hatası: $code - $message');
        throw FirebaseFunctionsException(code: code, message: message);
      }

      final result = body['result'] as Map<String, dynamic>?;
      final data = result;
      if (data == null || data['ok'] != true) {
        debugPrint('[placeBet] HATA: data null veya ok != true');
        debugPrint('[placeBet] data: $data');
        throw FirebaseFunctionsException(
          code: "unknown",
          message: "Bahis kabul edilemedi.",
        );
      }

      final newBalance = (data['newBalance'] as num?)?.toInt() ?? 0;
      final newStashBalance = (data['newStashBalance'] as num?)?.toInt() ?? 0;
      debugPrint('[placeBet] Yeni bakiye: $newBalance, stash: $newStashBalance');

      authState.updateBalanceFromBet(newBalance, newStashBalance);
      _updateLocalFeedModelAfterBet(model.key, userId, amount, commentFlag == 0);
      notifyListeners();
      debugPrint('[placeBet] Başarıyla tamamlandı!');
    } on PlatformException catch (e) {
      // Native Android hataları PlatformException olarak gelir
      debugPrint('[placeBet] PlatformException');
      debugPrint('[placeBet] code: ${e.code}');
      debugPrint('[placeBet] message: ${e.message}');
      debugPrint('[placeBet] details: ${e.details}');
      debugPrint('[placeBet] stacktrace: ${e.stacktrace}');
      rethrow; // Hatayı yukarı fırlat ki _send() içinde yakalansın
    } on FirebaseFunctionsException catch (e) {
      debugPrint('[placeBet] FirebaseFunctionsException');
      debugPrint('[placeBet] code: ${e.code}');
      debugPrint('[placeBet] message: ${e.message}');
      debugPrint('[placeBet] details: ${e.details}');
      rethrow; // Hatayı yukarı fırlat ki _send() içinde yakalansın
    } catch (e, stackTrace) {
      debugPrint('[placeBet] EXCEPTION: $e');
      debugPrint('[placeBet] Type: ${e.runtimeType}');
      debugPrint('[placeBet] Stack trace: $stackTrace');
      rethrow; // Hatayı yukarı fırlat ki _send() içinde yakalansın
    }
  }

  void _updateLocalFeedModelAfterBet(String? toldyaKey, String userId, int amount, bool isLike) {
    if (toldyaKey == null || _feedlist == null) return;
    for (final f in _feedlist!) {
      if (f.key == toldyaKey) {
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
          .child('toldya')
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
          .child('toldya')
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
          .child('toldya')
          .child(model.key ?? '')
          .child('favList')
          .set(model.favList);
    } catch (error) {
      cprint(error, errorIn: 'addFavToToldya');
    }
  }

  /// Add [new comment tweet] to any tweet
  /// Comment is a Tweet itself
  addcommentToPost(FeedModel replyToldya) {
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
        var json = replyToldya.toJson();
        kDatabase.child('toldya').push().set(json).then((value) {
          final lastKey = feedlist.isNotEmpty ? feedlist.last.key : null;
          if (lastKey != null) {
            (parentToldya.replyToldyaKeyList ??= []).add(lastKey);
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
  _onToldyaChanged(DatabaseEvent event) {
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

    final detailList = _toldyaDetailModelList;
    if (detailList != null && detailList.isNotEmpty) {
      if (detailList.any((x) => x.key == model.key)) {
        var oldEntry = detailList.lastWhere((entry) => entry.key == event.snapshot.key);
        final idx = detailList.indexOf(oldEntry);
        if (idx >= 0) detailList[idx] = model;
      }
      final parentKey = model.parentkey;
      if (parentKey != null) {
        var list = toldyaReplyMap[parentKey];
        if (list != null && list.isNotEmpty) {
          final idx = list.indexWhere((x) => x.key == model.key);
          if (idx >= 0) list[idx] = model;
        } else {
          toldyaReplyMap[parentKey] = [model];
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
  _onToldyaAdded(DatabaseEvent event) {
    final value = event.snapshot.value;
    if (value == null) return;
    final map = Map<String, dynamic>.from(value as Map);
    FeedModel toldya = FeedModel.fromJson(map);
    toldya.key = event.snapshot.key ?? '';

    _onCommentAdded(toldya);
    _feedlist ??= <FeedModel>[];
    // Sadece listede aynı key yoksa ekle (getDataFromDatabase + onChildAdded aynı kaydı iki kez eklemesin)
    if (toldya.isValidToldya && !_feedlist!.any((x) => x.key == toldya.key)) {
      _feedlist!.add(toldya);
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when comment tweet added
  /// Check if Tweet is a comment
  /// If Yes it will add tweet in comment list.
  /// add [new tweet] comment to comment list
  _onCommentAdded(FeedModel toldya) {
    if (toldya.childRetoldyaKey != null) return;
    final parentKey = toldya.parentkey;
    if (parentKey != null) {
      (toldyaReplyMap[parentKey] ??= []).add(toldya);
      cprint('Comment Added');
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when Tweet `Deleted`
  /// It removed Tweet from home page list, Tweet detail page list and from comment section if present
  _onToldyaRemoved(DatabaseEvent event) async {
    final value = event.snapshot.value;
    if (value == null) return;
    final map = Map<String, dynamic>.from(value as Map);
    FeedModel toldya = FeedModel.fromJson(map);
    toldya.key = event.snapshot.key ?? '';
    var toldyaId = toldya.key ?? '';
    var parentkey = toldya.parentkey;

    ///  Delete toldya in [Home Page]
    try {
      FeedModel? deletedToldya;
      final feedlist = _feedlist;
      if (feedlist != null &&
          feedlist.isNotEmpty &&
          toldyaId.isNotEmpty &&
          feedlist.any((x) => x.key == toldyaId)) {
        /// Delete toldya if it is in home page list.
        deletedToldya = feedlist.firstWhere((x) => x.key == toldyaId);
        _feedlist!.remove(deletedToldya);

        final dpk = deletedToldya.parentkey;
        if (dpk != null &&
            _feedlist!.isNotEmpty &&
            _feedlist!.any((x) => x.key == dpk)) {
          // Decrease parent toldya comment count and update
          var parentModel = _feedlist!.firstWhere((x) => x.key == dpk);
          (parentModel.replyToldyaKeyList ??= []).remove(deletedToldya.key);
          parentModel.commentCount =
              (parentModel.replyToldyaKeyList ?? []).length;
          updateToldya(parentModel);
        }
        if (_feedlist!.isEmpty) {
          _feedlist = null;
        }
        cprint('Toldya deleted from home page list');
      }

      /// [Delete toldya] if it is in nested toldya detail comment section page
      if (parentkey != null &&
          parentkey.isNotEmpty &&
          toldyaReplyMap.isNotEmpty &&
          toldyaReplyMap.containsKey(parentkey)) {
        final replyList = toldyaReplyMap[parentkey];
        if (replyList != null &&
            replyList.isNotEmpty &&
            replyList.any((x) => x.key == toldyaId)) {
          deletedToldya ??=
              replyList.firstWhere((x) => x.key == toldyaId);
          toldyaReplyMap[parentkey]!.remove(deletedToldya);
          if (toldyaReplyMap[parentkey]!.isEmpty) {
            toldyaReplyMap.remove(parentkey);
          }

          if (_toldyaDetailModelList != null &&
              _toldyaDetailModelList!.isNotEmpty &&
              _toldyaDetailModelList!.any((x) => x.key == parentkey)) {
            var parentModel =
                _toldyaDetailModelList!.firstWhere((x) => x.key == parentkey);
            (parentModel.replyToldyaKeyList ??= []).remove(deletedToldya.key);
            parentModel.commentCount =
                (parentModel.replyToldyaKeyList ?? []).length;
            cprint('Parent toldya comment count updated on child toldya removal');
            updateToldya(parentModel);
          }

          cprint('Toldya deleted from nested toldya detail comment section');
        }
      }

      if (deletedToldya == null) return;

      /// Delete toldya image from firebase storage if exist.
      if (deletedToldya.imagePath != null &&
          deletedToldya.imagePath!.isNotEmpty) {
        deleteFile(deletedToldya.imagePath!, 'toldyaImage');
      }

      /// If a retoldya is deleted then retoldyaCount of original toldya should be decrease by 1.
      if (deletedToldya.childRetoldyaKey != null) {
        await fetchToldya(deletedToldya.childRetoldyaKey!).then((retoldyaModel) {
          if (retoldyaModel == null) {
            return;
          }
          if ((retoldyaModel.retoldyaCount ?? 0) > 0) {
            retoldyaModel.retoldyaCount = (retoldyaModel.retoldyaCount ?? 0) - 1;
          }
          updateToldya(retoldyaModel);
        });
      }

      /// Delete notification related to deleted Toldya.
      if ((deletedToldya.likeCount ?? 0) > 0 &&
          toldya.userId != null &&
          toldya.key != null) {
        kDatabase
            .child('notification')
            .child(toldya.userId!)
            .child(toldya.key!)
            .remove();
      }
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: '_onToldyaRemoved');
    }
  }
}
