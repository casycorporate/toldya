import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';

class XpProgressBarWidget extends StatelessWidget {
  final int xp;
  final bool showHint;

  const XpProgressBarWidget({
    Key? key,
    required this.xp,
    this.showHint = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final safeXp = xp < 0 ? 0 : xp;
    final progress = _xpProgress(safeXp);
    final label = _xpProgressLabel(context, safeXp);
    final baseColor = _rankColorForXp(safeXp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(baseColor),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: baseColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (showHint) ...[
          const SizedBox(height: 4),
          Text(
            _xpHintForXp(l10n, safeXp),
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
}

double _xpProgress(int xp) {
  if (xp < AppIcon.xpCaylakMax) {
    return (xp / AppIcon.xpCaylakMax).clamp(0.0, 1.0);
  }
  if (xp < AppIcon.xpUstaMin) {
    return ((xp - AppIcon.xpCaylakMax) /
            (AppIcon.xpUstaMin - AppIcon.xpCaylakMax))
        .clamp(0.0, 1.0);
  }
  return 1.0;
}

String _xpProgressLabel(BuildContext context, int xp) {
  final l10n = AppLocalizations.of(context)!;
  if (xp < AppIcon.xpCaylakMax) {
    return l10n.xpProgressLabel(xp, AppIcon.xpCaylakMax);
  }
  if (xp < AppIcon.xpUstaMin) {
    return l10n.xpProgressLabel(xp, AppIcon.xpUstaMin);
  }
  return l10n.xpProgressMaxLabel(xp);
}

String _xpHintForXp(AppLocalizations l10n, int xp) {
  if (xp < AppIcon.xpCaylakMax) {
    return l10n.xpHintToBecomePredictor(AppIcon.xpCaylakMax);
  }
  if (xp < AppIcon.xpUstaMin) {
    return l10n.xpHintToBecomeMaster(AppIcon.xpUstaMin);
  }
  return l10n.xpHintMaxRank;
}

Color _rankColorForXp(int xp) {
  if (xp < AppIcon.xpCaylakMax) {
    return Colors.brown[300] ?? Colors.grey.shade500;
  }
  if (xp < AppIcon.xpUstaMin) {
    return const Color(0xFFFF6B6B);
  }
  final base = Colors.amber;
  return Color.lerp(base, Colors.deepPurpleAccent, 0.25) ?? base;
}

