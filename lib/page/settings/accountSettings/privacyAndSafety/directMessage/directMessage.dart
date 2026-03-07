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
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SettingsAppBar(
        title: AppLocalizations.of(context)!.directMessagesTitle,
        subtitle: user.userName ?? '',
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget(
            AppLocalizations.of(context)!.directMessagesTitle,
            secondHeader: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.receiveMessageRequestsTitle,
            navigateTo: null,
            showDivider: false,
            visibleSwitch: true,
            vPadding: 20,
            subtitle:
                AppLocalizations.of(context)!.receiveMessageRequestsSubtitle,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.showReadReceiptsTitle,
            navigateTo: null,
            showDivider: false,
            visibleSwitch: true,
            subtitle:
                AppLocalizations.of(context)!.showReadReceiptsSubtitle,
          ),
        ],
      ),
    );
  }
}
