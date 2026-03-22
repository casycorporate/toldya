import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';

/// Pre-sezon / bekleme odası: Lig ataması yapılmadan önce gösterilen boş durum.
/// Ortada kilit/ödül ikonu, başlık ve alt başlık; hafif animasyon.
class LeaguePreSeasonEmptyState extends StatelessWidget {
  const LeaguePreSeasonEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: MockupDesign.background,
      padding: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding * 2),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 80,
                color: MockupDesign.textSecondary.withOpacity(0.4),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.05, 1.05), curve: Curves.easeInOut, duration: 1200.ms),
              SizedBox(height: MockupDesign.screenPadding * 2),
              Text(
                l10n.leaguePreSeasonTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: MockupDesign.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
              SizedBox(height: MockupDesign.screenPadding),
              Text(
                l10n.leaguePreSeasonSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: MockupDesign.textSecondary,
                  fontSize: 16,
                  height: 1.35,
                ),
              )
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 400.ms)
                  .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
            ],
          ),
        ),
      ),
    );
  }
}
