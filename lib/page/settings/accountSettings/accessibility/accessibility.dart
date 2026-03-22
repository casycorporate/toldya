import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/page/settings/widgets/headerWidget.dart';
import 'package:toldya/page/settings/widgets/settingsRowWidget.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/title_text.dart';

class AccessibilityPage extends StatelessWidget {
  const AccessibilityPage({Key? key}) : super(key: key);

  void openBottomSheet(
    BuildContext context,
    double height,
    Widget child,
  ) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: MockupDesign.card,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: child,
        );
      },
    );
  }

  void openDarkModeSettings(BuildContext context) {
    openBottomSheet(
      context,
      250,
      Column(
        children: <Widget>[
          SizedBox(height: 5),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: ToldyaColor.paleSky50,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: TitleText(AppLocalizations.of(context)!.dataPreference),
          ),
          Divider(height: 0),
          _row(AppLocalizations.of(context)!.mobileDataWifi),
          Divider(height: 0),
          _row(AppLocalizations.of(context)!.wifiOnly),
          Divider(height: 0),
          _row(AppLocalizations.of(context)!.never),
        ],
      ),
    );
  }

  void openDarkModeAppearanceSettings(BuildContext context) {
    openBottomSheet(
      context,
      190,
      Column(
        children: <Widget>[
          SizedBox(height: 5),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: ToldyaColor.paleSky50,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: TitleText(AppLocalizations.of(context)!.darkModeAppearance),
          ),
          Divider(height: 0),
          _row(AppLocalizations.of(context)!.dim),
          Divider(height: 0),
          _row(AppLocalizations.of(context)!.lightOut),
        ],
      ),
    );
  }

  Widget _row(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      child: RadioListTile(
        value: false,
        groupValue: true,
        onChanged: (val) {},
        title: Text(text),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          l10n.accessibilityTitle,
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget(l10n.screenReaderHeader),
          SettingRowWidget(
            l10n.pronounceHashtagTitle,
            subtitle: l10n.featureComingSoon(l10n.pronounceHashtagTitle),
          ),
          Divider(height: 0),
          HeaderWidget(l10n.visionHeader),
          SettingRowWidget(
            l10n.composeImageDescriptionsTitle,
            subtitle: l10n.featureComingSoon(l10n.composeImageDescriptionsTitle),
            vPadding: 15,
            showCheckBox: false,
            showDivider: false,
          ),
          HeaderWidget(
            l10n.motionHeader,
            secondHeader: true,
          ),
          SettingRowWidget(
            l10n.reduceMotionTitle,
            subtitle: l10n.featureComingSoon(l10n.reduceMotionTitle),
            vPadding: 15,
            showCheckBox: false,
          ),
          SettingRowWidget(
            l10n.videoAutoplayTitle,
            subtitle: l10n.featureComingSoon(l10n.videoAutoplayTitle),
          ),
        ],
      ),
    );
  }
}
