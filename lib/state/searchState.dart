import 'package:firebase_database/firebase_database.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/model/user.dart';
import 'appState.dart';

class SearchState extends AppState {
  bool isBusy = false;
  SortUser sortBy = SortUser.ByMaxFollower;
  List<UserModel>? _userFilterlist;
  List<UserModel>? _userlist;

  List<UserModel>? get userlist {
    final list = _userFilterlist;
    if (list == null) return null;
    list.sort((x, y) => (y.rank ?? 0).compareTo(x.rank ?? 0));
    return List.from(list);
  }

  /// get [UserModel list] from firebase realtime Database
  void getDataFromDatabase() {
    try {
      isBusy = true;
      kDatabase.child('profile').once().then(
        (snapshot) {
          _userlist = <UserModel>[];
          _userFilterlist = <UserModel>[];
          if (snapshot.snapshot.value != null) {
            final map = Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map);
            map.forEach((key, value) {
              var model = UserModel.fromJson(Map<String, dynamic>.from(value as Map));
              model.key = key.toString();
              _userlist!.add(model);
              _userFilterlist!.add(model);
            });
            _userFilterlist!.sort((x, y) => (y.followers ?? 0).compareTo(x.followers ?? 0));
          } else {
            _userlist = null;
          }
          isBusy = false;
        },
      );
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// It will reset filter list
  /// If user has use search filter and change screen and came back to search screen It will reset user list.
  /// This function call when search page open.
  void resetFilterList() {
    if (_userlist != null && _userFilterlist != null && _userlist!.length != _userFilterlist!.length) {
      _userFilterlist = List.from(_userlist!);
      _userFilterlist!.sort((x, y) => (y.followers ?? 0).compareTo(x.followers ?? 0));
      notifyListeners();
    }
  }

  /// This function call when search fiels text change.
  /// UserModel list on  search field get filter by `name` string
  void filterByUsername(String name) {
    if (name.isEmpty &&
        _userlist != null &&
        _userFilterlist != null &&
        _userlist!.length != _userFilterlist!.length) {
      _userFilterlist = List.from(_userlist!);
    }
    if (_userlist == null || _userlist!.isEmpty) {
      print("Empty userList");
      return;
    }
    if (name.isNotEmpty) {
      _userFilterlist = _userlist!
          .where((x) =>
              x.userName != null &&
              x.userName!.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// Sort user list on search user page.
  set updateUserSortPrefrence(SortUser val) {
    sortBy = val;
    notifyListeners();
  }

  String get selectedFilter {
    final list = _userFilterlist;
    if (list == null) return "Unknown";
    switch (sortBy) {
      case SortUser.ByAlphabetically:
        list.sort((x, y) => (x.displayName ?? '').compareTo(y.displayName ?? ''));
        notifyListeners();
        return "alphabetically";

      case SortUser.ByMaxFollower:
        list.sort((x, y) => (y.followers ?? 0).compareTo(x.followers ?? 0));
        notifyListeners();
        return "UserModel with max follower";

      case SortUser.ByNewest:
        list.sort((x, y) =>
            DateTime.parse(y.createdAt ?? '').compareTo(DateTime.parse(x.createdAt ?? '')));
        notifyListeners();
        return "Newest user first";

      case SortUser.ByOldest:
        list.sort((x, y) =>
            DateTime.parse(x.createdAt ?? '').compareTo(DateTime.parse(y.createdAt ?? '')));
        notifyListeners();
        return "Oldest user first";

      case SortUser.ByVerified:
        list.sort((x, y) =>
            (y.isVerified ?? false).toString().compareTo((x.isVerified ?? false).toString()));
        notifyListeners();
        return "Verified user first";

      default:
        return "Unknown";
    }
  }

  /// Return user list relative to provided `userIds`
  /// Method is used on
  List<UserModel> userList = [];
  List<UserModel> getuserDetail(List<String> userIds) {
    final ul = _userlist;
    if (ul == null) return [];
    final list = ul.where((x) {
      if (x.key != null && userIds.contains(x.key)) {
        return true;
      } else {
        return false;
      }
    }).toList();
    return list;
  }

  List<String> getUserInBlackList(UserModel? userIds) {
    List<String> rt=[];
    if (_userlist == null || userIds == null) {
      if (_userlist == null) print("Empty userList");
      return rt;
    }
    final list = _userlist!.where((x) {
      if(x.blackList?.isNotEmpty ?? false){
        if ( userIds.userId != null && x.blackList!.contains(userIds.userId)) {
          return true;
        } else {
          return false;
        }
      }else {
        return false;
      }
    }).toList();
    rt = list.map((e) => e.userId ?? '').toList();
    return rt;
  }
}
