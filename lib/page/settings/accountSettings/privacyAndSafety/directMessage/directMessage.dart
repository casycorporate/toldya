import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/page/settings/widgets/headerWidget.dart';
import 'package:toldya/page/settings/widgets/settingsAppbar.dart';
import 'package:toldya/page/settings/widgets/settingsRowWidget.dart';
import 'package:toldya/state/authState.dart';
import 'package:provider/provider.dart';

class DirectMessagesPage extends StatelessWidget {
  const DirectMessagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SettingsAppBar(
        title: l10n.directMessagesTitle,
        subtitle: user.userName ?? '',
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget(
            l10n.directMessagesTitle,
            secondHeader: true,
          ),
          SettingRowWidget(
            l10n.receiveMessageRequestsTitle,
            navigateTo: null,
            showDivider: false,
            vPadding: 20,
            subtitle: l10n.featureComingSoon(l10n.receiveMessageRequestsTitle),
          ),
          SettingRowWidget(
            l10n.showReadReceiptsTitle,
            navigateTo: null,
            showDivider: false,
            subtitle: l10n.featureComingSoon(l10n.showReadReceiptsTitle),
          ),
        ],
      ),
    );
  }
}
