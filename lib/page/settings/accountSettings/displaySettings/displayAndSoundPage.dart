import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/page/settings/widgets/headerWidget.dart';
import 'package:toldya/page/settings/widgets/settingsRowWidget.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/title_text.dart';

class DisplayAndSoundPage extends StatelessWidget {
  const DisplayAndSoundPage({Key? key}) : super(key: key);

  void openBottomSheet(
    BuildContext context,
    double height,
    Widget child,
  ) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (ctx) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: TitleText(AppLocalizations.of(context)!.darkModeTitle),
          ),
          Divider(height: 0),
          _row(AppLocalizations.of(context)!.on),
          Divider(height: 0),
          _row(AppLocalizations.of(context)!.off),
          Divider(height: 0),
          _row(AppLocalizations.of(context)!.automaticAtSunset),
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          AppLocalizations.of(context)!.displayAndSoundTitle,
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget(AppLocalizations.of(context)!.mediaHeader),
          SettingRowWidget(
            AppLocalizations.of(context)!.mediaPreviewsTitle,
            showCheckBox: false,
          ),
          Divider(height: 0),
          HeaderWidget(AppLocalizations.of(context)!.displayHeader),
          SettingRowWidget(
            AppLocalizations.of(context)!.darkModeTitle,
            subtitle: AppLocalizations.of(context)!.off,
            onPressed: () {
              openDarkModeSettings(context);
            },
            showDivider: false,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.darkModeAppearance,
            subtitle: AppLocalizations.of(context)!.dim,
            onPressed: () {
              openDarkModeAppearanceSettings(context);
            },
            showDivider: false,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.emojiTitle,
            subtitle: AppLocalizations.of(context)!.emojiSubtitle,
            showDivider: false,
            showCheckBox: false,
          ),
          HeaderWidget(
            AppLocalizations.of(context)!.soundHeader,
            secondHeader: true,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.soundEffectsTitle,
            // vPadding: 15,
            showCheckBox: false,
          ),
          HeaderWidget(
            AppLocalizations.of(context)!.webBrowserHeader,
            secondHeader: false,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.useInAppBrowserTitle,
            subtitle: AppLocalizations.of(context)!.useInAppBrowserSubtitle,
            showCheckBox: false,
          ),
        ],
      ),
    );
  }
}
