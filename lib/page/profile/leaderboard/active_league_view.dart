import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/model/league.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/widgets/customWidgets.dart';

/// Tek bir lig satırı: sıra, avatar, isim, haftalık XP; yeşil/kırmızı bölge ve mevcut kullanıcı border.
const double _kLeagueTileHeight = 72.0;

class _LeagueTile extends StatelessWidget {
  const _LeagueTile({
    required this.user,
    required this.rank,
    required this.weeklyXp,
    required this.isCurrentUser,
    required this.zone,
  });

  final UserModel user;
  final int rank;
  final int weeklyXp;
  final bool isCurrentUser;
  final _Zone zone;

  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName ?? user.userName ?? '';
    final handle = user.userName ?? '';
    final handleText = handle.startsWith('@') ? handle : '@$handle';
    Color? bgColor;
    Widget? zoneIcon;
    if (zone == _Zone.promotion) {
      bgColor = AppNeon.green.withOpacity(0.12);
      zoneIcon = Icon(Icons.arrow_upward, size: 16, color: AppNeon.green);
    } else if (zone == _Zone.demotion) {
      bgColor = AppNeon.red.withOpacity(0.12);
      zoneIcon = Icon(Icons.arrow_downward, size: 16, color: AppNeon.red);
    }
    const accentBorder = Color(0xFFFF6B6B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, '/ProfilePage/${user.userId ?? ''}');
        },
        child: Container(
          height: _kLeagueTileHeight,
          padding: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding, vertical: 12),
          margin: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor ?? MockupDesign.card.withOpacity(0.6),
            borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
            border: Border.all(
              color: isCurrentUser ? accentBorder : MockupDesign.cardBorder.withOpacity(0.5),
              width: isCurrentUser ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (zoneIcon != null) ...[zoneIcon, SizedBox(width: 4)],
                    Text(
                      '$rank',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: rank <= 3 ? AppNeon.green : MockupDesign.textPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        color: MockupDesign.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      handleText,
                      style: TextStyle(color: MockupDesign.textSecondary, fontSize: 13),
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
                  color: AppNeon.green.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppNeon.green.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, size: 16, color: AppNeon.green),
                    SizedBox(width: 4),
                    Text(
                      '$weeklyXp',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppNeon.green,
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

enum _Zone { none, promotion, demotion }

/// Aktif lig görünümü: CustomScrollView + SliverAppBar (rozet + geri sayım) + 30 kişi listesi;
/// üst 5 yeşil, alt 5 kırmızı; mevcut kullanıcı satırı vurgulu; scroll’da pinned satır.
class ActiveLeagueView extends StatefulWidget {
  const ActiveLeagueView({
    Key? key,
    required this.config,
    required this.entries,
    required this.userlist,
    required this.currentUserId,
  }) : super(key: key);

  final LeagueConfig config;
  final List<LeagueEntry> entries;
  final List<UserModel> userlist;
  final String currentUserId;

  @override
  State<ActiveLeagueView> createState() => _ActiveLeagueViewState();
}

class _ActiveLeagueViewState extends State<ActiveLeagueView> {
  final ScrollController _scrollController = ScrollController();
  Timer? _countdownTimer;
  bool _showPinnedRow = false;

  int get _currentUserIndex {
    final i = widget.entries.indexWhere((e) => e.userId == widget.currentUserId);
    return i >= 0 ? i : 0;
  }

  UserModel _userForEntry(LeagueEntry entry) {
    try {
      return widget.userlist.firstWhere((u) => u.userId == entry.userId);
    } catch (_) {
      return UserModel(
        userId: entry.userId,
        displayName: entry.userId,
        userName: entry.userId,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted || widget.entries.isEmpty) return;
    final offset = _scrollController.offset;
    final viewport = _scrollController.position.viewportDimension;
    const itemHeight = _kLeagueTileHeight + 8;
    final firstVisible = (offset / itemHeight).floor();
    final lastVisible = ((offset + viewport) / itemHeight).floor();
    final show = _currentUserIndex < firstVisible || _currentUserIndex > lastVisible;
    if (show != _showPinnedRow) setState(() => _showPinnedRow = show);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tierName = _tierDisplayName();
    final countdown = _buildCountdown(l10n);

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: MockupDesign.background,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: MockupDesign.background,
                  padding: EdgeInsets.fromLTRB(
                    MockupDesign.screenPadding,
                    MediaQuery.of(context).padding.top + 8,
                    MockupDesign.screenPadding,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emoji_events, color: const Color(0xFFFF6B6B), size: 28),
                          SizedBox(width: 8),
                          Text(
                            tierName,
                            style: TextStyle(
                              color: MockupDesign.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        countdown,
                        style: TextStyle(
                          color: MockupDesign.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = widget.entries[index];
                  final rank = index + 1;
                  _Zone zone = _Zone.none;
                  if (rank <= 5) zone = _Zone.promotion;
                  if (rank >= 26) zone = _Zone.demotion;
                  final user = _userForEntry(entry);
                  final isCurrentUser = entry.userId == widget.currentUserId;
                  return _LeagueTile(
                    user: user,
                    rank: rank,
                    weeklyXp: entry.xpSnapshot,
                    isCurrentUser: isCurrentUser,
                    zone: zone,
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
                },
                childCount: widget.entries.length,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: _showPinnedRow ? _kLeagueTileHeight + 16 : 0)),
          ],
        ),
        if (_showPinnedRow && widget.entries.isNotEmpty) _buildPinnedRow(),
      ],
    );
  }

  String _tierDisplayName() {
    UserModel? currentUser;
    try {
      currentUser = widget.userlist.firstWhere((u) => u.userId == widget.currentUserId);
    } catch (_) {}
    final tier = currentUser?.tier ?? 'Bronze';
    final names = widget.config.tierNames;
    if (names.isNotEmpty) {
      final idx = names.indexWhere((n) => n.toLowerCase() == tier.toLowerCase());
      if (idx >= 0) return names[idx];
    }
    return tier;
  }

  String _buildCountdown(AppLocalizations l10n) {
    final weekEndsAt = widget.config.weekEndsAt;
    if (weekEndsAt == null || weekEndsAt.isEmpty) return '';
    DateTime? end;
    try {
      end = DateTime.parse(weekEndsAt);
    } catch (_) {
      return '';
    }
    final now = DateTime.now().toUtc();
    if (end.isBefore(now)) return '';
    final diff = end.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    return l10n.leagueCountdown(days, hours);
  }

  Widget _buildPinnedRow() {
    final entry = widget.entries[_currentUserIndex];
    final user = _userForEntry(entry);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        elevation: 8,
        color: MockupDesign.background,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: _LeagueTile(
              user: user,
              rank: _currentUserIndex + 1,
              weeklyXp: entry.xpSnapshot,
              isCurrentUser: true,
              zone: _currentUserIndex < 5
                  ? _Zone.promotion
                  : (_currentUserIndex >= 25 ? _Zone.demotion : _Zone.none),
            ),
          ),
        ),
      ),
    );
  }
}
