import 'package:toldya/model/userPegModel.dart';
import 'package:toldya/page/feed/composeToldya/state/compose_toldya_state.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:toldya/widgets/animated_bounce_button.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/utility.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

const Color _kToldyaSheetBackground = Color(0xFF1A1F2E);

class ToldyaBottomSheet {
  Widget toldyaOptionIcon(BuildContext context,
      {required FeedModel model, required ToldyaType type, required GlobalKey<ScaffoldState> scaffoldKey}) {
    return customInkWell(
        radius: BorderRadius.circular(20),
        context: context,
        onPressed: () {
          _openbottomSheet(context,
              type: type, model: model, scaffoldKey: scaffoldKey);
        },
        child: Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
              Icons.more_horiz,
              size: 24,
              color: AppColor.lightGrey,
            ),
        ));
  }

  static const Color _destructiveColor = Color(0xFFFF6B6B);
  static const Color _sheetBackground = _kToldyaSheetBackground;

  void _openbottomSheet(BuildContext context,
      {required ToldyaType type,
        required FeedModel model,
        required GlobalKey<ScaffoldState> scaffoldKey}) async {
    HapticFeedback.lightImpact();
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (sheetContext) {
        return Container(
          width: fullWidth(sheetContext),
          decoration: BoxDecoration(
            color: _sheetBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: _ToldyaActionSheetContent(
              model: model,
              type: type,
              scaffoldKey: scaffoldKey,
              parentContext: context,
            ),
          ),
        );
      },
    );
  }

  Widget _actionRow(BuildContext context,
      {required IconData icon,
        required String label,
        required bool isDestructive,
        required VoidCallback? onTap,
        bool isBusy = false}) {
    final color = isDestructive ? _destructiveColor : AppColor.textPrimaryDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isBusy ? null : onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 24, color: color),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: isDestructive ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              if (isBusy)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _addReportList(BuildContext context, FeedModel model, int statu,
      ConfirmWinner selectedRadio, GlobalKey<ScaffoldState> scaffoldKey) {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.addReportToToldya(model, authState.userId ?? '');
    if (Navigator.canPop(context)) Navigator.of(context).pop();
  }

  Future<void> _sendApproval(BuildContext context, FeedModel model, int statu,
      ConfirmWinner selectedRadio, GlobalKey<ScaffoldState> scaffoldKey) async {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    model.feedResult = selectedRadio.index;
    model.statu = statu;
    if (statu == Statu.statusOk) {
      await state.distributeWinnings(model, authState);
      if (ConfirmWinner.Like == selectedRadio) {
        model.likeList?.forEach((element) {
          authState.getuserDetail(element.userId ?? '').then((user) {
            if (user != null) {
              user.rank = (user.rank ?? 0) + calculateRank(model.likeList ?? [], element.pegCount ?? 0);
              authState.createUser(user);
            }
          });
        });
      } else {
        model.unlikeList?.forEach((element) {
          authState.getuserDetail(element.userId ?? '').then((user) {
            if (user != null) {
              user.rank = (user.rank ?? 0) + calculateRank(model.unlikeList ?? [], element.pegCount ?? 0);
              authState.createUser(user);
            }
          });
        });
      }
    }
    state.updateToldya(model);
    if (context.mounted && Navigator.canPop(context)) if (Navigator.canPop(context)) Navigator.of(context).pop();

    customSnackBar(
        scaffoldKey,
        statu == Statu.statusPending
            ? AppLocalizations.of(context)!.approvalPendingStatus
            : AppLocalizations.of(context)!.approvalSelectedForPost(
                selectedRadio.toString().split('.').last));
  }

  bool _shouldShowDispute(FeedModel model, bool isMyToldya, bool isAdmin) {
    if (isMyToldya || isAdmin) return false;
    return model.statu == Statu.statusPending || model.statu == Statu.statusOk;
  }

  bool _hasDisputed(FeedModel model, String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return model.disputeUserIds?.contains(userId) ?? false;
  }

  void _addDispute(BuildContext context, FeedModel model,
      GlobalKey<ScaffoldState> scaffoldKey) {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    final userId = authState.userId ?? '';
    if (model.disputeUserIds?.contains(userId) == true) return;
    state.addDisputeToToldya(model, userId);
    customSnackBar(scaffoldKey, AppLocalizations.of(context)!.disputeRecorded);
    if (Navigator.canPop(context)) Navigator.of(context).pop();
  }

  int calculateRank(List<UserPegModel> list, int userPeg) {
    return ((userPeg / sumOfVote(list)) * 100).round() + 3;
  }

  void _deleteToldya(BuildContext context, ToldyaType type, String toldyaId,
      {String? parentkey}) async {
    var state = Provider.of<FeedState>(context, listen: false);
    if (Navigator.canPop(context)) Navigator.of(context).pop();
    try {
      await state.deleteToldya(toldyaId, type, parentkey: parentkey);
      if (type == ToldyaType.Detail && context.mounted) {
        if (Navigator.canPop(context)) Navigator.of(context).pop();
        state.removeLastToldyaDetail(toldyaId);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.predictionDeleted)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorDeleteFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addBlackList(BuildContext context, ToldyaType type, String userId,
      {String? parentkey}) {
    var authState = Provider.of<AuthState>(context, listen: false);
    try {
      authState.addBlackList(userId);
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.userBlocked)),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorGeneric),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void openRetoldyabottomSheet(int commentFlag, BuildContext context,
      {required ToldyaType type,
        required FeedModel model,
        required GlobalKey<ScaffoldState> scaffoldKey}) async {
    HapticFeedback.lightImpact();
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).padding.bottom + 20),
          constraints: BoxConstraints(maxHeight: fullHeight(context) * 0.6),
          width: fullWidth(context),
          decoration: BoxDecoration(
            color: _sheetBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 16),
              Expanded(child: _retoldyaQuoteRow(context, model, type, commentFlag)),
            ],
          ),
        );
      },
    );
  }

  Widget _retoldyaQuoteRow(BuildContext context, FeedModel model, ToldyaType type,
      int commentFlag) {
    final totalLike = sumOfVote(model.likeList ?? []);
    final totalUnlike = sumOfVote(model.unlikeList ?? []);
    final total = totalLike + totalUnlike;
    final evetPercent = total > 0 ? (totalLike * 100 / total).round() : 50;
    final hayirPercent = total > 0 ? (totalUnlike * 100 / total).round() : 50;
    final textPrimary = AppColor.textPrimaryDark;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            model.description ?? AppLocalizations.of(context)!.prediction,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: 24),
          SliderInNavigationBar(
            model: model,
            commentFlag: commentFlag,
            yesPercent: evetPercent,
            noPercent: hayirPercent,
          ),
        ],
      ),
    );
  }

  static const Color _contentDestructiveColor = Color(0xFFFF6B6B);
  static const Color _contentSheetBackground = Color(0xFF1A1F2E);
}

