import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/page/settings/widgets/headerWidget.dart';
import 'package:toldya/page/settings/widgets/settingsAppbar.dart';
import 'package:toldya/page/settings/widgets/settingsRowWidget.dart';
import 'package:toldya/state/authState.dart';
import 'package:provider/provider.dart';

class ContentPrefrencePage extends StatelessWidget {
  const ContentPrefrencePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SettingsAppBar(
        title: l10n.contentPreferencesTitle,
        subtitle: user.userName ?? '',
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget(l10n.exploreHeader),
          SettingRowWidget(
            l10n.leaderboardTitle,
            navigateTo: 'LeaderboardPage',
          ),
          SettingRowWidget(
            l10n.trendsTitle,
            navigateTo: 'TrendsPage',
          ),
          Divider(height: 0),
          SettingRowWidget(
            l10n.searchSettingsTitle,
            subtitle: l10n.featureComingSoon(l10n.searchSettingsTitle),
            navigateTo: null,
          ),
          HeaderWidget(
            l10n.languagesHeader,
            secondHeader: true,
          ),
          SettingRowWidget(
            l10n.recommendationsTitle,
            vPadding: 15,
            subtitle: l10n.featureComingSoon(l10n.recommendationsTitle),
          ),
          HeaderWidget(
            l10n.safetyHeader,
            secondHeader: true,
          ),
          SettingRowWidget(l10n.blockedAccountsTitle, subtitle: l10n.featureComingSoon(l10n.blockedAccountsTitle)),
          SettingRowWidget(l10n.mutedAccountsTitle, subtitle: l10n.featureComingSoon(l10n.mutedAccountsTitle)),
        ],
      ),
    );
  }
}
