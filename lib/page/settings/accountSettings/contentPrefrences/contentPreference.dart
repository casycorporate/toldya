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
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SettingsAppBar(
        title: AppLocalizations.of(context)!.contentPreferencesTitle,
        subtitle: user.userName ?? '',
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget(AppLocalizations.of(context)!.exploreHeader),
          SettingRowWidget(
            AppLocalizations.of(context)!.leaderboardTitle,
            navigateTo: 'LeaderboardPage',
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.trendsTitle,
            navigateTo: 'TrendsPage',
          ),
          Divider(height: 0),
          SettingRowWidget(
            AppLocalizations.of(context)!.searchSettingsTitle,
            navigateTo: '',
          ),
          HeaderWidget(
            AppLocalizations.of(context)!.languagesHeader,
            secondHeader: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.recommendationsTitle,
            vPadding: 15,
            subtitle: AppLocalizations.of(context)!.recommendationsSubtitle,
          ),
          HeaderWidget(
            AppLocalizations.of(context)!.safetyHeader,
            secondHeader: true,
          ),
          SettingRowWidget(AppLocalizations.of(context)!.blockedAccountsTitle),
          SettingRowWidget(AppLocalizations.of(context)!.mutedAccountsTitle),
        ],
      ),
    );
  }
}
