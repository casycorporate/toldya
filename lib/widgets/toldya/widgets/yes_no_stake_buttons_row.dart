import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';

class YesNoStakeButtonsRow extends StatelessWidget {
  final int yesPercent;
  final int noPercent;
  final VoidCallback onYesTap;
  final VoidCallback onNoTap;
  final bool enabledYes;
  final bool enabledNo;
  final double height;

  const YesNoStakeButtonsRow({
    super.key,
    required this.yesPercent,
    required this.noPercent,
    required this.onYesTap,
    required this.onNoTap,
    this.enabledYes = true,
    this.enabledNo = true,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _SolidStakeButton(
            height: height,
            background: ToldyaStakeButtonPalette.yes,
            label: '${l10n.yes} · $yesPercent%',
            enabled: enabledYes,
            onTap: onYesTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SolidStakeButton(
            height: height,
            background: ToldyaStakeButtonPalette.no,
            label: '${l10n.no} · $noPercent%',
            enabled: enabledNo,
            onTap: onNoTap,
          ),
        ),
      ],
    );
  }
}

class _SolidStakeButton extends StatelessWidget {
  final Color background;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final double height;

  const _SolidStakeButton({
    required this.background,
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? background : background.withValues(alpha: 0.35);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: background.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: enabled ? 1.0 : 0.65),
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
