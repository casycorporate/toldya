import 'package:firebase_database/firebase_database.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/network_utils.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/model/user.dart';
import 'appState.dart';

/// V1.1: Loads profile list for Leaderboard and for user-detail lists (e.g. followers).
/// Replaces SearchState for leaderboard and UsersListPage.
class LeaderboardState extends AppState {
  bool isBusy = false;
  List<UserModel>? _userlist;
  String? _error;
  SortUser sortBy = SortUser.ByMaxFollower;

  String? get searchError => _error;
  void clearSearchError() {
    _error = null;
    notifyListeners();
  }

  set updateUserSortPrefrence(SortUser val) {
    sortBy = val;
    notifyListeners();
  }

  String get selectedFilter {
    switch (sortBy) {
      case SortUser.ByAlphabetically: return 'alphabeticallySort';
      case SortUser.ByNewest: return 'newestUserFirst';
      case SortUser.ByOldest: return 'oldestUserFirst';
      case SortUser.ByMaxFollower: return 'maxFollowerFirst';
      case SortUser.ByVerified: return 'verifiedUserFirst';
      default: return 'maxFollowerFirst';
    }
  }

  List<UserModel>? get userlist {
    if (_userlist == null) return null;
    final list = List<UserModel>.from(_userlist!);
    switch (sortBy) {
      case SortUser.ByAlphabetically:
        list.sort((x, y) => (x.displayName ?? '').compareTo(y.displayName ?? ''));
        break;
      case SortUser.ByNewest:
        list.sort((x, y) =>
            DateTime.parse(y.createdAt ?? '').compareTo(DateTime.parse(x.createdAt ?? '')));
        break;
      case SortUser.ByOldest:
        list.sort((x, y) =>
            DateTime.parse(x.createdAt ?? '').compareTo(DateTime.parse(y.createdAt ?? '')));
        break;
      case SortUser.ByMaxFollower:
        list.sort((x, y) => (y.followers ?? 0).compareTo(x.followers ?? 0));
        break;
      case SortUser.ByVerified:
        list.sort((x, y) =>
            (y.isVerified ?? false).toString().compareTo((x.isVerified ?? false).toString()));
        break;
      default:
        list.sort((x, y) => (y.rank ?? 0).compareTo(x.rank ?? 0));
    }
    return list;
  }

  /// Kullanıcıyı engellemiş kişilerin userId listesi (arama sonuçlarından çıkarılır).
  List<String> getUserInBlackList(UserModel? currentUser) {
    if (_userlist == null || currentUser?.userId == null) return [];
    final list = _userlist!.where((u) {
      if (u.blackList == null || u.blackList!.isEmpty) return false;
      return u.blackList!.contains(currentUser!.userId);
    }).toList();
    return list.map((e) => e.userId ?? '').where((id) => id.isNotEmpty).toList();
  }

  /// Load all profiles from Firebase (for leaderboard and getuserDetail).
  void getDataFromDatabase() {
    _error = null;
    isBusy = true;
    notifyListeners();
    runWithTimeoutAndRetry(() => kDatabase.child('profile').once()).then((snapshot) {
      final newList = <UserModel>[];
      if (snapshot.snapshot.value != null) {
        final map = Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map);
        map.forEach((key, value) {
          var model = UserModel.fromJson(Map<String, dynamic>.from(value as Map));
          model.key = key.toString();
          newList.add(model);
        });
      }
      _userlist = newList.isEmpty ? null : newList;
      isBusy = false;
      notifyListeners();
    }).catchError((error) {
      isBusy = false;
      _error = error?.toString() ?? 'Veri yüklenemedi';
      cprint(error, errorIn: 'LeaderboardState.getDataFromDatabase');
      notifyListeners();
    });
  }

  /// Return users whose keys are in [userIds].
  List<UserModel> getuserDetail(List<String> userIds) {
    final ul = _userlist;
    if (ul == null) return [];
    return ul.where((x) => x.key != null && userIds.contains(x.key)).toList();
  }
}
