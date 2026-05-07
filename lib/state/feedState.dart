import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:toldya/model/userPegModel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/network_utils.dart';
import 'package:toldya/helper/topicMap.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/state/appState.dart';
import 'package:toldya/state/authState.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'dart:developer' as developer;

class FeedState extends AppState {
  static const int kFeedPageSize = 10;
  static const bool _feedDebug = false;

  bool isBusy = false;
  final Set<String> _stakeInFlightIds = <String>{};
  bool isStakeInFlight(String? toldyaId) {
    if (toldyaId == null || toldyaId.isEmpty) return false;
    return _stakeInFlightIds.contains(toldyaId);
  }
  FeedModel? _toldyaRetoldyaSourceModel;
  FeedModel? _toldyaToEditModel;

  /// Cache for feed ordering to avoid sorting on every getter call.
  /// The UI reads [feedlist] often; we rebuild this cache only when underlying data changes.
  List<FeedModel>? _feedSortedCache;
  bool _isFeedCacheDirty = true;

  void _markFeedCacheDirty() {
    _isFeedCacheDirty = true;
  }

  void _rebuildFeedCacheIfNeeded() {
    if (!_isFeedCacheDirty) return;
    final src = _feedlist;
    if (src == null) {
      _feedSortedCache = null;
      _isFeedCacheDirty = false;
      return;
    }
    // Preserve existing behavior: sort by total vote (like+unlike), descending.
    final list = List<FeedModel>.from(src);
    list.sort((a, b) =>
        (sumOfVote(b.likeList ?? []) + sumOfVote(b.unlikeList ?? []))
            .compareTo(sumOfVote(a.likeList ?? []) + sumOfVote(a.unlikeList ?? [])));
    _feedSortedCache = list;
    _isFeedCacheDirty = false;
  }

  String? _lastLoadedKey;
  bool _hasMoreFeed = true;
  bool _isLoadingMore = false;
  bool get hasMoreFeed => _hasMoreFeed;
  bool get isLoadingMore => _isLoadingMore;

  /// Retoldya oluştururken alıntılanan kaynak tahmin (compose ekranı).
  FeedModel? get toldyaRetoldyaSourceModel => _toldyaRetoldyaSourceModel;
  FeedModel? get toldyaToEditModel => _toldyaToEditModel;

  set setToldyaRetoldyaSource(FeedModel model) {
    _toldyaRetoldyaSourceModel = model;
  }

  void clearToldyaRetoldyaSource() {
    _toldyaRetoldyaSourceModel = null;
  }

  set setToldyaToEdit(FeedModel model) {
    _toldyaToEditModel = model;
  }

  void clearToldyaToEdit() {
    if (_toldyaToEditModel == null) return;
    _toldyaToEditModel = null;
    notifyListeners();
  }

  List<FeedModel>? _feedlist;
  List<FeedModel>? _filterfeedlist;
  dabase.Query? _feedQuery;
  String? _feedError;

  /// Profile "Tahminlerim" list: toldya posts by a specific user (loaded via loadToldyaListForUser).
  List<FeedModel>? _profileUserToldyaList;
  String? _profileUserToldyaUserId;
  List<FeedModel>? get profileUserToldyaList => _profileUserToldyaList;
  String? get profileUserToldyaUserId => _profileUserToldyaUserId;

  /// Cache profile "Tahminlerim" lists per userId to avoid tab/profile swap flicker.
  final Map<String, List<FeedModel>> _profileUserToldyaCache = {};

  List<FeedModel>? profileUserToldyaListFor(String userId) =>
      _profileUserToldyaCache[userId];

  bool hasProfileUserToldyaCached(String userId) =>
      _profileUserToldyaCache.containsKey(userId);

  String? get feedError => _feedError;

  void clearFeedError() {
    _feedError = null;
    notifyListeners();
  }
  List<FeedModel>? _toldyaDetailModelList;
  List<FeedModel>? get toldyaDetailModel => _toldyaDetailModelList;

  /// `feedlist` always [contain all tweets] fetched from firebase database
  List<FeedModel>? get feedlist {
    _rebuildFeedCacheIfNeeded();
    return _feedSortedCache;
  }

  /// contain tweet list for home page
  List<FeedModel> getToldyaList(UserModel? userModel) {
    if (userModel == null) return [];
    if (!isBusy && feedlist != null && feedlist!.isNotEmpty) {
      return feedlist!.where((x) {
        if (x.parentkey != null &&
            x.statu == Statu.statusLive &&
            x.childRetoldyaKey == null &&
            x.ownerId != userModel.userId) {
          return false;
        }
        return x.statu == Statu.statusLive || x.statu == Statu.statusLocked;
      }).toList();
    }
    return [];
  }

