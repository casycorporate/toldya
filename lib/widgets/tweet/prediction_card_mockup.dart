import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:toldya/widgets/animated_bounce_button.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/topicMap.dart';
import 'package:toldya/helper/utility.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/customUrlText.dart';
import 'package:toldya/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:provider/provider.dart';

/// Mockup’a uygun tahmin kartı: soru üstte, countdown belirgin, progress + Evet/Hayır.
/// [enableVote]: false ise Evet/Hayır butonları tıklanamaz (sadece ana akışta tahmin girişi).
class PredictionCardMockup extends StatelessWidget {
  final FeedModel model;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool enableVote;

  const PredictionCardMockup({
    Key? key,
    required this.model,
    required this.scaffoldKey,
    this.enableVote = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context, listen: false);
    final totalYes = sumOfVote(model.likeList ?? []);
    final totalNo = sumOfVote(model.unlikeList ?? []);
    final total = totalYes + totalNo;
    final percent = total == 0 ? 0.5 : totalYes / total;
    final closed = arePredictionsClosed(model.statu, model.endDate);
    final topicLabel = topic.topicMap[model.topic ?? ''] ?? model.topic ?? 'Genel';

    final isOpen = !arePredictionsClosed(model.statu, model.endDate) && (model.statu == Statu.statusLive);
    final countdownLong = getCountdownLong(model.endDate);

    final yesPct = total > 0 ? (percent * 100).round().clamp(0, 100) : 50;
    final noPct = 100 - yesPct;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Üst satır: sol avatar + @kullanici (güncel profil) + kategori; sağ LIVE + Kalan + aksiyon ikonları
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<UserModel?>(
                  future: Provider.of<AuthState>(context, listen: false).getuserDetail(model.user?.userId ?? ''),
                  builder: (context, AsyncSnapshot<UserModel?> snapshot) {
                    final user = snapshot.data ?? model.user;
                    final handle = formatHandle(user?.userName, user?.displayName);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAvatar(context, user),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                handle,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ToldyaDesign.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                topicLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ToldyaDesign.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (isOpen) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ToldyaDesign.statusBadge, width: 1),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.statusOpen,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ToldyaDesign.statusBadge,
                    ),
                  ),
                ),
                SizedBox(width: 6),
              ],
              _iconBtn(
                context,
                (model.favList ?? []).any((id) => id == authState.userId)
                    ? Icons.star
                    : Icons.star_border,
                Theme.of(context).primaryColor,
                () {
                  Provider.of<FeedState>(context, listen: false)
                      .addFavToToldya(model, authState.userId);
                },
              ),
              _iconBtn(context, Icons.share_outlined, Colors.grey, () async {
                await Utility.createLinkToShare(
                  context,
                  'toldya/${model.key}',
                  socialMetaTagParameters: SocialMetaTagParameters(
                    description: model.description ??
                        AppLocalizations.of(context)!.sharedPredictionDescription(model.user?.displayName ?? ''),
                    title: AppLocalizations.of(context)!.appTitle,
                  ),
                );
              }),
              ToldyaBottomSheet().toldyaOptionIcon(
                context,
                model: model,
                type: ToldyaType.Toldya,
                scaffoldKey: scaffoldKey,
              ),
            ],
          ),
          // Tahmin başlığı
          if (model.description != null && (model.description ?? '').isNotEmpty) ...[
            SizedBox(height: 12),
            UrlText(
              text: model.description,
              onHashTagPressed: (_) {},
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: ToldyaDesign.textPrimary,
              ),
              urlStyle: TextStyle(
                fontSize: 17,
                color: ToldyaDesign.yes,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          // Oran çubuğu + altında % YES / % NO
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(ToldyaDesign.progressBarRadius),
            child: Container(
              height: ToldyaDesign.progressBarHeight,
              color: ToldyaDesign.progressBackground,
              child: Row(
                children: [
                  Expanded(
                    flex: yesPct.clamp(1, 99),
                    child: Container(color: ToldyaDesign.progressYes),
                  ),
                  Expanded(
                    flex: noPct.clamp(1, 99),
                    child: Container(color: ToldyaDesign.progressNo),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppLocalizations.of(context)!.yes} $yesPct%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ToldyaDesign.yes,
                ),
              ),
              Text(
                '${AppLocalizations.of(context)!.no} $noPct%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ToldyaDesign.no,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _VoteButton(
                  label: AppLocalizations.of(context)!.yes,
                  isYes: true,
                  closed: closed,
                  onTap: enableVote ? () => _onVoteTap(context, 0) : null,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _VoteButton(
                  label: AppLocalizations.of(context)!.no,
                  isYes: false,
                  closed: closed,
                  onTap: enableVote ? () => _onVoteTap(context, 1) : null,
                ),
              ),
            ],
          ),
          if (countdownLong.isNotEmpty) ...[
            SizedBox(height: 10),
            Text(
              countdownLong,
              style: TextStyle(
                fontSize: 12,
                color: ToldyaDesign.textSecondary,
              ),
            ),
          ],
        ],
      );
  }

  static const int _kDefaultPredictionPoints = 10;

  void _onVoteTap(BuildContext context, int commentFlag) {
    final authState = Provider.of<AuthState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final closed = arePredictionsClosed(model.statu, model.endDate);
    if (closed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(l10n.predictionsClosed),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black87,
      ));
      return;
    }
    if (authState.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(l10n.loginRequired),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    if (userAlreadyPredicted(model, authState.userId)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(l10n.predictionAlreadyParticipated),
        duration: const Duration(seconds: 3),
        backgroundColor: ToldyaDesign.card,
      ));
      return;
    }
    if (userAlreadyPredictedOtherSide(model, authState.userId, commentFlag)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(l10n.predictionOneSideOnly),
        duration: const Duration(seconds: 3),
        backgroundColor: ToldyaDesign.card,
      ));
      return;
    }
    final balance = authState.userModel?.pegCount ?? 0;
    final xp = authState.userModel?.xp ?? 0;
    final totalPool = sumOfVote(model.likeList ?? []) + sumOfVote(model.unlikeList ?? []);
    final maxPoints = [balance, Tokenomics.maxPredictionByRank(balance, xp), Tokenomics.maxPredictionByPool(totalPool)]
        .reduce((a, b) => a < b ? a : b);
    if (maxPoints <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(l10n.tokenInsufficient),
        backgroundColor: ToldyaDesign.card,
      ));
      return;
    }
    final defaultAmount = _kDefaultPredictionPoints > maxPoints ? maxPoints : _kDefaultPredictionPoints;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ToldyaDesign.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.confirmPrediction,
          style: TextStyle(color: ToldyaDesign.textPrimary, fontSize: 18),
        ),
        content: Text(
          l10n.confirmPredictionMessage('$defaultAmount'),
          style: TextStyle(color: ToldyaDesign.textSecondary, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel, style: TextStyle(color: ToldyaDesign.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final state = Provider.of<FeedState>(context, listen: false);
              try {
                await state.submitPrediction(
                  authState,
                  model,
                  authState.userId ?? '',
                  defaultAmount,
                  commentFlag,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(l10n.predictionSubmitted),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }
              } on Exception catch (e) {
                if (context.mounted) {
                  final msg = e.toString().contains('insufficient') || e.toString().contains('INSUFFICIENT')
                      ? l10n.tokenInsufficient
                      : (e.toString().length > 80 ? '${e.toString().substring(0, 80)}...' : e.toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(msg),
                      backgroundColor: ToldyaDesign.card,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, UserModel? user) {
    final userId = user?.userId ?? model.user?.userId ?? '';
    final profilePic = user?.profilePic ?? '';
    if (userId.isEmpty) return SizedBox(width: 34, height: 34);
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/ProfilePage/$userId'),
      child: Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ToldyaDesign.textSecondary.withOpacity(0.5), width: 1),
        ),
        child: ClipOval(
          child: Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.all(1),
            child: customProfileImage(context, profilePic.isEmpty ? null : profilePic, userId: userId, height: 28),
          ),
        ),
      ),
    );
  }

  Widget _countdownChip(BuildContext context) {
    final text = getEndTime(model.endDate ?? '');
    if (text.isEmpty) return SizedBox.shrink();
    final color = ToldyaDesign.textSecondary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(BuildContext context, IconData icon, Color color, VoidCallback onPressed) {
    return CupertinoButton(
      padding: EdgeInsets.all(4),
      minSize: 0,
      onPressed: onPressed,
      child: Icon(icon, size: 18, color: color),
    );
  }

  void _openPredictionSheet(BuildContext context, AuthState authState, int commentFlag) {
    final closed = arePredictionsClosed(model.statu, model.endDate);
    if (closed || (authState.userModel?.pegCount ?? 0) == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          closed ? 'Kapandığı için seçim yapılamaz' : 'Token yetersiz',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black87,
      ));
      return;
    }
    if (userAlreadyPredicted(model, authState.userId)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          AppLocalizations.of(context)!.predictionAlreadyParticipated,
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: ToldyaDesign.card,
      ));
      return;
    }
    if (userAlreadyPredictedOtherSide(model, authState.userId, commentFlag)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          AppLocalizations.of(context)!.predictionOneSideOnly,
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 4),
        backgroundColor: ToldyaDesign.card,
      ));
      return;
    }
    ToldyaBottomSheet().openRetoldyabottomSheet(
      commentFlag,
      context,
      type: ToldyaType.Toldya,
      model: model,
      scaffoldKey: scaffoldKey,
    );
  }
}

class _VoteButton extends StatelessWidget {
  final String label;
  final bool isYes;
  final bool closed;
  final VoidCallback? onTap;

  const _VoteButton({
    required this.label,
    required this.isYes,
    required this.closed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBounceButton(
      enabled: !closed && onTap != null,
      child: Material(
        color: isYes ? ToldyaDesign.yes : Colors.transparent,
        borderRadius: BorderRadius.circular(ToldyaDesign.buttonRadius),
        elevation: 0,
        shadowColor: Colors.transparent,
        child: InkWell(
          onTap: (closed || onTap == null) ? null : () {
            HapticFeedback.mediumImpact();
            onTap!();
          },
          borderRadius: BorderRadius.circular(ToldyaDesign.buttonRadius),
          child: Container(
            height: ToldyaDesign.buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ToldyaDesign.buttonRadius),
              border: isYes ? null : Border.all(color: ToldyaDesign.no, width: 2),
              boxShadow: isYes ? ToldyaDesign.yesButtonShadow : null,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isYes ? Colors.white : ToldyaDesign.no,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

