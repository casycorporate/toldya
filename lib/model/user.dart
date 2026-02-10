class UserModel {
  String? key;
  String? email;
  String? userId;
  String? displayName;
  String? userName;
  String? webSite;
  String? profilePic;
  String? bannerImage;
  String? contact;
  String? bio;
  String? location;
  String? dob;
  String? createdAt;
  bool? isVerified;
  int? followers;
  int? following;
  int? pegCount;
  /// Kilitli bakiye (kazançtan bir kısmı; drip ile harcanabilir bakiyeye aktarılır)
  int? stashCount;
  /// Rütbe/limit için deneyim puanı (backend ile uyumlu)
  int? xp;
  /// Son günlük bonus alım zamanı (ISO string)
  String? lastDailyClaimAt;
  /// Bahisçi skoru: Ne kadar isabetli tahminlere oynadı
  int? rank;
  /// Tahminci skoru: Ne kadar tahmini başarıyla sonuçlandırdı
  int? predictorScore;
  int? role;
  String? fcmToken;
  List<String>? followersList;
  List<String>? followingList;
  List<String>? blackList;

  UserModel(
      {this.email,
      this.userId,
      this.displayName,
      this.profilePic,
      this.bannerImage,
      this.key,
      this.contact,
      this.bio,
      this.dob,
      this.location,
      this.createdAt,
      this.userName,
      this.followers,
      this.following,
      this.webSite,
      this.isVerified,
      this.fcmToken,
      this.followersList,
      this.followingList,
      this.blackList,
      this.pegCount,
      this.stashCount,
      this.xp,
      this.lastDailyClaimAt,
      this.rank,
      this.predictorScore,
      this.role});

  UserModel.fromJson(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return;
    }
    followersList = [];
    followingList = [];
    blackList = [];
    email = map['email'];
    userId = map['userId'];
    displayName = map['displayName'];
    profilePic = map['profilePic'];
    bannerImage = map['bannerImage'];
    key = map['key'];
    dob = map['dob'];
    rank = map['rank'];
    bio = map['bio'];
    location = map['location'];
    contact = map['contact'];
    createdAt = map['createdAt'];
    followers = map['followers'];
    following = map['following'];
    userName = map['userName'];
    userName = map['userName'];
    pegCount = map["pegCount"];
    stashCount = map["stashCount"];
    xp = map["xp"];
    lastDailyClaimAt = map["lastDailyClaimAt"];
    predictorScore = map['predictorScore'];
    role = map['role'];
    webSite = map['webSite'];
    fcmToken = map['fcmToken'];
    isVerified = map['isVerified'] ?? false;
    if (map['followerList'] != null) {
      followersList = <String>[];
      for (final value in map['followerList'] as Iterable) {
        followersList!.add(value.toString());
      }
    }
    followers = followersList?.length;
    if (map['followingList'] != null) {
      followingList = <String>[];
      for (final value in map['followingList'] as Iterable) {
        followingList!.add(value.toString());
      }
    }
    following = followingList?.length;

    if (map['blackList'] != null) {
      blackList = <String>[];
      (map['blackList'] as Iterable).forEach((value) {
        blackList!.add(value.toString());
      });
    }
    else{
      blackList=[];
    }
  }

  toJson() {
    return {
      'key': key,
      "userId": userId,
      "email": email,
      'displayName': displayName,
      'profilePic': profilePic,
      'bannerImage': bannerImage,
      'contact': contact,
      'dob': dob,
      'bio': bio,
      'location': location,
      'createdAt': createdAt,
      'followers': followersList != null ? followersList!.length : null,
      'following': followingList != null ? followingList!.length : null,
      'userName': userName,
      'webSite': webSite,
      'isVerified': isVerified ?? false,
      'fcmToken': fcmToken,
      'followerList': followersList,
      'followingList': followingList,
      'blackList':blackList,
      'pegCount': pegCount,
      'stashCount': stashCount,
      'xp': xp,
      'lastDailyClaimAt': lastDailyClaimAt,
      'rank': rank,
      'predictorScore': predictorScore ?? 0,
      'role': role
    };
  }

  UserModel copyWith(
      {String? email,
      String? userId,
      String? displayName,
      String? profilePic,
      String? key,
      String? contact,
      String? bio,
      String? dob,
      String? bannerImage,
      String? location,
      String? createdAt,
      String? userName,
      int? followers,
      int? following,
      int? pegCount,
      int? stashCount,
      int? xp,
      String? lastDailyClaimAt,
      String? webSite,
      bool? isVerified,
      String? fcmToken,
      List<String>? followingList,
      List<String>? followersList,
      List<String>? blackList,
      int? rank,
      int? predictorScore,
      int? role}) {
    return UserModel(
        email: email ?? this.email,
        bio: bio ?? this.bio,
        contact: contact ?? this.contact,
        createdAt: createdAt ?? this.createdAt,
        displayName: displayName ?? this.displayName,
        dob: dob ?? this.dob,
        followers: followers ?? this.followers,
        following: following ?? this.following,
        pegCount: pegCount ?? this.pegCount,
        stashCount: stashCount ?? this.stashCount,
        xp: xp ?? this.xp,
        lastDailyClaimAt: lastDailyClaimAt ?? this.lastDailyClaimAt,
        isVerified: isVerified ?? this.isVerified,
        key: key ?? this.key,
        location: location ?? this.location,
        profilePic: profilePic ?? this.profilePic,
        bannerImage: bannerImage ?? this.bannerImage,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        webSite: webSite ?? this.webSite,
        fcmToken: fcmToken ?? this.fcmToken,
        followersList: followersList ?? this.followersList,
        followingList: followingList ?? this.followingList,
        blackList: blackList ?? this.blackList,
        rank: rank ?? this.rank,
        predictorScore: predictorScore ?? this.predictorScore,
        role: role ?? this.role);
  }

  String getLevel() {
    return "${((this.rank ?? 0) / 100).toStringAsFixed(0)} ";
    // if (num > 999 && num < 99999) {
    //   return "${(num / 1000).toStringAsFixed(1)} K";
    // } else if (num > 99999 && num < 999999) {
    //   return "${(num / 1000).toStringAsFixed(0)} K";
    // } else if (num > 999999 && num < 999999999) {
    //   return "${(num / 1000000).toStringAsFixed(1)} M";
    // } else if (num > 999999999) {
    //   return "${(num / 1000000000).toStringAsFixed(1)} B";
    // } else {
    //   return num.toString();
    // }
  }

  String getFollower() {
    return '${this.followers ?? 0}';
  }

  String getFollowing() {
    return '${this.following ?? 0}';
  }
}
