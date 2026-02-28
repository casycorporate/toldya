import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/page/settings/widgets/headerWidget.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/widgets/customAppBar.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:provider/provider.dart';
import 'widgets/settingsRowWidget.dart';

class SettingsAndPrivacyPage extends StatelessWidget {
  const SettingsAndPrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'Settings and privacy',
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: spacing8),
        children: <Widget>[
          HeaderWidget(user.userName ?? ''),
          SettingRowWidget(
            "Account",
            navigateTo: 'AccountSettingsPage',
          ),
          Divider(height: 0),
          SettingRowWidget("Privacy and Policy",
              navigateTo: 'PrivacyAndSaftyPage'),
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
