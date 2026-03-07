import 'package:toldya/model/userPegModel.dart';
import 'package:toldya/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          child: customIcon(context,
              icon: AppIcon.arrowDown,
              istwitterIcon: true,
              iconColor: AppColor.lightGrey),
        ));
  }

  static const Color _destructiveColor = Color(0xFFFF6B6B);
  static const Color _sheetBackground = _kToldyaSheetBackground;

  void _openbottomSheet(BuildContext context,
      {required ToldyaType type,
        required FeedModel model,
        required GlobalKey<ScaffoldState> scaffoldKey}) async {
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
              Expanded(child: _retweet(context, model, type, commentFlag)),
            ],
          ),
        );
      },
    );
  }

  Widget _retweet(BuildContext context, FeedModel model, ToldyaType type,
      int commentFlag) {
    final totalLike = sumOfVote(model.likeList ?? []);
    final totalUnlike = sumOfVote(model.unlikeList ?? []);
    final total = totalLike + totalUnlike;
    final evetPercent = total > 0 ? (totalLike * 100 / total).round() : 50;
    final hayirPercent = total > 0 ? (totalUnlike * 100 / total).round() : 50;
    final isEvet = commentFlag == 0;
    const evetGreen = Color(0xFF2E7D32);
    const hayirGray = Color(0xFF3D3D4A);
    const evetBorder = Color(0xFF4CAF50);
    const hayirBorder = Color(0xFFE53935);
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
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isEvet ? evetGreen.withOpacity(0.3) : hayirGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEvet ? evetBorder : Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.yes, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
                      Text('$evetPercent%', style: TextStyle(fontSize: 14, color: isEvet ? Color(0xFF81C784) : AppColor.textSecondaryDark)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: !isEvet ? hayirBorder.withOpacity(0.25) : hayirGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: !isEvet ? hayirBorder : Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.no, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
                      Text('$hayirPercent%', style: TextStyle(fontSize: 14, color: !isEvet ? Color(0xFFE57373) : AppColor.textSecondaryDark)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          SliderInNavigationBar(model: model, commentFlag: commentFlag),
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
  bool _isFollowLoading = false;
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

  Future<void> _handleFollowUnfollow() async {
    final authState = Provider.of<AuthState>(context, listen: false);
    final isFollowing = authState.userModel?.followingList?.contains(widget.model.userId ?? '') ?? false;
    final targetUserId = widget.model.userId ?? '';
    if (targetUserId.isEmpty) return;
    setState(() => _isFollowLoading = true);
    try {
      await authState.followUserByUserId(targetUserId, removeFollower: isFollowing);
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      final l10n = AppLocalizations.of(widget.parentContext)!;
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text(isFollowing ? l10n.unfollowSuccess : l10n.followSuccess)),
      );
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isFollowLoading = false);
    }
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
    final isFollowing = authState.userModel?.followingList?.contains(widget.model.userId ?? '') ?? false;
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
        if (!isMyPost) ...[
          _buildRow(
            icon: Icons.person_outline,
            label: l10n.goToProfile,
            isDestructive: false,
            onTap: _handleGoToProfile,
          ),
          _buildRow(
            icon: isFollowing ? Icons.person_remove_outlined : Icons.person_add_outlined,
            label: isFollowing ? l10n.unfollow : l10n.follow,
            isDestructive: false,
            onTap: _handleFollowUnfollow,
            isBusy: _isFollowLoading,
          ),
        ],
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

class SliderInNavigationBar extends StatefulWidget {
  final FeedModel model;
  final int commentFlag;

  SliderInNavigationBar({Key? key, required this.model, this.commentFlag = 0})
      : super(key: key);

  @override
  _SliderInNavigationBarScreenState createState() =>
      new _SliderInNavigationBarScreenState();
}

class _SliderInNavigationBarScreenState extends State<SliderInNavigationBar> {
  int _currentIndex = 0;

  //List<Widget> _children;
  int _period = 0;
  int maxVal = 0;
  bool isPressed = false;
  bool _isPlacingBet = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context, listen: false);
    var state = Provider.of<FeedState>(context, listen: false);

    void _send() async {
      debugPrint('=== BEN DEDIM BUTONUNA BASILDI ===');
      debugPrint('_period: $_period');
      debugPrint('maxVal: $maxVal');
      debugPrint('commentFlag: ${widget.commentFlag}');
      debugPrint('userId: ${authState.userId}');
      debugPrint('model.key: ${widget.model.key}');
      
      // Miktar kontrolü
      if (_period <= 0) {
        debugPrint('[HATA] Bahis miktarı 0 veya negatif!');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.pleaseSelectBetAmount),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      if (_period > maxVal) {
        debugPrint('[HATA] Bahis miktarı maksimumdan fazla! $_period > $maxVal');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.maxBetTokens('$maxVal')),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Bir tahminde yalnızca tek tarafa (Evet veya Hayır) bahis yapılabilir
      final userId = authState.userId;
      if (userAlreadyBetOnOtherSide(widget.model, userId, widget.commentFlag)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.betOnOneSideOnly,
              ),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.orange.shade800,
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      setState(() => _isPlacingBet = true);

      try {
        debugPrint('[BAHIS] placeBet çağrılıyor...');
        await state.placeBet(
          authState,
          widget.model,
          authState.userId ?? '',
          _period,
          widget.commentFlag,
        );
        debugPrint('[BAHIS] placeBet başarılı!');

        state.setToldyaToReply = widget.model;
        debugPrint('[BAHIS] Bildirim gönderiliyor...');
        authState.getuserDetail(widget.model.userId ?? '').then((user) {
          final ownUser = authState.userModel;
          if (user != null && ownUser != null && context.mounted) {
            Provider.of<ComposeToldyaState>(context, listen: false)
                .sendNotificationToFeed(
                    widget.model, user, ownUser, widget.commentFlag, _period)
                .then((_) {
                  debugPrint('[BAHIS] Bildirim gönderildi');
                });
          }
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.betPlaced)),
          );
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
      } on PlatformException catch (e) {
        // Native Android hataları PlatformException olarak gelir
        debugPrint('[BAHIS HATASI] PlatformException');
        debugPrint('[BAHIS HATASI] code: ${e.code}');
        debugPrint('[BAHIS HATASI] message: ${e.message}');
        debugPrint('[BAHIS HATASI] details: ${e.details}');
        debugPrint('[BAHIS HATASI] stacktrace: ${e.stacktrace}');
        if (context.mounted) {
          setState(() => _isPlacingBet = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.gmsError(e.message ?? e.code ?? AppLocalizations.of(context)!.unknownError)),
              duration: Duration(seconds: 6),
              backgroundColor: Colors.red,
            ),
          );
        }
      } on FirebaseFunctionsException catch (e) {
        // Konsol + Logcat'te görünmesi için (Android Studio Run/Debug sekmesi)
        debugPrint('[BAHIS HATASI] FirebaseFunctionsException');
        debugPrint('[BAHIS HATASI] code: ${e.code}');
        debugPrint('[BAHIS HATASI] message: ${e.message}');
        debugPrint('[BAHIS HATASI] details: ${e.details}');
        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          String errorMessage = l10n.betErrorGeneric;
          if (e.code == 'internal' || e.code == 'INTERNAL') {
            errorMessage = l10n.gmsUpdateMessage;
          } else if (e.code == 'unauthenticated') {
            errorMessage = l10n.loginRequired;
          } else if (e.code == 'deadline-exceeded') {
            errorMessage = l10n.betTimeout;
          } else if (e.message != null && e.message!.isNotEmpty) {
            errorMessage = e.message!;
          } else if (e.code.isNotEmpty) {
            errorMessage = l10n.errorWithMessage(e.code);
          }
          setState(() => _isPlacingBet = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: Duration(seconds: 6),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e, stackTrace) {
        debugPrint('[BAHIS HATASI] Genel Exception');
        debugPrint('[BAHIS HATASI] Type: ${e.runtimeType}');
        debugPrint('[BAHIS HATASI] Message: $e');
        debugPrint('[BAHIS HATASI] Stack trace: $stackTrace');
        if (context.mounted) {
          setState(() => _isPlacingBet = false);
          final msg = e.toString().length > 120
              ? '${e.toString().substring(0, 120)}...'
              : e.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.errorWithMessage(msg)),
              duration: Duration(seconds: 6),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    final balance = authState.userModel?.pegCount ?? 0;
    final xp = authState.userModel?.xp ?? 0;
    final totalPool = sumOfVote(widget.model.likeList ?? []) +
        sumOfVote(widget.model.unlikeList ?? []);
    maxVal = [
      balance,
      Tokenomics.maxBetByRank(balance, xp),
      Tokenomics.maxBetByPool(totalPool),
    ].reduce((a, b) => a < b ? a : b);

    const presetAmounts = [10, 25, 50, 100];
    final validPresets = presetAmounts.where((a) => a <= maxVal).toList();
    const greenPrimary = Color(0xFF4CAF50);

    final textSecondary = AppColor.textSecondaryDark;
    final textPrimary = AppColor.textPrimaryDark;
    final surfaceColor = MockupDesign.card;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          AppLocalizations.of(context)!.betAmountLabel,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MockupDesign.cardBorder),
          ),
          child: Text(
            '$_period token',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: validPresets.map((amount) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _period = (_period + amount).clamp(0, maxVal)),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: MockupDesign.cardBorder),
                  ),
                  child: Text(
                    '+$amount',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 24),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isPlacingBet
                ? null
                : () {
                    if (_period <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectBetAmount), duration: Duration(seconds: 2)),
                      );
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text(AppLocalizations.of(context)!.confirmBet, style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 18)),
                        content: Text(
                          AppLocalizations.of(context)!.confirmBetMessage('$_period'),
                          style: TextStyle(color: Color(0xFF616161)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () { if (Navigator.canPop(ctx)) Navigator.pop(ctx); },
                            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Color(0xFF757575))),
                          ),
                          TextButton(
                            onPressed: () {
                              if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                              _send();
                            },
                            child: Text(AppLocalizations.of(context)!.confirm, style: TextStyle(color: greenPrimary, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    );
                  },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _isPlacingBet ? Colors.grey : greenPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isPlacingBet
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      AppLocalizations.of(context)!.confirmBet,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
