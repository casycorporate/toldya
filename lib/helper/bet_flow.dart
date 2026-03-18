import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/widgets/tweet/widgets/tweetBottomSheet.dart';

/// Shared bet flow: guards + opens bet amount sheet (no navigation to detail).
Future<void> openBetFlow({
  required BuildContext context,
  required FeedModel model,
  required int commentFlag,
  required ToldyaType type,
  required GlobalKey<ScaffoldState> scaffoldKey,
}) async {
  final authState = Provider.of<AuthState>(context, listen: false);
  final feedState = Provider.of<FeedState>(context, listen: false);

  if (feedState.isBetInFlight(model.key)) return;
  if (isBettingClosed(model.statu, model.endDate)) return;
  if ((authState.userModel?.pegCount ?? 0) <= 0) return;
  if (userAlreadyBetOnOtherSide(model, authState.userId, commentFlag)) return;

  ToldyaBottomSheet().openRetoldyabottomSheet(
    commentFlag,
    context,
    type: type,
    model: model,
    scaffoldKey: scaffoldKey,
  );
}

void _showBetHint(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      backgroundColor: const Color(0xFF1A1F2E),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    ),
  );
}

/// Her tıklamada: uygunsa sheet açar; değilse kısa SnackBar ile nedenini söyler.
void openBetFlowWithFeedback({
  required BuildContext context,
  required FeedModel model,
  required int commentFlag,
  required ToldyaType type,
  required GlobalKey<ScaffoldState> scaffoldKey,
}) {
  final l10n = AppLocalizations.of(context)!;
  final authState = Provider.of<AuthState>(context, listen: false);
  final feedState = Provider.of<FeedState>(context, listen: false);

  if (feedState.isBetInFlight(model.key)) {
    _showBetHint(context, l10n.betPleaseWait);
    return;
  }
  if (isBettingClosed(model.statu, model.endDate)) {
    _showBetHint(context, l10n.closedNoSelection);
    return;
  }
  if ((authState.userModel?.pegCount ?? 0) <= 0) {
    _showBetHint(context, l10n.tokenInsufficient);
    return;
  }
  if (userAlreadyBetOnOtherSide(model, authState.userId, commentFlag)) {
    _showBetHint(context, l10n.betOnOneSideOnly);
    return;
  }

  HapticFeedback.lightImpact();
  ToldyaBottomSheet().openRetoldyabottomSheet(
    commentFlag,
    context,
    type: type,
    model: model,
    scaffoldKey: scaffoldKey,
  );
}