  List<FeedModel> getToldyaListByTopic(UserModel? userModel, List<String> inBlackList, String searchWord, int statu,
      {String topic_val = topic.gundem}) {
    if (_feedDebug) {
      debugPrint("[FeedDebug] getToldyaListByTopic: feedlist==null=${feedlist == null}, feedlist!.length=${feedlist?.length ?? -1}, topic_val=$topic_val, statu=$statu, userModel?.userId=${userModel?.userId}, inBlackList.length=${inBlackList.length}");
    }
    if (feedlist == null) return [];
    List<FeedModel> filterList = feedlist!;
    if (!feedlist!.isNotEmpty) return [];
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
      if (_feedDebug) {
        debugPrint("[FeedDebug] getToldyaListByTopic: after search filter, filterList.length=${filterList.length}");
      }
    }
    final list = filterList.where((x) {
      if (x.parentkey != null &&
          x.childRetoldyaKey == null &&
          userModel != null &&
          x.ownerId != userModel.userId) {
        return false;
      }
      if (userModel != null && inBlackList.contains(x.ownerId)) {
        return false;
      }
      final isPublished = x.statu == Statu.statusLive || x.statu == Statu.statusLocked;
      final isMine = userModel != null && x.ownerId == userModel.userId;
      final isAdminReviewOrRejected = x.statu == Statu.statusPendingAdminReview || x.statu == Statu.statusRejectedByAdmin;

      // Feed'de netlik: Yayında filtredeyken kendi "incelemede / yönetici reddi" gönderilerini de göster.
      if (statu == Statu.statusLive && (isPublished || (isMine && isAdminReviewOrRejected))) {
        if (topic_val == topic.gundem || topic_val == topic.followList) return true;
        if (userModel == null) return false;
        if (topic_val == topic.favList) {
          return x.favList?.contains(userModel.userId) ?? false;
        }
        return x.topic == topic_val;
      }
      if (x.statu == statu) {
        if (topic_val == topic.gundem || topic_val == topic.followList) return true;
        if (userModel == null) return false;
        if (topic_val == topic.favList) {
          return x.favList?.contains(userModel.userId) ?? false;
        }
        return x.topic == topic_val;
      }
      return false;
    }).toList();
    if (_feedDebug) {
      debugPrint("[FeedDebug] getToldyaListByTopic: result list.length=${list.length} (topic_val=$topic_val, statu=$statu)");
    }
    return list;
  }

  void getToldyaListByTopicAndSearch(UserModel? userModel, String searchWord,
      {String topic_val = topic.gundem}) {
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
            x.ownerId != userModel.userId) {
          return false;
        }
        final isPublished = x.statu == Statu.statusLive || x.statu == Statu.statusLocked;
        if (isPublished) {
          if (topic_val == topic.gundem || topic_val == topic.followList) return true;
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
      cprint(
          "Last Tweet removed from stack. Remaining Tweet: ${_toldyaDetailModelList!.length}");
    }
  }

  /// [clear all tweets] if any tweet present in toldya detail stack
  void clearAllDetailToldyaStack() {
    if (_toldyaDetailModelList != null) {
      _toldyaDetailModelList!.clear();
    }
    cprint('Empty tweets from stack');
  }

  /// [Subscribe Tweets] firebase Database
  Future<bool> databaseInit() {
    try {
      if (_feedQuery == null) {
        _feedQuery = kDatabase.child("toldya");
        _feedQuery!.onChildAdded.listen(_onToldyaAdded);
        // Kök `onValue` tüm toldya koleksiyonunu verir; tek modele parse etmek hatalıydı.
        // Alan güncellemeleri (ör. admin onayı → statu=0) için çocuk bazlı dinleme gerekir.
        _feedQuery!.onChildChanged.listen(_onToldyaChildChanged);
        _feedQuery!.onChildRemoved.listen(_onToldyaRemoved);
      }

      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  /// get [Tweet list] from firebase realtime database (first page only; pagination).
  /// Resets pagination state and loads newest [kFeedPageSize] items.
  void getDataFromDatabase() {
    _feedError = null;
    _isLoadingMore = false;
    isBusy = true;
    notifyListeners();
    if (_feedDebug) debugPrint("[FeedDebug] getDataFromDatabase: starting query (orderByKey limitToLast)");
    runWithTimeoutAndRetry(() => kDatabase
        .child('toldya')
        .orderByKey()
        .limitToLast(kFeedPageSize)
        .once()).then((snapshot) {
      if (_feedDebug) debugPrint("[FeedDebug] getDataFromDatabase: snapshot has ${snapshot.snapshot.children.length} children (from query orderByKey limitToLast)");
      final parsedList = <FeedModel>[];
      int rawChildCount = 0;
      final children = snapshot.snapshot.children;
      final childrenList = children.toList();
      if (childrenList.isNotEmpty) {
        for (var i = 0; i < childrenList.length; i++) {
          final child = childrenList[i];
          final key = child.key;
          final value = child.value;
          if (key == null || value == null) continue;
          rawChildCount++;
          try {
            var model = FeedModel.fromJson(Map<String, dynamic>.from(value as Map));
            model.key = key;
            model.normalizeOwnershipForWrite();
            final isFirst = i == 0;
            final isLast = i == childrenList.length - 1;
            if (isFirst || isLast) {
              if (_feedDebug) debugPrint("[FeedDebug] getDataFromDatabase: ${isFirst ? "first" : "last"} child key=$key, statu=${model.statu}, user?.userName=${model.user?.userName}, isValidToldya=${model.isValidToldya}");
            }
            if (model.isValidToldya) {
              parsedList.add(model);
            }
          } catch (e) {
            cprint(e, errorIn: 'getDataFromDatabase parse child');
          }
        }
      } else {
        final val = snapshot.snapshot.value;
        if (val != null && val is Map) {
          final map = Map<dynamic, dynamic>.from(val);
          final entries = map.entries.toList();
          for (var i = 0; i < entries.length; i++) {
            final key = entries[i].key;
            final value = entries[i].value;
            if (value == null) continue;
            rawChildCount++;
            try {
              var model = FeedModel.fromJson(Map<String, dynamic>.from(value as Map));
              model.key = key.toString();
              model.normalizeOwnershipForWrite();
              final isFirst = i == 0;
              final isLast = i == entries.length - 1;
              if (isFirst || isLast) {
                if (_feedDebug) debugPrint("[FeedDebug] getDataFromDatabase: ${isFirst ? "first" : "last"} child key=$key, statu=${model.statu}, user?.userName=${model.user?.userName}, isValidToldya=${model.isValidToldya}");
              }
              if (model.isValidToldya) {
                parsedList.add(model);
              }
            } catch (e) {
              cprint(e, errorIn: 'getDataFromDatabase parse');
            }
          }
        }
      }
      if (_feedDebug) debugPrint("[FeedDebug] getDataFromDatabase: after parse, _feedlist.length=${_feedlist?.length ?? 0}, _lastLoadedKey=$_lastLoadedKey");
      if (parsedList.isNotEmpty) {
        _feedlist = parsedList;
        _markFeedCacheDirty();
        final sortedKeys = _feedlist!.map((e) => e.key!).toList()..sort();
        _lastLoadedKey = sortedKeys.first;
        _hasMoreFeed = _feedlist!.length >= kFeedPageSize;
        final keys = _feedlist!.map((e) => e.key!).toList();
        final first3 = keys.length > 3 ? keys.take(3).join(',') : keys.join(',');
        final last3 = keys.length > 3 ? keys.reversed.take(3).toList().reversed.join(',') : '';
        if (_feedDebug) debugPrint("[FeedDebug] getDataFromDatabase: _lastLoadedKey set, _feedlist keys first3=$first3${last3.isNotEmpty ? ', last3=$last3' : ''}");
        _feedError = null;
      } else {
        // Keep _feedlist unchanged so items already added by _onToldyaAdded remain visible
        _hasMoreFeed = rawChildCount > 0;
        if (rawChildCount > 0) {
          _feedError = null;
          cprint('getDataFromDatabase: $rawChildCount raw children but 0 valid (isValidToldya). hasMoreFeed=true so user can load more.', errorIn: 'getDataFromDatabase');
        }
      }
      isBusy = false;
      if (_feedlist != null && _feedlist!.isNotEmpty) _feedError = null;
      notifyListeners();
    }).catchError((error) {
      if (_feedDebug) debugPrint("[FeedDebug] getDataFromDatabase: CATCHERROR error=$error");
      if (error != null && error is Error) {
        if (_feedDebug) debugPrint("[FeedDebug] getDataFromDatabase: stackTrace=${(error as Error).stackTrace}");
      }
      final msg = error?.toString().toLowerCase() ?? '';
      if (msg.contains('permission')) {
        if (_feedDebug) debugPrint("[FeedDebug] getDataFromDatabase: hint=likely Firebase rules/auth");
      }
      if (msg.contains('timeout')) {
        if (_feedDebug) debugPrint("[FeedDebug] getDataFromDatabase: hint=likely network/timeout");
      }
      cprint(error, errorIn: 'getDataFromDatabase');
      isBusy = false;
      _feedError = error?.toString() ?? 'Failed to load feed';
      // Do not clear _feedlist so any items already added by _onToldyaAdded remain visible
      notifyListeners();
    });
  }

  /// Load next page of feed (older items). No-op if already loading, no more data, or no _lastLoadedKey.
  Future<void> loadMoreFeed() async {
    if (_isLoadingMore || !_hasMoreFeed || _lastLoadedKey == null) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final snapshot = await runWithTimeoutAndRetry(() => kDatabase
          .child('toldya')
          .orderByKey()
          .endAt(_lastLoadedKey!)
          .limitToLast(kFeedPageSize + 1)
          .once());
      final list = <FeedModel>[];
      final val = snapshot.snapshot.value;
      if (val != null) {
        if (val is Map) {
          final map = Map<dynamic, dynamic>.from(val);
          map.forEach((key, value) {
            if (value == null) return;
            try {
              var model = FeedModel.fromJson(Map<String, dynamic>.from(value as Map));
              model.key = key.toString();
              model.normalizeOwnershipForWrite();
              if (model.isValidToldya) list.add(model);
            } catch (_) {}
          });
        } else {
          for (final child in snapshot.snapshot.children) {
            final key = child.key;
            final value = child.value;
            if (key == null || value == null) continue;
            try {
              var model = FeedModel.fromJson(Map<String, dynamic>.from(value as Map));
              model.key = key;
              model.normalizeOwnershipForWrite();
              if (model.isValidToldya) list.add(model);
            } catch (_) {}
          }
        }
      }
      list.sort((a, b) => (a.key ?? '').compareTo(b.key ?? ''));
      if (list.isNotEmpty && list.last.key == _lastLoadedKey) {
        list.removeLast();
      }
      final existingKeys = _feedlist != null
          ? Set<String>.from(_feedlist!.map((e) => e.key ?? ''))
          : <String>{};
      final toAppend = list.where((e) => e.key != null && !existingKeys.contains(e.key!)).toList();
      if (toAppend.isEmpty) {
        _hasMoreFeed = false;
      } else {
        _feedlist ??= <FeedModel>[];
        _feedlist!.addAll(toAppend);
        _markFeedCacheDirty();
        final newKeys = toAppend.map((e) => e.key!).toList()..sort();
        _lastLoadedKey = newKeys.first;
        _hasMoreFeed = toAppend.length >= kFeedPageSize;
      }
      if (list.length < kFeedPageSize && toAppend.length < kFeedPageSize) {
        _hasMoreFeed = false;
      }
    } catch (error) {
      cprint(error, errorIn: 'loadMoreFeed');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load toldya posts for a given user (profile "Tahminlerim"). Requires Firebase index on toldya: ".indexOn": ["userId"].
  /// Call when opening a profile; use [profileUserToldyaList] for that user's posts.
  Future<void> loadToldyaListForUser(String? userId) async {
    if (userId == null || userId.isEmpty) {
      _profileUserToldyaList = null;
      _profileUserToldyaUserId = null;
      notifyListeners();
      return;
    }
    try {
      final snapshot = await runWithTimeoutAndRetry(() => kDatabase
          .child('toldya')
          .orderByChild('userId')
          .equalTo(userId)
          .once());
      final list = <FeedModel>[];
      final val = snapshot.snapshot.value;
      if (val != null) {
        if (val is Map) {
          final map = Map<dynamic, dynamic>.from(val);
          map.forEach((key, value) {
            if (value == null) return;
            try {
              var model = FeedModel.fromJson(Map<String, dynamic>.from(value as Map));
              model.key = key.toString();
              model.normalizeOwnershipForWrite();
              if (model.isValidToldya) list.add(model);
            } catch (_) {}
          });
        } else {
          for (final child in snapshot.snapshot.children) {
            final key = child.key;
            final value = child.value;
            if (key == null || value == null) continue;
            try {
              var model = FeedModel.fromJson(Map<String, dynamic>.from(value as Map));
              model.key = key;
              model.normalizeOwnershipForWrite();
              if (model.isValidToldya) list.add(model);
            } catch (_) {}
          }
        }
      }
      list.sort((a, b) => (a.createdAt ?? '').compareTo(b.createdAt ?? ''));
      final out = list.reversed.toList();
      _profileUserToldyaCache[userId] = out;
      // Keep legacy fields in sync for older call sites.
      _profileUserToldyaList = out;
      _profileUserToldyaUserId = userId;
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'loadToldyaListForUser');
      _profileUserToldyaCache[userId] = [];
      _profileUserToldyaList = _profileUserToldyaCache[userId];
      _profileUserToldyaUserId = userId;
      notifyListeners();
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
            _toldyaDetail!.normalizeOwnershipForWrite();
            setFeedModel = _toldyaDetail!;
          }
        });
      }

      if (_toldyaDetail != null) {
        notifyListeners();
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
        _toldyaDetail!.normalizeOwnershipForWrite();
      } else {
        cprint("Fetched null value from  DB");
      }
    }
    return _toldyaDetail;
  }

  /// create [New Tweet]
  Future<void> createToldya(FeedModel model) async {
    isBusy = true;
    notifyListeners();
    try {
      await kDatabase.child('toldya').push().set(model.toJson());
    } catch (error) {
      cprint(error, errorIn: 'createToldya');
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  ///  It will create tweet in [Firebase kDatabase] just like other normal tweet.
  ///  update retweet count for retweet model
  Future<void> createReToldya(FeedModel model) async {
    try {
      await createToldya(model);
      final source = _toldyaRetoldyaSourceModel;
      if (source != null) {
        source.retoldyaCount = (source.retoldyaCount ?? 0) + 1;
        await updateToldya(source);
      }
    } catch (error) {
      cprint(error, errorIn: 'createReToldya');
      rethrow;
    }
  }



  /// [Delete tweet] in Firebase kDatabase
  /// Remove Tweet if present in home page Tweet list
  /// Remove Tweet if present in Tweet detail page or in comment
  Future<void> deleteToldya(String toldyaId, ToldyaType type, {String? parentkey}) async {
    try {
      await kDatabase.child('toldya').child(toldyaId).remove();
      if (type == ToldyaType.Detail &&
          _toldyaDetailModelList != null &&
          _toldyaDetailModelList!.length > 0) {
        _toldyaDetailModelList!.removeWhere((x) => x.key == toldyaId);
        if (_toldyaDetailModelList!.isEmpty) {
          _toldyaDetailModelList = null;
        }
      }
    } catch (error) {
      cprint(error, errorIn: 'deleteToldya');
      rethrow;
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
  Future<void> updateToldya(FeedModel model) async {
    try {
      final key = model.key;
      if (key == null || key.isEmpty) return;
      model.normalizeOwnershipForWrite();

      // IMPORTANT: Never overwrite the whole `toldya/{id}` node from client.
      // Root `.set(model.toJson())` can accidentally null out server-controlled fields
      // (e.g. `statu`, `endDate`, `manualModeration*`) and races with
      // admin/batch jobs. Use partial update instead.
      final raw = Map<String, dynamic>.from(model.toJson() as Map);

      // Drop nulls: RTDB `update` treats null as delete.
      raw.removeWhere((k, v) => v == null);

      // Server-controlled fields: never write from client updates.
      raw.remove('statu');
      raw.remove('topic');
      raw.remove('endDate');
      raw.remove('manualModerationReason');
      raw.remove('aiModerationReason');
      raw.remove('collateralAmount');
      raw.remove('distributionDone');
      raw.remove('feedResult');
      raw.remove('disputeUserIds');
      raw.remove('challengeeUserId');
      raw.remove('parentkey');
      raw.remove('childRetoldyaKey');
      raw.remove('createdAt');
      raw.remove('userId');

      // If nothing left, don't write.
      if (raw.isEmpty) return;

      await kDatabase.child('toldya').child(key).update(raw);
    } catch (error) {
      cprint(error, errorIn: 'updateToldya');
      rethrow;
    }
  }

  /// Pari-Mutuel: Kazananlara token dağıtımı
  /// Kazanç = (Kişisel puan / Kazanan tarafın toplam puanı) × (Toplam havuz × (1 - komisyon))
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

  /// (Kullanımdışı – kural: tahmin katılımı yalnızca Cloud Function üzerinden.)
  /// Eskiden toldya/likeList'e client'tan yazıyordu; artık tüm işlem submitStake ile.
  @Deprecated('Use submitStake Cloud Function only. No direct client write to toldya.')
  void addLikeToToldya(FeedModel model, String userId, int count) {
    // No-op: Tahmin katılımı yalnızca Cloud Function üzerinden yapılmalı.
  }

  /// (Kullanımdışı – kural: tahmin katılımı yalnızca Cloud Function üzerinden.)
  @Deprecated('Use submitStake Cloud Function only. No direct client write to toldya.')
  void addunLikeToToldya(FeedModel model, String userId, int count) {
    // No-op: Tahmin katılımı yalnızca Cloud Function üzerinden yapılmalı.
  }

  /// Tahmin katılımını backend (HTTPS callable `submitStake`) üzerinden gönderir.
  /// Optimistic UI: önce yerel state güncellenir (bakiye + post likeList/unlikeList), sonra HTTP çağrısı yapılır.
  /// Başarısız olursa yerel state snapshot ile geri alınır ve hata fırlatılır.
  Future<void> submitStake(
    AuthState authState,
    FeedModel model,
    String userId,
    int amount,
    int commentFlag, {
    BuildContext? context,
  }) async {
    if (_feedDebug) {
      developer.log(
        'submitStake start',
        name: 'FeedState',
        error: {'toldyaId': model.key, 'side': commentFlag, 'amount': amount, 'userId': userId},
      );
    }

    final currentUser = authState.user;
    if (currentUser == null) {
      throw FirebaseFunctionsException(
        code: "unauthenticated",
        message: context != null
            ? AppLocalizations.of(context)!.stakeErrorUnauthenticated
            : "Giriş yapmanız gerekiyor.",
      );
    }
    if (amount <= 0) {
      throw FirebaseFunctionsException(
        code: "invalid-argument",
        message: context != null
            ? AppLocalizations.of(context)!.stakeInvalidAmount
            : "Geçersiz tahmin puanı.",
      );
    }
    final toldyaId = model.key ?? '';
    if (toldyaId.isNotEmpty && _stakeInFlightIds.contains(toldyaId)) {
      return;
    }
    if (toldyaId.isNotEmpty) {
      _stakeInFlightIds.add(toldyaId);
      notifyListeners();
    }

    // Snapshot: rollback için önceki bakiye ve listelerin kopyası (optimistic güncellemeden önce alınır)
    final previousPegCount = authState.userModel?.pegCount ?? 0;
    final previousStashCount = authState.userModel?.stashCount ?? 0;
    final previousLikeList = [for (final e in model.likeList ?? []) UserPegModel(userId: e.userId, pegCount: e.pegCount)];
    final previousUnlikeList = [for (final e in model.unlikeList ?? []) UserPegModel(userId: e.userId, pegCount: e.pegCount)];

    // Optimistic update: UI anında güncellenir (balance azalır, post'a katılım eklenir)
    authState.setBalanceOptimistic(previousPegCount - amount, previousStashCount);
    _applyStakeToFeedModel(model, userId, amount, commentFlag == 0);
    _updateLocalFeedModelAfterStake(model.key, userId, amount, commentFlag == 0);
    _markFeedCacheDirty();
    notifyListeners();

    try {
      final side = commentFlag == 0 ? 1 : 2; // 1 = Evet (like), 2 = Hayır (unlike)
      final idToken = await currentUser.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw FirebaseFunctionsException(
          code: "unauthenticated",
          message: "Oturum bilgisi alınamadı. Lütfen tekrar giriş yapın.",
        );
      }

      final uri = Uri.parse('${AppIcon.cloudFunctionsBaseUrl}/submitStake');

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
              final l10n = context != null ? AppLocalizations.of(context!) : null;
              throw FirebaseFunctionsException(
                code: "deadline-exceeded",
                message: l10n?.stakeErrorDeadlineExceeded ??
                    "İstek zaman aşımına uğradı. Lütfen tekrar deneyin.",
              );
            },
          );

      final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      if (body.containsKey('error')) {
        final err = body['error'] as Map<String, dynamic>? ?? {};
        final code = (err['status'] as String?)?.toLowerCase().replaceAll('_', '-') ?? 'unknown';
        final l10n = context != null ? AppLocalizations.of(context!) : null;
        final message = err['message'] as String? ?? l10n?.stakeErrorGeneric ?? 'Tahmin gönderilemedi.';
        throw FirebaseFunctionsException(
          code: code,
          message: l10n != null ? _mapStakeError(l10n, code, message) : message,
        );
      }

      final result = body['result'] as Map<String, dynamic>?;
      final data = result;
      if (data == null || data['ok'] != true) {
        final l10n = context != null ? AppLocalizations.of(context!) : null;
        throw FirebaseFunctionsException(
          code: "unknown",
          message: l10n?.stakeErrorGeneric ?? "Tahmin gönderilemedi.",
        );
      }

      final newBalance = (data['newBalance'] as num?)?.toInt() ?? 0;
      final newStashBalance = (data['newStashBalance'] as num?)?.toInt() ?? 0;
      authState.updateBalanceFromStake(newBalance, newStashBalance);
      notifyListeners();
    } on PlatformException catch (e) {
      developer.log(
        'submitStake PlatformException',
        name: 'FeedState',
        error: e,
        stackTrace: StackTrace.current,
      );
      _rollbackStake(authState, model, previousPegCount, previousStashCount, previousLikeList, previousUnlikeList);
      rethrow;
    } on FirebaseFunctionsException catch (e) {
      developer.log(
        'submitStake FirebaseFunctionsException',
        name: 'FeedState',
        error: e,
        stackTrace: StackTrace.current,
      );
      _rollbackStake(authState, model, previousPegCount, previousStashCount, previousLikeList, previousUnlikeList);
      final l10n = context != null ? AppLocalizations.of(context!) : null;
      if (l10n == null) rethrow;
      final code = e.code;
      final msg = _mapStakeError(l10n, code, e.message);
      throw FirebaseFunctionsException(code: code, message: msg, details: e.details);
    } catch (e, stackTrace) {
      developer.log(
        'submitStake exception',
        name: 'FeedState',
        error: e,
        stackTrace: stackTrace,
      );
      _rollbackStake(authState, model, previousPegCount, previousStashCount, previousLikeList, previousUnlikeList);
      rethrow;
    } finally {
      if (toldyaId.isNotEmpty) {
        _stakeInFlightIds.remove(toldyaId);
        notifyListeners();
      }
    }
  }

  String _mapStakeError(AppLocalizations l10n, String codeRaw, String? fallbackMessage) {
    final code = codeRaw.toLowerCase().replaceAll('_', '-');
    switch (code) {
      case 'unauthenticated':
        return l10n.stakeErrorUnauthenticated;
      case 'deadline-exceeded':
        return l10n.stakeErrorDeadlineExceeded;
      case 'resource-exhausted':
        return l10n.stakeErrorResourceExhausted;
      case 'failed-precondition':
        return l10n.stakeErrorFailedPrecondition;
      case 'insufficient-balance':
        return l10n.tokenInsufficient;
      default:
        if (fallbackMessage != null && fallbackMessage.trim().isNotEmpty) return fallbackMessage;
        return l10n.stakeErrorGeneric;
    }
  }

  /// Optimistic güncelleme başarısız olduğunda snapshot ile bakiye ve post listelerini eski haline getirir.
  void _rollbackStake(
    AuthState authState,
    FeedModel model,
    int previousPegCount,
    int previousStashCount,
    List<UserPegModel> previousLikeList,
    List<UserPegModel> previousUnlikeList,
  ) {
    authState.setBalanceOptimistic(previousPegCount, previousStashCount);
    model.likeList = [for (final e in previousLikeList) UserPegModel(userId: e.userId, pegCount: e.pegCount)];
    model.unlikeList = [for (final e in previousUnlikeList) UserPegModel(userId: e.userId, pegCount: e.pegCount)];
    if (_feedlist != null) {
      for (final f in _feedlist!) {
        if (f.key == model.key && f != model) {
          f.likeList = [for (final e in previousLikeList) UserPegModel(userId: e.userId, pegCount: e.pegCount)];
          f.unlikeList = [for (final e in previousUnlikeList) UserPegModel(userId: e.userId, pegCount: e.pegCount)];
          break;
        }
      }
    }
    if (_toldyaDetailModelList != null) {
      for (final f in _toldyaDetailModelList!) {
        if (f.key == model.key && f != model) {
          f.likeList = [for (final e in previousLikeList) UserPegModel(userId: e.userId, pegCount: e.pegCount)];
          f.unlikeList = [for (final e in previousUnlikeList) UserPegModel(userId: e.userId, pegCount: e.pegCount)];
          break;
        }
      }
    }
    _markFeedCacheDirty();
    notifyListeners();
  }

  void _applyStakeToFeedModel(FeedModel f, String userId, int amount, bool isLike) {
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
  }

  /// Optimistic update: aynı post _feedlist ve _toldyaDetailModelList içinde varsa hepsinde likeList/unlikeList güncellenir (feed + detail senkron).
  void _updateLocalFeedModelAfterStake(String? toldyaKey, String userId, int amount, bool isLike) {
    if (toldyaKey == null) return;
    if (_feedlist != null) {
      for (final f in _feedlist!) {
        if (f.key == toldyaKey) {
          _applyStakeToFeedModel(f, userId, amount, isLike);
          break;
        }
      }
    }
    if (_toldyaDetailModelList != null) {
      for (final f in _toldyaDetailModelList!) {
        if (f.key == toldyaKey) {
          _applyStakeToFeedModel(f, userId, amount, isLike);
        }
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

  /// Report a toldya with a reason code (for moderators). Keeps reportList and adds reportReasons.
  void addReportToToldyaWithReason(FeedModel model, String userId, String reason) {
    try {
      model.reportList ??= [];
      if (!model.reportList!.any((id) => id == userId)) {
        model.reportList!.add(userId);
      }
      model.reportReasons ??= {};
      model.reportReasons![userId] = reason;

      kDatabase
          .child('toldya')
          .child(model.key ?? '')
          .child('reportList')
          .set(model.reportList);
      kDatabase
          .child('toldya')
          .child(model.key ?? '')
          .child('reportReasons')
          .set(model.reportReasons);
    } catch (error) {
      cprint(error, errorIn: 'addReportToToldyaWithReason');
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

  /// Profil sekmesindeki önbelleği mevcut kullanıcı listesiyle senkron tut.
  void _syncLegacyProfileListPointer(String userId) {
    if (_profileUserToldyaUserId == userId) {
      _profileUserToldyaList = _profileUserToldyaCache[userId];
    }
  }

  /// `loadToldyaListForUser` önbelleği: RTDB güncellemelerinde statü vb. anında yansır.
  void _syncProfileToldyaCacheForModel(FeedModel model, {required bool insertIfMissing}) {
    final uid = model.ownerId;
    if (uid.isEmpty || !model.isValidToldya) return;
    var list = _profileUserToldyaCache[uid];
    if (list == null) {
      if (!insertIfMissing) return;
      list = <FeedModel>[model];
      _profileUserToldyaCache[uid] = list;
      _syncLegacyProfileListPointer(uid);
      return;
    }
    final idx = list.indexWhere((m) => m.key == model.key);
    if (idx >= 0) {
      list[idx] = model;
    } else if (insertIfMissing) {
      list.insert(0, model);
    }
    _syncLegacyProfileListPointer(uid);
  }

  void _removeFromProfileToldyaCaches(FeedModel deleted) {
    final uid = deleted.ownerId;
    if (uid.isEmpty) return;
    final list = _profileUserToldyaCache[uid];
    if (list == null) return;
    list.removeWhere((m) => m.key == deleted.key);
    _syncLegacyProfileListPointer(uid);
  }

  /// Tek bir toldya düğümü değiştiğinde (moderasyon statu, endDate, havuz vb.).
  void _onToldyaChildChanged(DatabaseEvent event) {
    final key = event.snapshot.key;
    final value = event.snapshot.value;
    if (key == null || value == null) return;
    try {
      FeedModel model =
          FeedModel.fromJson(Map<String, dynamic>.from(value as Map));
      model.key = key;
      model.normalizeOwnershipForWrite();

      final feedlist = _feedlist;
      if (feedlist != null && feedlist.any((x) => x.key == model.key)) {
        final idx = feedlist.indexWhere((x) => x.key == model.key);
        if (idx >= 0) {
          feedlist[idx] = model;
          _markFeedCacheDirty();
        }
      }

      final detailList = _toldyaDetailModelList;
      if (detailList != null &&
          detailList.isNotEmpty &&
          detailList.any((x) => x.key == model.key)) {
        final idx = detailList.indexWhere((x) => x.key == model.key);
        if (idx >= 0) detailList[idx] = model;
      }

      _syncProfileToldyaCacheForModel(model, insertIfMissing: false);

      if (_feedDebug) {
        debugPrint(
            '[FeedDebug] _onToldyaChildChanged: key=$key statu=${model.statu}');
      }
      isBusy = false;
      notifyListeners();
    } catch (error, stack) {
      cprint(error, errorIn: '_onToldyaChildChanged');
      if (_feedDebug) debugPrint('$stack');
    }
  }

  /// Trigger when new tweet added
  /// It will add new Tweet in home page list.
  /// IF Tweet is comment it will be added in comment section too.
  _onToldyaAdded(DatabaseEvent event) {
    if (_feedDebug) debugPrint("[FeedDebug] _onToldyaAdded: key=${event.snapshot.key}, value exists=${event.snapshot.value != null}");
    final value = event.snapshot.value;
    if (value == null) return;
    final map = Map<String, dynamic>.from(value as Map);
    FeedModel toldya = FeedModel.fromJson(map);
    toldya.key = event.snapshot.key ?? '';
    toldya.normalizeOwnershipForWrite();
    if (_feedDebug) debugPrint("[FeedDebug] _onToldyaAdded: parsed key=${toldya.key}, statu=${toldya.statu}, user?.userName=${toldya.user?.userName}, isValidToldya=${toldya.isValidToldya}, alreadyInList=${_feedlist?.any((x) => x.key == toldya.key) ?? false}");

    _feedlist ??= <FeedModel>[];
    final existingIdx = _feedlist!.indexWhere((x) => x.key == toldya.key);
    final added = toldya.isValidToldya && existingIdx < 0;
    if (added) {
      _feedlist!.add(toldya);
      _markFeedCacheDirty();
    } else if (existingIdx >= 0 && toldya.isValidToldya) {
      _feedlist![existingIdx] = toldya;
      _markFeedCacheDirty();
    }
    _syncProfileToldyaCacheForModel(toldya, insertIfMissing: true);
    if (_feedDebug) debugPrint("[FeedDebug] _onToldyaAdded: added=$added, _feedlist.length now=${_feedlist?.length ?? 0}");
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
    toldya.normalizeOwnershipForWrite();
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
        _markFeedCacheDirty();

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
          _markFeedCacheDirty();
        }
        cprint('Toldya deleted from home page list');
      }

      if (parentkey != null &&
          parentkey.isNotEmpty &&
          _toldyaDetailModelList != null &&
          _toldyaDetailModelList!.isNotEmpty &&
          _toldyaDetailModelList!.any((x) => x.key == parentkey)) {
        var parentModel =
            _toldyaDetailModelList!.firstWhere((x) => x.key == parentkey);
        (parentModel.replyToldyaKeyList ??= []).remove(toldyaId);
        parentModel.commentCount =
            (parentModel.replyToldyaKeyList ?? []).length;
        cprint('Parent toldya comment count updated on child toldya removal');
        updateToldya(parentModel);
      }

      deletedToldya ??= toldya;
      _removeFromProfileToldyaCaches(deletedToldya);

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
