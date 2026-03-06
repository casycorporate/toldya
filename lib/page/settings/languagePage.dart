import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/state/appState.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';

/// Language selection page. Saves choice to AppState + SharedPreferences.
class LanguagePage extends StatelessWidget {
  const LanguagePage({Key? key}) : super(key: key);

  static const List<LocaleOption> _options = [
    LocaleOption('tr', '🇹🇷 Türkçe'),
    LocaleOption('en', '🇬🇧 English'),
    LocaleOption('de', '🇩🇪 Deutsch'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context);
    final currentCode = appState.locale?.languageCode ?? 'tr';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(l10n.language),
      ),
      body: ListView(
        children: _options
            .map((opt) => ListTile(
                  title: Text(opt.label),
                  trailing: currentCode == opt.code
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () async {
                    await appState.setLocale(Locale(opt.code));
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ))
            .toList(),
      ),
    );
  }
}

class LocaleOption {
  final String code;
  final String label;
  const LocaleOption(this.code, this.label);
}
