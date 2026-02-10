import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/page/settings/widgets/headerWidget.dart';
import 'package:bendemistim/page/settings/widgets/settingsAppbar.dart';
import 'package:bendemistim/page/settings/widgets/settingsRowWidget.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:provider/provider.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: ToldyaColor.white,
      appBar: SettingsAppBar(
        title: 'Account',
        subtitle: user.userName ?? '',
      ),
      body: ListView(
        children: <Widget>[
          HeaderWidget('Login'),
          SettingRowWidget(
            "Username",
            subtitle: user.userName ?? '',
            // navigateTo: 'AccountSettingsPage',
          ),
          Divider(height: 0),
          // SettingRowWidget(
          //   "Phone",
          //   subtitle: user?.contact,
          // ),
          SettingRowWidget(
            "Email address",
            subtitle: user.email ?? '',
            // navigateTo: 'VerifyEmailPage',
          ),
          // SettingRowWidget("Password"),
          // SettingRowWidget("Security"),
          // HeaderWidget(
          //   'Data and Permission',
          //   secondHeader: true,
          // ),
          // SettingRowWidget("Country"),
          // SettingRowWidget("Your Fwitter data"),
          // SettingRowWidget("Apps and sessions"),
          // SettingRowWidget(
          //   "Log out",
          //   textColor: ToldyaColor.ceriseRed,
          //   onPressed: () {
          //     Navigator.popUntil(context, ModalRoute.withName('/'));
          //     final state = Provider.of<AuthState>(context);
          //     state.logoutCallback();
          //   },
          // ),
        ],
      ),
    );
  }
}