class _ToldyaActionSheetContent extends StatefulWidget {
  final FeedModel model;
  final ToldyaType type;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final BuildContext parentContext;

  const _ToldyaActionSheetContent({
    required this.model,
    required this.type,
    required this.scaffoldKey,
    required this.parentContext,
  });

  @override
  State<_ToldyaActionSheetContent> createState() => _ToldyaActionSheetContentState();
}

class _ToldyaActionSheetContentState extends State<_ToldyaActionSheetContent> {
  bool _isMuteLoading = false;

  Future<void> _handleShare() async {
    final l10n = AppLocalizations.of(context)!;
    final uri = await Utility.createLinkToCopy(
      context,
      "toldya/${widget.model.key ?? ''}",
      socialMetaTagParameters: SocialMetaTagParameters(
        description: widget.model.description ??
            l10n.sharedPostDescription(widget.model.user?.displayName ?? ''),
        title: l10n.postTitle,
        imageUrl: Uri.parse(
            "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw")),
    );
    if (!mounted) return;
    if (Navigator.canPop(context)) Navigator.pop(context);
    Share.share(uri.toString(), subject: l10n.appTitle);
  }

  Future<void> _handleCopyLink() async {
    final l10n = AppLocalizations.of(context)!;
    final uri = await Utility.createLinkToCopy(
      context,
      "toldya/${widget.model.key ?? ''}",
      socialMetaTagParameters: SocialMetaTagParameters(
        description: widget.model.description ??
            l10n.sharedPostDescription(widget.model.user?.displayName ?? ''),
        title: l10n.postTitle,
        imageUrl: Uri.parse(
            "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw")),
    );
    if (!mounted) return;
    if (Navigator.canPop(context)) Navigator.pop(context);
    copyToClipBoard(
      scaffoldKey: widget.scaffoldKey,
      text: uri.toString(),
      message: l10n.copiedToClipboard,
    );
  }

