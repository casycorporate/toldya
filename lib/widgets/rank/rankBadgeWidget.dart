import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';

class RankBadgeWidget extends StatelessWidget {
  final int xp;
  final double? height;
  final bool compact;

  const RankBadgeWidget({
    Key? key,
    required this.xp,
    this.height,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final safeXp = xp < 0 ? 0 : xp;
    final l10n = AppLocalizations.of(context)!;

    final _RankVisual visual = _rankVisualForXp(context, safeXp, l10n);

    final baseColor = visual.color;
    final textColor = Colors.white;
    final padding = EdgeInsets.symmetric(
      horizontal: compact ? 8 : 10,
      vertical: compact ? 2 : 4,
    );
    final iconSize = compact ? 14.0 : 16.0;
    final fontSize = compact ? 11.0 : 12.0;

    return Container(
      constraints: height != null
          ? BoxConstraints(minHeight: height!)
          : const BoxConstraints(),
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: baseColor.withOpacity(0.70), width: 1),
        boxShadow: visual.showGlow
            ? [
                BoxShadow(
                  color: baseColor.withOpacity(0.45),
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            visual.icon,
            size: iconSize,
            color: baseColor,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            visual.label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  _RankVisual _rankVisualForXp(
    BuildContext context,
    int xp,
    AppLocalizations l10n,
  ) {
    if (xp < AppIcon.xpCaylakMax) {
      // Çaylak / Rookie
      final color = Colors.brown[300] ?? Colors.grey.shade500;
      return _RankVisual(
        tier: _RankTier.rookie,
        color: color,
        icon: Icons.local_florist_rounded,
        label: l10n.rankRookie,
        showGlow: false,
      );
    }
    if (xp < AppIcon.xpUstaMin) {
      // Tahminci / Forecaster
      const color = Color(0xFFFF6B6B);
      return const _RankVisual(
        tier: _RankTier.predictor,
        color: color,
        icon: Icons.flash_on_rounded,
        label: '', // label is filled via l10n below
        showGlow: false,
      ).withLabel(l10n.rankPredictor);
    }
    // Üstad / Master
    final base = Colors.amber;
    final blended = Color.lerp(base, Colors.deepPurpleAccent, 0.25) ?? base;
    return _RankVisual(
      tier: _RankTier.master,
      color: blended,
      icon: Icons.workspace_premium,
      label: l10n.rankMaster,
      showGlow: true,
    );
  }
}

enum _RankTier { rookie, predictor, master }

class _RankVisual {
  final _RankTier tier;
  final Color color;
  final IconData icon;
  final String label;
  final bool showGlow;

  const _RankVisual({
    required this.tier,
    required this.color,
    required this.icon,
    required this.label,
    required this.showGlow,
  });

  _RankVisual withLabel(String newLabel) => _RankVisual(
        tier: tier,
        color: color,
        icon: icon,
        label: newLabel,
        showGlow: showGlow,
      );
}

