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
    final l10n = AppLocalizations.of(context)!;
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SettingsAppBar(
        title: l10n.notificationsTitle,
        subtitle: user.userName ?? '',
      ),
      body: ListView(
        children: <Widget>[
          HeaderWidget(l10n.filtersHeader),
          SettingRowWidget(
            l10n.qualityFilterTitle,
            subtitle: l10n.featureComingSoon(l10n.qualityFilterTitle),
            // navigateTo: 'AccountSettingsPage',
          ),
          Divider(height: 0),
          SettingRowWidget(l10n.advancedFilterTitle, subtitle: l10n.featureComingSoon(l10n.advancedFilterTitle)),
          SettingRowWidget(l10n.mutedWordTitle, subtitle: l10n.featureComingSoon(l10n.mutedWordTitle)),
          HeaderWidget(
            l10n.preferencesHeader,
            secondHeader: true,
          ),
          SettingRowWidget(
            l10n.unreadBadgeTitle,
            showCheckBox: false,
            subtitle: l10n.unreadBadgeSubtitle,
          ),
          SettingRowWidget(AppLocalizations.of(context)!.pushNotificationsTitle),
          SettingRowWidget(AppLocalizations.of(context)!.smsNotificationsTitle),
          SettingRowWidget(
            l10n.emailNotificationsTitle,
            subtitle: l10n.emailNotificationsSubtitle,
          ),
        ],
      ),
    );
  }
}
