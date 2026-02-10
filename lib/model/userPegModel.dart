class UserPegModel {
  String userId;
  int pegCount;

  UserPegModel({this.userId = '', this.pegCount = 0});

  UserPegModel.fromJson(Map<dynamic, dynamic> map)
      : userId = map['userId']?.toString() ?? '',
        pegCount = (map['pegCount'] is int) ? map['pegCount'] as int : int.tryParse(map['pegCount']?.toString() ?? '0') ?? 0;

  toJson() {
    return {
      "userId": userId,
      'pegCount': pegCount
    };}
}

