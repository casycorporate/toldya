
class topic{
  static final String gundem="Akış";
  static final String followList="Takip";
  static final String favList="Favori";
  static final Map<String, String> topicMap = {
    'spor': 'Spor',
    'eco': 'Ekonomi',
    'fun': 'Eğlence',
    'politic': 'Siyaset'
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
