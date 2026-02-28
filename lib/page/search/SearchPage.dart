import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/helper/topicMap.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/state/searchState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/tweet/prediction_card_mockup.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _searchSubmitted = false;
  int _selectedCategoryIndex = 0;
  final List<String> _recentSearches = [];

  static const List<String> _categoryLabels = ['🔥 Trendler', '⚽ Spor', '📈 Ekonomi', '🎭 Eğlence'];
  static const List<String> _categoryTopicValues = ['Akış', 'Spor', 'Ekonomi', 'Eğlence'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<SearchState>(context, listen: false);
      state.resetFilterList();
    });
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(() => setState(() {}));
  }

  void _onSearchChanged() {
    final state = Provider.of<SearchState>(context, listen: false);
    state.filterByUsername(_searchController.text);
    if (_searchController.text.isEmpty) {
      setState(() => _searchSubmitted = false);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isDiscover =>
      _searchController.text.isEmpty && !_focusNode.hasFocus && !_searchSubmitted;

  bool get _isActiveSearch =>
      !_searchSubmitted && (_searchController.text.isNotEmpty || _focusNode.hasFocus);

  bool get _isResults => _searchSubmitted;

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _searchSubmitted = true;
        if (!_recentSearches.contains(query)) {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 10) _recentSearches.removeLast();
        }
      });
    }
  }

  void _removeRecentSearch(String item) {
    setState(() => _recentSearches.remove(item));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MockupDesign.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchBar(context),
            Expanded(
              child: _isDiscover
                  ? _buildDiscoverView(context)
                  : _isActiveSearch
                      ? _buildActiveSearchView(context)
                      : _buildResultsView(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Sabit üst kısım: kapsül arama çubuğu
  Widget _buildSearchBar(BuildContext context) {
    final hasText = _searchController.text.isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(MockupDesign.screenPadding, 12, MockupDesign.screenPadding, 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onSubmitted: (_) => _submitSearch(),
          style: TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: 'Ara...',
            hintStyle: TextStyle(color: Colors.white54, fontSize: 16),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 24,
            ),
            suffixIcon: hasText
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchSubmitted = false);
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  /// 2. Durum 1: Keşfet – kategori hapları + Trend Tahminler
  Widget _buildDiscoverView(BuildContext context) {
    final authState = Provider.of<AuthState>(context, listen: false);
    final feedState = Provider.of<FeedState>(context);
    final searchState = Provider.of<SearchState>(context);
    final topicVal = _categoryTopicValues[_selectedCategoryIndex];
    final list = feedState.getToldyaListByTopic(
      authState.userModel,
      searchState.getUserInBlackList(authState.userModel),
      '',
      Statu.statusLive,
      topic_val: topicVal,
    );

    return RefreshIndicator(
      onRefresh: () async {
        Provider.of<SearchState>(context, listen: false).getDataFromDatabase();
        return Future.value();
      },
      child: ListView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.only(bottom: 24),
        children: [
          _buildCategoryChips(context),
          Padding(
            padding: EdgeInsets.fromLTRB(MockupDesign.screenPadding, 20, MockupDesign.screenPadding, 12),
            child: Text(
              'Trend Tahminler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          if (list.isEmpty)
            Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Bu kategoride tahmin yok',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ),
            )
          else
            ...list.take(20).map((model) => _CompactPredictionCard(
                  model: model,
                  scaffoldKey: widget.scaffoldKey ?? GlobalKey<ScaffoldState>(),
                )),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding),
      child: Row(
        children: List.generate(_categoryLabels.length, (i) {
          final selected = _selectedCategoryIndex == i;
          return Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = i),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? Colors.transparent : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppNeon.green : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _categoryLabels[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 3. Durum 2: Aktif arama – Son Aramalar + Canlı Öneriler
  Widget _buildActiveSearchView(BuildContext context) {
    final searchState = Provider.of<SearchState>(context);
    final authState = Provider.of<AuthState>(context, listen: false);
    final feedState = Provider.of<FeedState>(context);
    final searchStateBlackList = searchState.getUserInBlackList(authState.userModel);
    final query = _searchController.text.trim();
    final userList = searchState.userlist ?? [];
    final predictionList = query.isEmpty
        ? <FeedModel>[]
        : feedState.getToldyaListByTopic(
            authState.userModel,
            searchStateBlackList,
            query,
            Statu.statusLive,
            topic_val: topic.gundem,
          );

    return ListView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(MockupDesign.screenPadding, 8, MockupDesign.screenPadding, 8),
            child: Text(
              'Son Aramalar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          ..._recentSearches.map((item) => ListTile(
                leading: Icon(Icons.history, color: Colors.grey.shade500, size: 22),
                title: Text(
                  item,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: Colors.grey.shade500, size: 20),
                  onPressed: () => _removeRecentSearch(item),
                ),
              )),
          Divider(height: 1, color: Colors.white10),
        ],
        Padding(
          padding: EdgeInsets.fromLTRB(MockupDesign.screenPadding, 16, MockupDesign.screenPadding, 8),
          child: Text(
            'Canlı Öneriler',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade400,
            ),
          ),
        ),
        if (userList.isEmpty && predictionList.isEmpty)
          Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Sonuç yok',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          )
        else ...[
          ...userList.take(15).map((user) => _SuggestionUserTile(
                user: user,
                onTap: () {
                  kAnalytics.logViewSearchResults(searchTerm: user.userName ?? '');
                  Navigator.of(context).pushNamed('/ProfilePage/${user.userId}');
                },
              )),
          ...predictionList.take(10).map((model) => _SuggestionPredictionTile(
                model: model,
                onTap: () {
                  Provider.of<FeedState>(context, listen: false)
                      .getpostDetailFromDatabase(model.key ?? '', model: model);
                  Navigator.of(context).pushNamed('/FeedPostDetail/${model.key}');
                },
              )),
        ],
      ],
    );
  }

  /// 4. Durum 3: Sonuçlar – TabBar (Tahminler / Kişiler)
  Widget _buildResultsView(BuildContext context) {
    final query = _searchController.text.trim();
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: MockupDesign.background,
            child: TabBar(
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3, color: AppNeon.green),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              tabs: [
                Tab(text: 'Tahminler'),
                Tab(text: 'Kişiler'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ResultsPredictionsTab(
                  query: query,
                  scaffoldKey: widget.scaffoldKey ?? GlobalKey<ScaffoldState>(),
                ),
                _ResultsPeopleTab(query: query),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Keşfet: kompakt tahmin kartı (dar padding)
class _CompactPredictionCard extends StatelessWidget {
  final FeedModel model;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _CompactPredictionCard({Key? key, required this.model, required this.scaffoldKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding, vertical: 6),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: MockupDesign.card,
          borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
          border: Border.all(color: MockupDesign.cardBorder),
        ),
        child: PredictionCardMockup(model: model, scaffoldKey: scaffoldKey),
      ),
    );
  }
}

/// Canlı öneri: kullanıcı satırı
class _SuggestionUserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _SuggestionUserTile({Key? key, required this.user, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final handle = user.userName ?? user.displayName ?? '';
    final displayHandle = handle.startsWith('@') ? handle : '@$handle';
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade800,
        child: ClipOval(
          child: customProfileImage(context, user.profilePic, userId: user.userId, height: 44),
        ),
      ),
      title: Text(
        displayHandle.isEmpty ? 'Kullanıcı' : displayHandle,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        user.displayName ?? '',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Canlı öneri: tahmin satırı
class _SuggestionPredictionTile extends StatelessWidget {
  final FeedModel model;
  final VoidCallback onTap;

  const _SuggestionPredictionTile({Key? key, required this.model, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final desc = model.description ?? '';
    final short = desc.length > 60 ? '${desc.substring(0, 60)}...' : desc;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppNeon.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.analytics_outlined, color: AppNeon.green, size: 22),
      ),
      title: Text(
        short.isEmpty ? 'Tahmin' : short,
        style: TextStyle(color: Colors.white, fontSize: 14),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Sonuçlar: Tahminler sekmesi
class _ResultsPredictionsTab extends StatelessWidget {
  final String query;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _ResultsPredictionsTab({Key? key, required this.query, required this.scaffoldKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context, listen: false);
    final feedState = Provider.of<FeedState>(context);
    final searchState = Provider.of<SearchState>(context);
    final list = feedState.getToldyaListByTopic(
      authState.userModel,
      searchState.getUserInBlackList(authState.userModel),
      query,
      Statu.statusLive,
      topic_val: topic.gundem,
    );

    if (list.isEmpty) {
      return Center(
        child: Text(
          'Tahmin sonucu yok',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, i) => _CompactPredictionCard(
        model: list[i],
        scaffoldKey: scaffoldKey,
      ),
    );
  }
}

/// Sonuçlar: Kişiler sekmesi (Avatar + ad + Takip Et)
class _ResultsPeopleTab extends StatelessWidget {
  final String query;

  const _ResultsPeopleTab({Key? key, required this.query}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchState = Provider.of<SearchState>(context);
    final authState = Provider.of<AuthState>(context, listen: false);
    final userList = searchState.userlist ?? [];
    final myId = authState.userModel?.userId;
    final isMe = (String? uid) => uid != null && uid == myId;

    if (userList.isEmpty) {
      return Center(
        child: Text(
          'Kişi sonucu yok',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding, vertical: 8),
      itemCount: userList.length,
      itemBuilder: (context, i) {
        final user = userList[i];
        final following = (user.followersList ?? []).contains(myId);
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: MockupDesign.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MockupDesign.cardBorder),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    kAnalytics.logViewSearchResults(searchTerm: user.userName ?? '');
                    Navigator.of(context).pushNamed('/ProfilePage/${user.userId}');
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade800,
                    child: ClipOval(
                      child: customProfileImage(
                          context, user.profilePic, userId: user.userId, height: 48),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      kAnalytics.logViewSearchResults(searchTerm: user.userName ?? '');
                      Navigator.of(context).pushNamed('/ProfilePage/${user.userId}');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? user.userName ?? 'Kullanıcı',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.userName != null ? '@${user.userName}' : '',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isMe(user.userId))
                  OutlinedButton(
                    onPressed: () {
                      authState.followUser(removeFollower: following);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: following ? Colors.grey : AppNeon.green,
                      side: BorderSide(
                          color: following ? Colors.grey.shade600 : AppNeon.green),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size(0, 36),
                    ),
                    child: Text(
                      following ? 'Takip ediliyor' : 'Takip Et',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