  void _handleGoToProfile() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    Navigator.pushNamed(context, '/ProfilePage/${widget.model.userId}');
  }

  Future<void> _handleMuteToggle() async {
    final authState = Provider.of<AuthState>(context, listen: false);
    final postId = widget.model.key ?? '';
    if (postId.isEmpty) return;
    final isMuted = authState.isPostMuted(postId);
    setState(() => _isMuteLoading = true);
    try {
      if (isMuted) {
        await authState.removeMutedPostId(postId);
      } else {
        await authState.addMutedPostId(postId);
      }
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      final l10n = AppLocalizations.of(widget.parentContext)!;
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text(isMuted ? l10n.notificationsUnmuted : l10n.notificationsMuted)),
      );
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isMuteLoading = false);
    }
  }

  void _showReportReasonSheet() {
    final l10n = AppLocalizations.of(context)!;
    final feedState = Provider.of<FeedState>(context, listen: false);
    final authState = Provider.of<AuthState>(context, listen: false);
    final userId = authState.userId ?? '';
    if (userId.isEmpty) return;

    final reasons = [
      ('spam', l10n.reportReasonSpam),
      ('harassment', l10n.reportReasonHarassment),
      ('misleading', l10n.reportReasonMisleading),
      ('other', l10n.reportReasonOther),
    ];

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (reasonContext) {
        return Container(
          decoration: BoxDecoration(
            color: ToldyaBottomSheet._contentSheetBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 8),
                ...reasons.map((r) {
                  final (code, label) = r;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        feedState.addReportToToldyaWithReason(widget.model, userId, code);
                        if (Navigator.canPop(reasonContext)) Navigator.pop(reasonContext);
                        if (Navigator.canPop(context)) Navigator.pop(context);
                        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                          SnackBar(content: Text(l10n.reportReceived)),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, size: 24, color: ToldyaBottomSheet._contentDestructiveColor),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: AppColor.textPrimaryDark,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleBlockUnblock() {
    final authState = Provider.of<AuthState>(context, listen: false);
    final targetUserId = widget.model.userId ?? '';
    if (targetUserId.isEmpty) return;
    final isInBlackList = authState.userModel?.blackList?.contains(targetUserId) ?? false;
    try {
      authState.addBlackList(targetUserId);
      if (Navigator.canPop(context)) Navigator.pop(context);
      final l10n = AppLocalizations.of(widget.parentContext)!;
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text(isInBlackList ? l10n.userUnblocked : l10n.userBlocked)),
      );
    } catch (_) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric), backgroundColor: Colors.red),
      );
    }
  }

  void _handleDelete() {
    final state = Provider.of<FeedState>(context, listen: false);
    if (Navigator.canPop(context)) Navigator.pop(context);
    state.deleteToldya(widget.model.key ?? '', widget.type, parentkey: widget.model.parentkey).then((_) {
      if (widget.parentContext.mounted) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(widget.parentContext)!.predictionDeleted)),
        );
      }
      if (widget.type == ToldyaType.Detail && widget.parentContext.mounted) {
        Navigator.of(widget.parentContext).pop();
        state.removeLastToldyaDetail(widget.model.key ?? '');
      }
    }).catchError((_) {
      if (widget.parentContext.mounted) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(widget.parentContext)!.errorDeleteFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required bool isDestructive,
    required VoidCallback? onTap,
    bool isBusy = false,
  }) {
    final color = isDestructive ? ToldyaBottomSheet._contentDestructiveColor : AppColor.textPrimaryDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isBusy ? null : onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 24, color: color),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: isDestructive ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              if (isBusy)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context, listen: true);
    final isMyPost = authState.userId == widget.model.userId;
    final l10n = AppLocalizations.of(context)!;
    final isMuted = authState.isPostMuted(widget.model.key ?? '');
    final isInBlackList = authState.userModel?.blackList?.contains(widget.model.userId ?? '') ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(height: 8),
        _buildRow(
          icon: Icons.share_outlined,
          label: l10n.share,
          isDestructive: false,
          onTap: _handleShare,
        ),
        _buildRow(
          icon: Icons.link_outlined,
          label: l10n.copyLink,
          isDestructive: false,
          onTap: _handleCopyLink,
        ),
        if (!isMyPost)
          _buildRow(
            icon: Icons.person_outline,
            label: l10n.goToProfile,
            isDestructive: false,
            onTap: _handleGoToProfile,
          ),
        _buildRow(
          icon: isMuted ? Icons.notifications_outlined : Icons.notifications_off_outlined,
          label: isMuted ? l10n.unmuteNotificationsForPost : l10n.muteNotificationsForPost,
          isDestructive: false,
          onTap: _handleMuteToggle,
          isBusy: _isMuteLoading,
        ),
        if (isMyPost) ...[
          _buildRow(
            icon: Icons.edit_outlined,
            label: l10n.editPrediction,
            isDestructive: false,
            onTap: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
              Provider.of<FeedState>(context, listen: false).setToldyaToEdit = widget.model;
              Navigator.pushNamed(context, '/CreateFeedPage/toldya');
            },
          ),
          _buildRow(
            icon: Icons.delete_outlined,
            label: l10n.delete,
            isDestructive: true,
            onTap: _handleDelete,
          ),
        ] else ...[
          _buildRow(
            icon: Icons.flag_outlined,
            label: l10n.report,
            isDestructive: true,
            onTap: _showReportReasonSheet,
          ),
          _buildRow(
            icon: Icons.block_outlined,
            label: isInBlackList
                ? l10n.unblockUser(widget.model.user?.displayName ?? '')
                : l10n.blockUser(widget.model.user?.displayName ?? ''),
            isDestructive: true,
            onTap: _handleBlockUnblock,
          ),
        ],
        SizedBox(height: 20),
      ],
    );
  }
}

