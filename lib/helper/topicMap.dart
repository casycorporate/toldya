
class topic{
  // Internal keys for topics – these are NOT user-facing strings.
  static const String gundem = 'flow';
  static const String followList = 'follow';
  static const String favList = 'favorite';
  static const Map<String, String> topicMap = {
    'spor': 'sports',
    'eco': 'economy',
    'fun': 'entertainment',
    'politic': 'politics'
  };
  static String getKeyFromVal(String val){
    try {
      final _key = topicMap.keys.firstWhere((k) => topicMap[k] == val);
      return _key;
    } catch (_) {
      return '';
    }
  }
}
