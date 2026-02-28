import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/state/searchState.dart';
import 'package:bendemistim/widgets/customAppBar.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';
import 'package:bendemistim/widgets/newWidget/emptyList.dart';
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
    _tabController = TabController(length: 2, vsync: this);
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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: BackButton(),
        title: customTitleText('Liderlik Tablosu'),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb_outline, size: 18),
                  SizedBox(width: 8),
                  Text('Tahminciler'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 18),
                  SizedBox(width: 8),
                  Text('Bahisçiler'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Consumer<SearchState>(
        builder: (context, state, _) {
          if (state.isBusy || state.userlist == null) {
            return Center(
              child: CustomScreenLoader(
                height: 80,
                width: 80,
                backgroundColor: Colors.transparent,
              ),
            );
          }
          final list = state.userlist ?? [];
          final topPredictors = List<UserModel>.from(list)
            ..sort((a, b) => (b.predictorScore ?? 0).compareTo(a.predictorScore ?? 0));
          final topBettors = List<UserModel>.from(list)
            ..sort((a, b) => (b.rank ?? 0).compareTo(a.rank ?? 0));

          return TabBarView(
            controller: _tabController,
            children: [
              _LeaderList(
                users: topPredictors.take(50).toList(),
                scoreKey: 'predictor',
                emptyText: 'Henüz tahminci skoru yok',
              ),
              _LeaderList(
                users: topBettors.take(50).toList(),
                scoreKey: 'bettor',
                emptyText: 'Henüz bahisçi skoru yok',
              ),
            ],
          );
        },
      ),
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
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: rank <= 3 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          SizedBox(width: 8),
          customProfileImage(context, user.profilePic, userId: user.userId, height: 48),
        ],
      ),
      title: Row(
        children: [
          customText(
            user.displayName ?? user.userName ?? '',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          if (user.isVerified ?? false) ...[
            SizedBox(width: 4),
            Icon(Icons.verified, size: 16, color: HexColor('#1DA1F2')),
          ],
        ],
      ),
      subtitle: customText('@${user.userName ?? ''}', style: userNameStyle),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: (isPredictor ? HexColor('#4CAF50') : HexColor('#FFA400'))
              .withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPredictor ? Icons.lightbulb_outline : Icons.emoji_events,
              size: 18,
              color: isPredictor ? HexColor('#4CAF50') : HexColor('#FFA400'),
            ),
            SizedBox(width: 6),
            Text(
              '$score',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPredictor ? HexColor('#4CAF50') : HexColor('#FFA400'),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/ProfilePage/${user.userId ?? ''}',
        );
      },
    );
  }
}
