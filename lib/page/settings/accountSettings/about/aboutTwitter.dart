import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/page/settings/widgets/headerWidget.dart';
import 'package:toldya/page/settings/widgets/settingsRowWidget.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/toldya_logo.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          AppLocalizations.of(context)!.aboutToldya,
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: ToldyaLogo(
                height: 56,
                fit: BoxFit.contain,
              ),
            ),
          ),
          HeaderWidget(
            AppLocalizations.of(context)!.helpHeader,
            secondHeader: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.helpCenterTitle,
            vPadding: 0,
            showDivider: false,
            onPressed: (){
              launchURL("https://github.com/casycorporate/toldya/issues");
            },
          ),
          HeaderWidget(AppLocalizations.of(context)!.legal),
          SettingRowWidget(
            AppLocalizations.of(context)!.termsOfServiceTitle,
            showDivider: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.privacyPolicyTitle,
            showDivider: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.cookieUseTitle,
            showDivider: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.legalNoticesTitle,
            showDivider: true,
            onPressed: () async {
              showLicensePage(
                context: context,
                applicationName: 'Toldya',
                applicationVersion: '1.0.0',
                useRootNavigator: true,
              );
            },
          ),
          HeaderWidget(AppLocalizations.of(context)!.developer),
          SettingRowWidget(
            "Github",
            showDivider: true,
            onPressed: (){
              launchURL("https://github.com/TheAlphamerc");
            }
          ),
          SettingRowWidget(
            "LinkidIn",
            showDivider: true,
            onPressed: (){
              launchURL("https://www.linkedin.com/in/thealphamerc/");
            }
          ),
          SettingRowWidget(
            "Twitter",
            showDivider: true,
            onPressed: (){
              launchURL("https://twitter.com/TheAlphaMerc");
            }
          ),
          SettingRowWidget(
            "Blog",
            showDivider: true,
            onPressed: (){
              launchURL("https://dev.to/thealphamerc");
            }
          ),
        ],
      ),
    );
  }
}
