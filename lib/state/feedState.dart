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
  final Set<String> _betInFlightIds = <String>{};
  bool isBetInFlight(String? toldyaId) {
    if (toldyaId == null || toldyaId.isEmpty) return false;
    return _betInFlightIds.contains(toldyaId);
  }
  Map<String, List<FeedModel>> toldyaReplyMap = {};
  FeedModel? _toldyaToReplyModel;
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

  FeedModel? get toldyaToReplyModel => _toldyaToReplyModel;
  FeedModel? get toldyaToEditModel => _toldyaToEditModel;

  set setToldyaToReply(FeedModel model) {
    _toldyaToReplyModel = model;
  }

  set setToldyaToEdit(FeedModel model) {
    _toldyaToEditModel = model;
  }

  void clearToldyaToEdit() {
    if (_toldyaToEditModel == null) return;
    _toldyaToEditModel = null;
    notifyListeners();
  }

  List<FeedModel>? _commentlist;

  List<FeedModel>? _feedlist;
  List<FeedModel>? _filterfeedlist;
  dabase.Query? _feedQuery;
  String? _feedError;

  /// Profile "Bahislerim" list: toldya posts by a specific user (loaded via loadToldyaListForUser).
  List<FeedModel>? _profileUserToldyaList;
  String? _profileUserToldyaUserId;
  List<FeedModel>? get profileUserToldyaList => _profileUserToldyaList;
  String? get profileUserToldyaUserId => _profileUserToldyaUserId;

  /// Cache profile "Bahislerim" lists per userId to avoid tab/profile swap flicker.
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
  List<String>? _userfollowingList;

  List<String>? get followingList => _userfollowingList;

  List<FeedModel>? get toldyaDetailModel => _toldyaDetailModelList;

  /// `feedlist` always [contain all tweets] fetched from firebase database
  List<FeedModel>? get feedlist {
    _rebuildFeedCacheIfNeeded();
    return _feedSortedCache;
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
          x.user?.userId != userModel.userId) {
        return false;
      }
      if (userModel != null && inBlackList.contains(x.user?.userId)) {
        return false;
      }
      final isPublished = x.statu == Statu.statusLive || x.statu == Statu.statusLocked;
      final isMine = userModel != null && x.userId == userModel.userId;
      final isAiReviewOrRejected = x.statu == Statu.statusPendingAiReview || x.statu == Statu.statusRejectedByAi;

      // Feed'de netlik: Yayında filtredeyken kendi "incelemede / AI reddi" gönderilerini de göster.
      if (statu == Statu.statusLive && (isPublished || (isMine && isAiReviewOrRejected))) {
        if (topic_val == topic.gundem) return true;
        if (userModel == null) return false;
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
        if (userModel == null) return false;
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

  /// Load toldya posts for a given user (profile "Bahislerim"). Requires Firebase index on toldya: ".indexOn": ["userId"].
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
      final reply = _toldyaToReplyModel;
      if (reply != null) {
        reply.retoldyaCount = (reply.retoldyaCount ?? 0) + 1;
        await updateToldya(reply);
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

      // IMPORTANT: Never overwrite the whole `toldya/{id}` node from client.
      // Root `.set(model.toJson())` can accidentally null out server-controlled fields
      // (e.g. `statu`, `endDate`, `resolutionDate`, `manualModeration*`) and races with
      // admin/batch jobs. Use partial update instead.
      final raw = Map<String, dynamic>.from(model.toJson() as Map);

      // Drop nulls: RTDB `update` treats null as delete.
      raw.removeWhere((k, v) => v == null);

      // Server-controlled fields: never write from client updates.
      raw.remove('statu');
      raw.remove('topic');
      raw.remove('endDate');
      raw.remove('resolutionDate');
      raw.remove('aiModerationReason');
      raw.remove('oracleSource');
      raw.remove('oracleApiUrl');
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

  /// (Kullanımdışı – kural: bahis sadece placeBet Callable üzerinden.)
  /// Eskiden toldya/likeList'e client'tan yazıyordu; artık tüm bahis placeBet ile.
  @Deprecated('Use placeBet Callable for any bet. No direct client write to toldya.')
  void addLikeToToldya(FeedModel model, String userId, int count) {
    // No-op: Tüm bahis işlemi placeBet Cloud Function üzerinden yapılmalı.
  }

  /// (Kullanımdışı – kural: bahis sadece placeBet Callable üzerinden.)
  @Deprecated('Use placeBet Callable for any bet. No direct client write to toldya.')
  void addunLikeToToldya(FeedModel model, String userId, int count) {
    // No-op: Tüm bahis işlemi placeBet Cloud Function üzerinden yapılmalı.
  }

  /// Bahis işlemini backend (placeBet Callable) üzerinden yapar.
  /// Optimistic UI: önce yerel state güncellenir (bakiye + post likeList/unlikeList), sonra HTTP çağrısı yapılır.
  /// Başarısız olursa yerel state snapshot ile geri alınır ve hata fırlatılır.
  Future<void> placeBet(
    AuthState authState,
    FeedModel model,
    String userId,
    int amount,
    int commentFlag, {
    BuildContext? context,
  }) async {
    if (_feedDebug) {
      developer.log(
        'placeBet start',
        name: 'FeedState',
        error: {'toldyaId': model.key, 'side': commentFlag, 'amount': amount, 'userId': userId},
      );
    }

    final currentUser = authState.user;
    if (currentUser == null) {
      throw FirebaseFunctionsException(
        code: "unauthenticated",
        message: context != null
            ? AppLocalizations.of(context)!.betErrorUnauthenticated
            : "Giriş yapmanız gerekiyor.",
      );
    }
    if (amount <= 0) {
      throw FirebaseFunctionsException(code: "invalid-argument", message: "Geçersiz bahis miktarı.");
    }
    final toldyaId = model.key ?? '';
    if (toldyaId.isNotEmpty && _betInFlightIds.contains(toldyaId)) {
      return;
    }
    if (toldyaId.isNotEmpty) {
      _betInFlightIds.add(toldyaId);
      notifyListeners();
    }

    // Snapshot: rollback için önceki bakiye ve listelerin kopyası (optimistic güncellemeden önce alınır)
    final previousPegCount = authState.userModel?.pegCount ?? 0;
    final previousStashCount = authState.userModel?.stashCount ?? 0;
    final previousLikeList = [for (final e in model.likeList ?? []) UserPegModel(userId: e.userId, pegCount: e.pegCount)];
    final previousUnlikeList = [for (final e in model.unlikeList ?? []) UserPegModel(userId: e.userId, pegCount: e.pegCount)];

    // Optimistic update: UI anında güncellenir (balance azalır, post'a bahis eklenir)
    authState.setBalanceOptimistic(previousPegCount - amount, previousStashCount);
    _applyBetToFeedModel(model, userId, amount, commentFlag == 0);
    _updateLocalFeedModelAfterBet(model.key, userId, amount, commentFlag == 0);
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

      final uri = Uri.parse('${AppIcon.cloudFunctionsBaseUrl}/placeBet');

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
                message: l10n?.betErrorDeadlineExceeded ??
                    "İstek zaman aşımına uğradı. Lütfen tekrar deneyin.",
              );
            },
          );

      final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      if (body.containsKey('error')) {
        final err = body['error'] as Map<String, dynamic>? ?? {};
        final code = (err['status'] as String?)?.toLowerCase().replaceAll('_', '-') ?? 'unknown';
        final message = err['message'] as String? ?? 'Bahis kabul edilemedi.';
        final l10n = context != null ? AppLocalizations.of(context!) : null;
        throw FirebaseFunctionsException(
          code: code,
          message: l10n != null ? _mapPlaceBetError(l10n, code, message) : message,
        );
      }

      final result = body['result'] as Map<String, dynamic>?;
      final data = result;
      if (data == null || data['ok'] != true) {
        throw FirebaseFunctionsException(
          code: "unknown",
          message: "Bahis kabul edilemedi.",
        );
      }

      final newBalance = (data['newBalance'] as num?)?.toInt() ?? 0;
      final newStashBalance = (data['newStashBalance'] as num?)?.toInt() ?? 0;
      authState.updateBalanceFromBet(newBalance, newStashBalance);
      notifyListeners();
    } on PlatformException catch (e) {
      developer.log(
        'placeBet PlatformException',
        name: 'FeedState',
        error: e,
        stackTrace: StackTrace.current,
      );
      _rollbackPlaceBet(authState, model, previousPegCount, previousStashCount, previousLikeList, previousUnlikeList);
      rethrow;
    } on FirebaseFunctionsException catch (e) {
      developer.log(
        'placeBet FirebaseFunctionsException',
        name: 'FeedState',
        error: e,
        stackTrace: StackTrace.current,
      );
      _rollbackPlaceBet(authState, model, previousPegCount, previousStashCount, previousLikeList, previousUnlikeList);
      final l10n = context != null ? AppLocalizations.of(context!) : null;
      if (l10n == null) rethrow;
      final code = e.code;
      final msg = _mapPlaceBetError(l10n, code, e.message);
      throw FirebaseFunctionsException(code: code, message: msg, details: e.details);
    } catch (e, stackTrace) {
      developer.log(
        'placeBet exception',
        name: 'FeedState',
        error: e,
        stackTrace: stackTrace,
      );
      _rollbackPlaceBet(authState, model, previousPegCount, previousStashCount, previousLikeList, previousUnlikeList);
      rethrow;
    } finally {
      if (toldyaId.isNotEmpty) {
        _betInFlightIds.remove(toldyaId);
        notifyListeners();
      }
    }
  }

  String _mapPlaceBetError(AppLocalizations l10n, String codeRaw, String? fallbackMessage) {
    final code = codeRaw.toLowerCase().replaceAll('_', '-');
    switch (code) {
      case 'unauthenticated':
        return l10n.betErrorUnauthenticated;
      case 'deadline-exceeded':
        return l10n.betErrorDeadlineExceeded;
      case 'resource-exhausted':
        return l10n.betErrorResourceExhausted;
      case 'failed-precondition':
        return l10n.betErrorFailedPrecondition;
      case 'insufficient-balance':
        return l10n.tokenInsufficient;
      default:
        if (fallbackMessage != null && fallbackMessage.trim().isNotEmpty) return fallbackMessage;
        return l10n.betErrorGeneric;
    }
  }

  /// Optimistic güncelleme başarısız olduğunda snapshot ile bakiye ve post listelerini eski haline getirir.
  void _rollbackPlaceBet(
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

  /// Yorum oylama (Katılıyorum / Katılmıyorum). [postId] ana tahmin key, [replyToldyaId] yorum key, [vote] 1 veya -1.
  Future<void> voteReply(String postId, String replyToldyaId, int vote) async {
    if (vote != 1 && vote != -1) return;
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable("voteReply")
          .call<Map<dynamic, dynamic>>({"toldyaId": replyToldyaId, "vote": vote});
      final data = result.data;
      if (data == null || data["ok"] != true) return;
      final upvoteCount = (data["upvoteCount"] as num?)?.toInt() ?? 0;
      final downvoteCount = (data["downvoteCount"] as num?)?.toInt() ?? 0;
      final upvoteUserIds = (data["upvoteUserIds"] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      final downvoteUserIds = (data["downvoteUserIds"] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      final list = toldyaReplyMap[postId];
      if (list != null) {
        final idx = list.indexWhere((x) => x.key == replyToldyaId);
        if (idx >= 0) {
          list[idx].upvoteCount = upvoteCount;
          list[idx].downvoteCount = downvoteCount;
          list[idx].upvoteUserIds = upvoteUserIds;
          list[idx].downvoteUserIds = downvoteUserIds;
          notifyListeners();
        }
      }
    } catch (e) {
      cprint(e, errorIn: 'voteReply');
      rethrow;
    }
  }

  void _applyBetToFeedModel(FeedModel f, String userId, int amount, bool isLike) {
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
  void _updateLocalFeedModelAfterBet(String? toldyaKey, String userId, int amount, bool isLike) {
    if (toldyaKey == null) return;
    if (_feedlist != null) {
      for (final f in _feedlist!) {
        if (f.key == toldyaKey) {
          _applyBetToFeedModel(f, userId, amount, isLike);
          break;
        }
      }
    }
    if (_toldyaDetailModelList != null) {
      for (final f in _toldyaDetailModelList!) {
        if (f.key == toldyaKey) {
          _applyBetToFeedModel(f, userId, amount, isLike);
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

  /// (Kullanımdışı) Eski yorum ekleme API'si.
  /// Artık client tarafında yeni yorum oluşturulmuyor; RTDB'ye yazmaz.
  Future<void> addcommentToPost(FeedModel replyToldya) async {
    return;
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
      _markFeedCacheDirty();
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
    if (_feedDebug) debugPrint("[FeedDebug] _onToldyaAdded: key=${event.snapshot.key}, value exists=${event.snapshot.value != null}");
    final value = event.snapshot.value;
    if (value == null) return;
    final map = Map<String, dynamic>.from(value as Map);
    FeedModel toldya = FeedModel.fromJson(map);
    toldya.key = event.snapshot.key ?? '';
    if (_feedDebug) debugPrint("[FeedDebug] _onToldyaAdded: parsed key=${toldya.key}, statu=${toldya.statu}, user?.userName=${toldya.user?.userName}, isValidToldya=${toldya.isValidToldya}, alreadyInList=${_feedlist?.any((x) => x.key == toldya.key) ?? false}");

    _onCommentAdded(toldya);
    _feedlist ??= <FeedModel>[];
    // Sadece listede aynı key yoksa ekle (getDataFromDatabase + onChildAdded aynı kaydı iki kez eklemesin)
    final added = toldya.isValidToldya && !_feedlist!.any((x) => x.key == toldya.key);
    if (added) {
      _feedlist!.add(toldya);
      _markFeedCacheDirty();
    }
    if (_feedDebug) debugPrint("[FeedDebug] _onToldyaAdded: added=$added, _feedlist.length now=${_feedlist?.length ?? 0}");
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
    // No notify here; caller already notifies (avoids duplicate rebuilds).
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
