import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/page/settings/widgets/settingsAppbar.dart';

class LegalUrlPage extends StatelessWidget {
  final String type; // 'privacy' | 'terms'
  const LegalUrlPage({super.key, required this.type});

  String? _urlForType() {
    // URL missing: set before release.
    // This repo currently does not include configured privacy/terms URLs.
    // Do not add placeholder URLs here.
    switch (type) {
      case 'privacy':
        return null;
      case 'terms':
        return null;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final url = _urlForType();
    final title = type == 'terms' ? l10n.userAgreementRowTitle : l10n.privacyPolicyRowTitle;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F2E),
      appBar: SettingsAppBar(
        title: title,
        subtitle: '',
      ),
      body: Padding(
        padding: const EdgeInsets.all(MockupDesign.screenPadding),
        child: Container(
          width: double.infinity,
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
                l10n.legalUrlMissingTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: MockupDesign.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.legalUrlMissingSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: MockupDesign.textSecondary,
                ),
              ),
              if (url != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await launchURL(url);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppNeon.green,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(l10n.openLegalButton),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}

