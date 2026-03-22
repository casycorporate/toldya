import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/page/settings/widgets/settingsRowWidget.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';

class ProxyPage extends StatelessWidget {
  const ProxyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          AppLocalizations.of(context)!.proxyTitle,
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          SettingRowWidget(
            AppLocalizations.of(context)!.enableHttpProxyTitle,
            showCheckBox: false,
            vPadding: 15,
            showDivider: true,
            subtitle: AppLocalizations.of(context)!.enableHttpProxySubtitle,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.proxyHostTitle,
            subtitle: AppLocalizations.of(context)!.proxyHostSubtitle,
            showDivider: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.proxyPortTitle,
            subtitle: AppLocalizations.of(context)!.proxyPortSubtitle,
          ),
        ],
      ),
    );
  }
}
