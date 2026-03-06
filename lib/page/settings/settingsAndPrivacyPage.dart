import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/page/settings/widgets/headerWidget.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:provider/provider.dart';
import 'widgets/settingsRowWidget.dart';

class SettingsAndPrivacyPage extends StatelessWidget {
  const SettingsAndPrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(l10n.settingsAndPrivacy),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: spacing8),
        children: <Widget>[
          HeaderWidget(user.userName ?? ''),
          SettingRowWidget(
            l10n.account,
            navigateTo: 'AccountSettingsPage',
          ),
          Divider(height: 0),
          SettingRowWidget(l10n.privacyAndPolicy,
              navigateTo: 'PrivacyAndSaftyPage'),
          Divider(height: 0),
          SettingRowWidget(l10n.language, navigateTo: 'LanguagePage'),
          // SettingRowWidget("Notification", navigateTo: 'NotificationPage'),
          // SettingRowWidget("Content prefrences",
          //     navigateTo: 'ContentPrefrencePage'),
          // HeaderWidget(
          //   'General',
          //   secondHeader: true,
          // ),
          // SettingRowWidget("Display and Sound",
          //     navigateTo: 'DisplayAndSoundPage'),
          // SettingRowWidget("Data usage", navigateTo: 'DataUsagePage'),
          // SettingRowWidget("Accessibility", navigateTo: 'AccessibilityPage'),
          // SettingRowWidget("Proxy", navigateTo: "ProxyPage"),
          // SettingRowWidget(
          //   "About Fwitter",
          //   navigateTo: "AboutPage",
          // ),
          // SettingRowWidget(
          //   null,
          //   showDivider: false,
          //   vPadding: 10,
          //   subtitle:
          //       'These settings affect all of your Fwitter accounts on this devce.',
          // )
        ],
      ),
    );
  }
}
