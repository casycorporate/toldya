import 'package:toldya/helper/utility.dart';

/// Single entry in a league group: user and their XP snapshot for that week.
class LeagueEntry {
  LeagueEntry({required this.userId, required this.xpSnapshot});

  final String userId;
  final int xpSnapshot;

  static LeagueEntry? fromMap(String userId, dynamic xp) {
    if (userId.isEmpty) return null;
    final value = xp is int ? xp : (int.tryParse(xp?.toString() ?? '0') ?? 0);
    return LeagueEntry(userId: userId, xpSnapshot: value);
  }
}

/// League config from RTDB leagues/config.
class LeagueConfig {
  LeagueConfig({
    this.currentWeekId,
    this.groupSize = 30,
    this.tierNames = const ['Bronz', 'Gümüş', 'Altın'],
  });

  final String? currentWeekId;
  final int groupSize;
  final List<String> tierNames;

  static LeagueConfig fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return LeagueConfig();
    List<String> names = ['Bronz', 'Gümüş', 'Altın'];
    if (map['tierNames'] is List) {
      names = (map['tierNames'] as List)
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      if (names.isEmpty) names = ['Bronz', 'Gümüş', 'Altın'];
    }
    return LeagueConfig(
      currentWeekId: map['currentWeekId']?.toString(),
      groupSize: (map['groupSize'] is int)
          ? map['groupSize'] as int
          : (int.tryParse(map['groupSize']?.toString() ?? '30') ?? 30),
      tierNames: names,
    );
  }
}

/// Fetches the current week's league group for [userId]: list of entries (userId, xp) sorted by XP descending.
/// Returns empty list if config missing, week has no data, or user not in any group.
Future<List<LeagueEntry>> fetchLeagueGroupForUser(String userId) async {
  if (userId.isEmpty) return [];
  final configSnap = await kDatabase.child('leagues/config').get();
  final config = LeagueConfig.fromMap(
    configSnap.exists ? Map<dynamic, dynamic>.from(configSnap.value as Map) : null,
  );
  final weekId = config.currentWeekId;
  if (weekId == null || weekId.isEmpty) return [];

  final groupsSnap = await kDatabase.child('leagues/weeks/$weekId/groups').get();
  if (!groupsSnap.exists || groupsSnap.value == null) return [];

  final groups = groupsSnap.value as Map<dynamic, dynamic>;
  for (final groupEntry in groups.entries) {
    final groupMap = groupEntry.value;
    if (groupMap is! Map) continue;
    final map = Map<String, dynamic>.from(groupMap as Map);
    if (!map.containsKey(userId)) continue;
    final entries = <LeagueEntry>[];
    for (final e in map.entries) {
      final entry = LeagueEntry.fromMap(e.key, e.value);
      if (entry != null) entries.add(entry);
    }
    entries.sort((a, b) => b.xpSnapshot.compareTo(a.xpSnapshot));
    return entries;
  }
  return [];
}
