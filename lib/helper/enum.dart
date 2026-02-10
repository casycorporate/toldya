enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}
enum ToldyaType{
  Toldya,
  Detail,
  Reply,
  ParentToldya
}

enum SortUser{
  ByVerified,
  ByAlphabetically,
  ByNewest,
  ByOldest,
  ByMaxFollower
}

enum NotificationType{
  NOT_DETERMINED,
  Message,
  Toldya,
  Reply,
  Retoldya,
  Follow,
  Mention,
  Like,
  UnLike
}
enum ConfirmWinner{
  None,
  Like,
  Unlike
}