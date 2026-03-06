import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/page/settings/widgets/headerWidget.dart';
import 'package:toldya/page/settings/widgets/settingsAppbar.dart';
import 'package:toldya/page/settings/widgets/settingsRowWidget.dart';
import 'package:toldya/state/authState.dart';
import 'package:provider/provider.dart';

class PrivacyAndSaftyPage extends StatelessWidget {
  const PrivacyAndSaftyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SettingsAppBar(
        title: AppLocalizations.of(context)!.privacyAndSafetyTitle,
        subtitle: user.userName ?? '',
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget(AppLocalizations.of(context)!.privacySharesHeader),
          SettingRowWidget(
            AppLocalizations.of(context)!.protectPostsTitle,
            subtitle: AppLocalizations.of(context)!.protectPostsSubtitle,
            vPadding: 15,
            showDivider: false,
            visibleSwitch: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.photoTaggingTitle,
            subtitle: AppLocalizations.of(context)!.photoTaggingSubtitle,
          ),
          HeaderWidget(
            AppLocalizations.of(context)!.liveVideoHeader,
            secondHeader: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.connectToLiveVideoTitle,
            subtitle: AppLocalizations.of(context)!.connectToLiveVideoSubtitle,
            vPadding: 15,
            showDivider: false,
            visibleSwitch: true,
          ),
          HeaderWidget(
            AppLocalizations.of(context)!.discoverabilityHeader,
            secondHeader: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.discoverabilityTitle,
            vPadding: 15,
            showDivider: false,
          ),
          SettingRowWidget(
            '',
            subtitle: AppLocalizations.of(context)!.discoverabilitySubtitle,
            vPadding: 15,
            showDivider: false,
          ),
          HeaderWidget(
            AppLocalizations.of(context)!.securityHeader,
            secondHeader: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.showSensitiveMediaTitle,
            vPadding: 15,
            showDivider: false,
            visibleSwitch: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.markSensitiveMediaTitle,
            vPadding: 15,
            showDivider: false,
            visibleSwitch: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.blockedAccountsTitle,
            showDivider: false,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.mutedAccountsTitle,
            showDivider: false,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.mutedWordsTitle,
            showDivider: false,
          ),
          HeaderWidget(
            AppLocalizations.of(context)!.locationHeader,
            secondHeader: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.preciseLocationTitle,
            subtitle: AppLocalizations.of(context)!.preciseLocationSubtitle,
          ),
          HeaderWidget(
            AppLocalizations.of(context)!.personalizationHeader,
            secondHeader: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.personalizationTitle,
            subtitle: AppLocalizations.of(context)!.allowAllSubtitle,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.viewYourDataTitle,
            subtitle: AppLocalizations.of(context)!.viewYourDataSubtitle,
          ),
        ],
      ),
    );
  }
}
