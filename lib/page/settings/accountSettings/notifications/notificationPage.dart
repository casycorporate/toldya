import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/page/settings/widgets/headerWidget.dart';
import 'package:toldya/page/settings/widgets/settingsAppbar.dart';
import 'package:toldya/page/settings/widgets/settingsRowWidget.dart';
import 'package:toldya/state/authState.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SettingsAppBar(
        title: AppLocalizations.of(context)!.notificationsTitle,
        subtitle: user.userName ?? '',
      ),
      body: ListView(
        children: <Widget>[
          HeaderWidget(AppLocalizations.of(context)!.filtersHeader),
          SettingRowWidget(
            AppLocalizations.of(context)!.qualityFilterTitle,
            showCheckBox: true,
            subtitle: AppLocalizations.of(context)!.qualityFilterSubtitle,
            // navigateTo: 'AccountSettingsPage',
          ),
          Divider(height: 0),
          SettingRowWidget(AppLocalizations.of(context)!.advancedFilterTitle),
          SettingRowWidget(AppLocalizations.of(context)!.mutedWordTitle),
          HeaderWidget(
            AppLocalizations.of(context)!.preferencesHeader,
            secondHeader: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.unreadBadgeTitle,
            showCheckBox: false,
            subtitle: AppLocalizations.of(context)!.unreadBadgeSubtitle,
          ),
          SettingRowWidget(AppLocalizations.of(context)!.pushNotificationsTitle),
          SettingRowWidget(AppLocalizations.of(context)!.smsNotificationsTitle),
          SettingRowWidget(
            AppLocalizations.of(context)!.emailNotificationsTitle,
            subtitle: AppLocalizations.of(context)!.emailNotificationsSubtitle,
          ),
        ],
      ),
    );
  }
}
