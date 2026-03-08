import 'package:flutter/material.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/model/league.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/searchState.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/widgets/newWidget/emptyList.dart';
import 'package:toldya/widgets/newWidget/custom_shimmer.dart';
import 'package:toldya/page/profile/leaderboard/league_pre_season_empty_state.dart';
import 'package:toldya/page/profile/leaderboard/active_league_view.dart';
import 'package:provider/provider.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchState>(context, listen: false).getDataFromDatabase();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? MockupDesign.textPrimary : theme.colorScheme.onSurface;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        if (Navigator.canPop(context)) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: MockupDesign.background,
        appBar: AppBar(
        leading: BackButton(color: titleColor),
        title: Text(
          AppLocalizations.of(context)!.leaderboardTitle,
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: MockupDesign.background,
        elevation: 0,
        iconTheme: IconThemeData(color: titleColor),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppNeon.green,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: AppNeon.green,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb_outline, size: 18),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.predictors),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 18),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.bettors),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups, size: 18),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.weeklyLeague),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Consumer<SearchState>(
        builder: (context, state, _) {
          final list = state.userlist ?? [];
          final isLeagueLoading = state.isBusy || state.userlist == null;
          final topPredictors = List<UserModel>.from(list)
            ..sort((a, b) => (b.predictorScore ?? 0).compareTo(a.predictorScore ?? 0));
          final topBettors = List<UserModel>.from(list)
            ..sort((a, b) => (b.rank ?? 0).compareTo(a.rank ?? 0));
          final currentUserId = Provider.of<AuthState>(context, listen: false).userId ?? '';

          return TabBarView(
            controller: _tabController,
            children: [
              _LeaderList(
                users: topPredictors.take(50).toList(),
                scoreKey: 'predictor',
                emptyText: AppLocalizations.of(context)!.noPredictorScoreYet,
              ),
              _LeaderList(
                users: topBettors.take(50).toList(),
                scoreKey: 'bettor',
                emptyText: AppLocalizations.of(context)!.noBettorScoreYet,
              ),
              _LeagueTab(
                userlist: list,
                currentUserId: currentUserId,
                isGlobalLoading: isLeagueLoading,
              ),
            ],
          );
        },
      ),
    ),
    );
  }
}

/// Haftalık Lig sekmesi: LeagueShimmer / PreSeason boş durum / ActiveLeagueView.
class _LeagueTab extends StatelessWidget {
  const _LeagueTab({
    required this.userlist,
    required this.currentUserId,
    required this.isGlobalLoading,
  });

  final List<UserModel> userlist;
  final String currentUserId;
  final bool isGlobalLoading;

  @override
  Widget build(BuildContext context) {
    if (isGlobalLoading) {
      return const LeagueShimmer(itemCount: 8);
    }
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        fetchLeagueGroupForUser(currentUserId),
        fetchLeagueConfig(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LeagueShimmer(itemCount: 8);
        }
        final results = snapshot.data as List<dynamic>?;
        final entries = results != null && results.isNotEmpty
            ? results[0] as List<LeagueEntry>
            : <LeagueEntry>[];
        final config = results != null && results.length > 1
            ? results[1] as LeagueConfig
            : LeagueConfig();
        if (entries.isEmpty) {
          return const LeaguePreSeasonEmptyState();
        }
        return ActiveLeagueView(
          config: config,
          entries: entries,
          userlist: userlist,
          currentUserId: currentUserId,
        );
      },
    );
  }
}

class _LeaderList extends StatelessWidget {
  final List<UserModel> users;
  final String scoreKey;
  final String emptyText;

  const _LeaderList({
    required this.users,
    required this.scoreKey,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: NotifyText(title: emptyText, subTitle: ''),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final score = scoreKey == 'predictor'
            ? (user.predictorScore ?? 0)
            : (user.rank ?? 0);
        if (score == 0 && index > 10) return SizedBox.shrink();
        return _LeaderTile(
          user: user,
          rank: index + 1,
          score: score,
          isPredictor: scoreKey == 'predictor',
        );
      },
    );
  }
}

class _LeaderTile extends StatelessWidget {
  final UserModel user;
  final int rank;
  final int score;
  final bool isPredictor;

  const _LeaderTile({
    required this.user,
    required this.rank,
    required this.score,
    required this.isPredictor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreColor = isPredictor ? AppNeon.green : AppNeon.orange;
    final displayName = user.displayName ?? user.userName ?? '';
    final handle = user.userName ?? '';
    final handleText = handle.startsWith('@') ? handle : '@$handle';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/ProfilePage/${user.userId ?? ''}',
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding, vertical: 12),
          margin: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding, vertical: 4),
          decoration: BoxDecoration(
            color: MockupDesign.card.withOpacity(0.6),
            borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
            border: Border.all(color: MockupDesign.cardBorder.withOpacity(0.5), width: 1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: rank <= 3 ? scoreColor : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: customProfileImage(context, user.profilePic, userId: user.userId, height: 44),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              color: MockupDesign.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if ((user.currentStreak ?? 0) >= 3) ...[
                          SizedBox(width: 4),
                          Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: Colors.orange,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      handleText,
                      style: TextStyle(
                        color: MockupDesign.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scoreColor.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPredictor ? Icons.lightbulb_outline : Icons.emoji_events,
                      size: 16,
                      color: scoreColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '$score',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
