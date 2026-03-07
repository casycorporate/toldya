import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/page/settings/widgets/settingsRowWidget.dart';
import 'package:toldya/state/searchState.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class TrendsPage extends StatelessWidget {
  String sortBy = "";

  TrendsPage({Key? key}) : super(key: key);

  void openBottomSheet(
      BuildContext context, double height, Widget child) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: ToldyaColor.white,
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

  void openUserSortSettings(BuildContext context) {
    openBottomSheet(
      context,
      340,
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
            child: TitleText(AppLocalizations.of(context)!.sortUserList),
          ),
          Divider(height: 0),
          _row(context, AppLocalizations.of(context)!.verifiedUserFirst, SortUser.ByVerified),
          Divider(height: 0),
          _row(context, AppLocalizations.of(context)!.alphabeticallySort, SortUser.ByAlphabetically),
          Divider(height: 0),
          _row(context, AppLocalizations.of(context)!.newestUserFirst, SortUser.ByNewest),
          Divider(height: 0),
          _row(context, AppLocalizations.of(context)!.oldestUserFirst, SortUser.ByOldest),
          Divider(height: 0),
          _row(context, AppLocalizations.of(context)!.maxFollowerFirst, SortUser.ByMaxFollower),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String text, SortUser sortBy) {
    final state = Provider.of<SearchState>(context,listen: false);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      child: RadioListTile<SortUser>(
        value: sortBy,
        activeColor: ToldyaColor.dodgetBlue,
        groupValue: state.sortBy,
        onChanged: (val) {
          if (val != null) state.updateUserSortPrefrence = val;
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
        title: Text(text, style: subtitleStyle),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<SearchState>(context, listen: false);
      sortBy = state.selectedFilter;
    });
    final l10n = AppLocalizations.of(context)!;
    final sortLabel = switch (sortBy) {
      'verifiedUserFirst' => l10n.verifiedUserFirst,
      'alphabeticallySort' => l10n.alphabeticallySort,
      'newestUserFirst' => l10n.newestUserFirst,
      'oldestUserFirst' => l10n.oldestUserFirst,
      'maxFollowerFirst' => l10n.maxFollowerFirst,
      _ => '',
    };
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          AppLocalizations.of(context)!.trendsTitle,
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          SettingRowWidget(
            AppLocalizations.of(context)!.searchFilterTitle,
            subtitle: sortLabel,
            onPressed: () {
              openUserSortSettings(context);
            },
            showDivider: false,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.trendsLocationTitle,
            navigateTo: null,
            subtitle: AppLocalizations.of(context)!.trendsLocationSubtitle,
            showDivider: false,
          ),
          SettingRowWidget(
            '',
            subtitle:
                AppLocalizations.of(context)!.trendsLocationHint,
                // 'You can see what\'s trending in a specfic location by selecting which location appears in your Trending tab.',
            navigateTo: null,
            showDivider: false,
            vPadding: 12,
          ),
        ],
      ),
    );
  }
}
