import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/page/settings/widgets/headerWidget.dart';
import 'package:bendemistim/page/settings/widgets/settingsAppbar.dart';
import 'package:bendemistim/page/settings/widgets/settingsRowWidget.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:provider/provider.dart';

class ContentPrefrencePage extends StatelessWidget {
  const ContentPrefrencePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: ToldyaColor.white,
      appBar: SettingsAppBar(
        title: 'Content preferences',
        subtitle: user.userName ?? '',
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget('Explore'),
          SettingRowWidget(
            "Liderlik Tablosu",
            navigateTo: 'LeaderboardPage',
          ),
          SettingRowWidget(
            "Trends",
            navigateTo: 'TrendsPage',
          ),
          Divider(height: 0),
          SettingRowWidget(
            "Search settings",
            navigateTo: '',
          ),
          HeaderWidget(
            'Languages',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Recommendations",
            vPadding: 15,
            subtitle:
                "Select which language you want recommended Tweets, people, and trends to include",
          ),
          HeaderWidget(
            'Safety',
            secondHeader: true,
          ),
          SettingRowWidget("Blocked accounts"),
          SettingRowWidget("Muted accounts"),
        ],
      ),
    );
  }
}
