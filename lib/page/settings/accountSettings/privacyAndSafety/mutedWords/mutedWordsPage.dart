import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/page/settings/widgets/settingsAppbar.dart';

class MutedWordsPage extends StatelessWidget {
  const MutedWordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F2E),
      appBar: SettingsAppBar(
        title: l10n.mutedWordsTitle,
        subtitle: '',
      ),
      body: Padding(
        padding: const EdgeInsets.all(MockupDesign.screenPadding),
        child: Container(
          decoration: BoxDecoration(
            color: MockupDesign.card,
            borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
            border: Border.all(color: MockupDesign.cardBorder),
            boxShadow: MockupDesign.cardShadow,
          ),
          padding: const EdgeInsets.all(MockupDesign.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.mutedWordsComingSoonTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: MockupDesign.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.mutedWordsComingSoonSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: MockupDesign.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