enum _StakeSide { yes, no }

class SliderInNavigationBar extends StatefulWidget {
  final FeedModel model;
  final int commentFlag;
  final int yesPercent;
  final int noPercent;

  SliderInNavigationBar({
    Key? key,
    required this.model,
    this.commentFlag = 0,
    required this.yesPercent,
    required this.noPercent,
  })
      : super(key: key);

  @override
  _SliderInNavigationBarScreenState createState() =>
      _SliderInNavigationBarScreenState();
}

class _SliderInNavigationBarScreenState extends State<SliderInNavigationBar> {
  static const Color _neonYes = Color(0xFF2ED573);
  static const Color _neonNo = Color(0xFFFF4757);

  late TextEditingController _amountController;
  late _StakeSide _side;
  bool _isPlacingStake = false;
  bool _showSuccess = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '0');
    _side = widget.commentFlag == AppIcon.hayirCommentFlag
        ? _StakeSide.no
        : _StakeSide.yes;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int _commentFlagForSide(_StakeSide s) =>
      s == _StakeSide.yes ? AppIcon.evetCommentFlag : AppIcon.hayirCommentFlag;

  int _maxVal(int balance, int xp, int totalPool) {
    if (balance <= 0) return 0;
    // TEMP: Aggressive max stake cap = 75% of spendable balance.
    // (Rank/pool limits are intentionally disabled for now; can be re-enabled later.)
    return (balance * 0.75).floor();
  }

  int _parseAmount() {
    final t = _amountController.text.trim();
    if (t.isEmpty) return 0;
    return int.tryParse(t) ?? 0;
  }

  void _setAmountClamped(int v, int maxVal) {
    final c = v.clamp(0, maxVal);
    _amountController.text = c == 0 ? '0' : '$c';
    _amountController.selection = TextSelection.collapsed(
        offset: _amountController.text.length);
  }

  /// Rough pari-mutuel estimate if selected side wins (after fee).
  double? _estimateReturn(int stake, _StakeSide side, FeedModel m) {
    if (stake <= 0) return null;
    final totalYes = sumOfVote(m.likeList ?? []);
    final totalNo = sumOfVote(m.unlikeList ?? []);
    if (totalYes + totalNo <= 0) return null;
    final fee = AppIcon.commissionRate;
    if (side == _StakeSide.yes) {
      final newYes = totalYes + stake;
      if (newYes <= 0) return null;
      return stake + (stake / newYes) * totalNo * (1 - fee);
    } else {
      final newNo = totalNo + stake;
      if (newNo <= 0) return null;
      return stake + (stake / newNo) * totalYes * (1 - fee);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Selector<AuthState, ({int peg, int xp})>(
      selector: (_, a) => (
        peg: a.userModel?.pegCount ?? 0,
        xp: a.userModel?.xp ?? 0,
      ),
      builder: (context, bal, __) {
        final authState = Provider.of<AuthState>(context, listen: false);
        final state = Provider.of<FeedState>(context, listen: false);
        final stakeInFlight = context.select<FeedState, bool>(
          (s) => s.isStakeInFlight(widget.model.key),
        );
        final userId = authState.userId;
        final totalPool = sumOfVote(widget.model.likeList ?? []) +
            sumOfVote(widget.model.unlikeList ?? []);
        final maxVal = _maxVal(bal.peg, bal.xp, totalPool);
        final canYes = userId == null ||
            !userAlreadyStakedOtherSide(
                widget.model, userId, AppIcon.evetCommentFlag);
        final canNo = userId == null ||
            !userAlreadyStakedOtherSide(
                widget.model, userId, AppIcon.hayirCommentFlag);

        if (!canYes && _side == _StakeSide.yes && canNo) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _side = _StakeSide.no);
          });
        } else if (!canNo && _side == _StakeSide.no && canYes) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _side = _StakeSide.yes);
          });
        }

        Future<void> send() async {
          final amount = _parseAmount();
          if (amount <= 0) {
            setState(() => _inlineError = l10n.pleaseSelectStakeAmount);
            return;
          }
          if (amount > maxVal) {
            setState(() => _inlineError = l10n.maxStakeTokens('$maxVal'));
            return;
          }
          final flag = _commentFlagForSide(_side);
          if (userAlreadyStakedOtherSide(widget.model, userId, flag)) {
            setState(() => _inlineError = l10n.stakeOneSideOnly);
            return;
          }
          if (!mounted) return;
          setState(() {
            _isPlacingStake = true;
            _inlineError = null;
          });
          try {
            await state.placeBet(
              authState,
              widget.model,
              authState.userId ?? '',
              amount,
              flag,
              context: context,
            );
            authState.getuserDetail(widget.model.userId ?? '').then((user) {
              final ownUser = authState.userModel;
              if (user != null && ownUser != null && context.mounted) {
                Provider.of<ComposeToldyaState>(context, listen: false)
                    .sendNotificationToFeed(
                        widget.model, user, ownUser, flag, amount)
                    .then((_) {});
              }
            });
            if (context.mounted) {
              setState(() => _showSuccess = true);
              Future.delayed(const Duration(milliseconds: 350), () {
                if (!context.mounted) return;
                if (Navigator.canPop(context)) Navigator.pop(context);
              });
            }
          } on PlatformException catch (e) {
            if (mounted) {
              setState(() {
                _isPlacingStake = false;
                _inlineError = l10n.gmsError(
                    e.message ?? e.code ?? l10n.unknownError);
              });
            }
          } on FirebaseFunctionsException catch (e) {
            if (context.mounted) {
              String errorMessage = l10n.stakeErrorGeneric;
              if (e.code.toLowerCase() == 'internal') {
                errorMessage = l10n.gmsUpdateMessage;
              } else if (e.message != null && e.message!.isNotEmpty) {
                errorMessage = e.message!;
              } else if (e.code.isNotEmpty) {
                errorMessage = l10n.errorWithMessage(e.code);
              }
              setState(() {
                _isPlacingStake = false;
                _inlineError = errorMessage;
              });
            }
          } catch (e) {
            if (context.mounted) {
              final msg = e.toString().length > 120
                  ? '${e.toString().substring(0, 120)}...'
                  : e.toString();
              setState(() {
                _isPlacingStake = false;
                _inlineError = l10n.errorWithMessage(msg);
              });
            }
          }
        }

        final stake = _parseAmount();
        final est = _estimateReturn(stake, _side, widget.model);
        final estRounded =
            est != null ? est.round().clamp(0, 999999999).toString() : null;
        final busy = _isPlacingStake || stakeInFlight;
        final textSecondary = AppColor.textSecondaryDark;
        final surfaceColor = MockupDesign.card;
        const presetAmounts = [10, 25, 50, 100];
        final validPresets = presetAmounts.where((a) => a <= maxVal).toList();

        Widget submitBtn = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: busy
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    setState(() => _inlineError = null);
                    send();
                  },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: busy
                    ? Colors.grey.shade700
                    : (_side == _StakeSide.yes ? _neonYes : _neonNo),
                borderRadius: BorderRadius.circular(14),
                boxShadow: busy
                    ? null
                    : [
                        BoxShadow(
                          color: (_side == _StakeSide.yes ? _neonYes : _neonNo)
                              .withOpacity(0.45),
                          blurRadius: 16,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: busy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      _side == _StakeSide.yes
                          ? l10n.stakeSheetSubmitYes
                          : l10n.stakeSheetSubmitNo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        );
        if (_showSuccess) {
          submitBtn = submitBtn
              .animate()
              .scale(duration: 300.ms, begin: const Offset(0.96, 0.96));
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_inlineError != null) ...[
              Text(
                _inlineError!,
                style: const TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: _sideChip(
                    label: l10n.stakeSheetSideYes,
                    percent: widget.yesPercent,
                    active: _side == _StakeSide.yes,
                    enabled: canYes,
                    neon: _neonYes,
                    onTap: busy
                        ? null
                        : () {
                            if (!canYes) return;
                            setState(() {
                              _side = _StakeSide.yes;
                              _inlineError = null;
                              _setAmountClamped(_parseAmount(), maxVal);
                            });
                          },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _sideChip(
                    label: l10n.stakeSheetSideNo,
                    percent: widget.noPercent,
                    active: _side == _StakeSide.no,
                    enabled: canNo,
                    neon: _neonNo,
                    onTap: busy
                        ? null
                        : () {
                            if (!canNo) return;
                            setState(() {
                              _side = _StakeSide.no;
                              _inlineError = null;
                              _setAmountClamped(_parseAmount(), maxVal);
                            });
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.availableBalanceTokens('${bal.peg}'),
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.maxStakeTokens('$maxVal'),
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 2),
            const SizedBox(height: 8),
            Text(
              l10n.stakeAmountLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textSecondary.withOpacity(0.85),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _amountController,
              enabled: !busy && maxVal > 0,
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (s) {
                if (s.isEmpty) {
                  setState(() {});
                  return;
                }
                var v = int.tryParse(s) ?? 0;
                if (v > maxVal) {
                  _amountController.value = TextEditingValue(
                    text: '$maxVal',
                    selection:
                        TextSelection.collapsed(offset: '$maxVal'.length),
                  );
                  v = maxVal;
                }
                setState(() => _inlineError = null);
              },
            ),
            if (maxVal <= 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.tokenInsufficient,
                  style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ...validPresets.map((add) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: busy || maxVal <= 0
                          ? null
                          : () {
                              setState(() {
                                final next =
                                    (_parseAmount() + add).clamp(0, maxVal);
                                _setAmountClamped(next, maxVal);
                                _inlineError = null;
                              });
                            },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: MockupDesign.cardBorder),
                        ),
                        child: Text(
                          '+$add',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textPrimaryDark,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: busy || maxVal <= 0
                        ? null
                        : () {
                            setState(() {
                              _setAmountClamped(maxVal, maxVal);
                              _inlineError = null;
                            });
                          },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: MockupDesign.accentCyan.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: MockupDesign.accentCyan.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        l10n.stakeSheetMaxButton,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: MockupDesign.accentCyan,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (stake > 0) ...[
              Text(
                estRounded != null
                    ? l10n.potentialReturnEstimate(estRounded)
                    : l10n.potentialReturnUnavailable,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: estRounded != null
                      ? const Color(0xFF69F0AE)
                      : textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.potentialReturnDisclaimer,
                style: TextStyle(
                  fontSize: 10,
                  color: textSecondary.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 8),
            submitBtn,
          ],
        );
      },
    );
  }

  Widget _sideChip({
    required String label,
    required int percent,
    required bool active,
    required bool enabled,
    required Color neon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active && enabled
                ? neon.withOpacity(0.22)
                : MockupDesign.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active && enabled
                  ? neon
                  : Colors.white.withOpacity(enabled ? 0.12 : 0.06),
              width: active && enabled ? 2 : 1,
            ),
            boxShadow: active && enabled
                ? [
                    BoxShadow(
                      color: neon.withOpacity(0.5),
                      blurRadius: 14,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: !enabled
                      ? Colors.white.withOpacity(0.25)
                      : (active
                          ? Colors.white
                          : Colors.white.withOpacity(0.45)),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: !enabled
                      ? Colors.white.withOpacity(0.18)
                      : (active
                          ? Colors.white.withOpacity(0.95)
                          : Colors.white.withOpacity(0.28)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
