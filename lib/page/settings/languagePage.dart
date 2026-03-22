import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/state/appState.dart';
import 'package:toldya/page/settings/widgets/customSettingsCard.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';

/// Language selection page. Saves choice to AppState + SharedPreferences.
class LanguagePage extends StatelessWidget {
  const LanguagePage({Key? key}) : super(key: key);

  static const List<LocaleOption> _options = [
    LocaleOption('tr'),
    LocaleOption('en'),
    LocaleOption('de'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context);
    final currentCode = appState.locale.languageCode;
    const selectedNeonGreen = Color(0xFF2ED573);
    const selectedTint = Color(0x192ED573); // ~10% opacity

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F2E),
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(l10n.language),
      ),
      body: ListView(
        padding: const EdgeInsets.all(MockupDesign.screenPadding),
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          CustomSettingsCard(
            children: _options.map((opt) {
              final isSelected = currentCode == opt.code;
              final label = _labelForLocale(l10n, opt.code);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await appState.setLocale(Locale(opt.code));
                    if (context.mounted && Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? selectedTint : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? selectedNeonGreen.withOpacity(0.65)
                            : MockupDesign.cardBorder.withOpacity(0.9),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: MockupDesign.textPrimary,
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          Icon(Icons.check, color: selectedNeonGreen, size: 22),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _labelForLocale(AppLocalizations l10n, String code) {
    switch (code) {
      case 'tr':
        return l10n.languageOptionTurkish;
      case 'en':
        return l10n.languageOptionEnglish;
      case 'de':
        return l10n.languageOptionGerman;
      default:
        return l10n.languageOptionTurkish;
    }
  }
}

class LocaleOption {
  final String code;
  const LocaleOption(this.code);
}
