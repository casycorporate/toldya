import 'dart:io';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/page/Auth/selectAuthMethod.dart';
import 'package:bendemistim/page/Auth/verifyEmail.dart';
import 'package:bendemistim/page/common/updateApp.dart';
import 'package:bendemistim/page/homePage.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer();
      initDynamicLinks();
    });
    super.initState();
  }

  void initDynamicLinks() async {

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri? deepLink = dynamicLinkData.link;
      if (deepLink != null) {
        redirectFromDeepLink(deepLink);
      }
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      redirectFromDeepLink(deepLink);
    }
  }

  void redirectFromDeepLink(Uri deepLink) {
    print("Found Url from share: ${deepLink.path}");
    var type = deepLink.path.split("/")[1];
    var id = deepLink.path.split("/")[2];
    if (type == "profile") {
      Navigator.of(context).pushNamed('/ProfilePage/' + id);
    } else if (type == "toldya") {
      var feedstate = Provider.of<FeedState>(context, listen: false);
      feedstate.getpostDetailFromDatabase(id);
      Navigator.of(context).pushNamed('/FeedPostDetail/' + id);
    }
  }

  void timer() async {
    final isAppUpdated = await _checkAppVersion();
    if (isAppUpdated) {
      print("App is updated");
      Future.delayed(Duration(seconds: 1)).then((_) {
        var state = Provider.of<AuthState>(context, listen: false);
        // state.authStatus = AuthStatus.NOT_DETERMINED;
        state.getCurrentUser();
      });
    }
  }

  /// Return installed app version
  /// For testing purpose in debug mode update screen will not be open up
  /// In  an old version of  realease app is installed on user's device then
  /// User will not be able to see home screen
  /// User will redirected to update app screen.
  /// Once user update app with latest verson and back to app then user automatically redirected to welcome / Home page
  Future<bool> _checkAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final currentAppVersion = "${packageInfo.version}";
    final appVersion = await _getAppVersionFromFirebaseConfig();
    if (appVersion != currentAppVersion) {// if (appVersion != currentAppVersion) {
      if (kDebugMode) {
        cprint("Latest version of app is not installed on your system");
        cprint(
            "In debug mode we are not restrict devlopers to redirect to update screen");
        cprint(
            "Redirect devs to update screen can put other devs in confusion");
        return true;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UpdateApp(),
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  /// Returns app version from firebase config
  /// Fecth Latest app version from firebase Remote config
  /// To check current installed app version check [version] in pubspec.yaml
  /// you have to add latest app version in firebase remote config
  /// To fetch this key go to project setting in firebase
  /// Click on `cloud messaging` tab
  /// Copy server key from `Project credentials`
  /// Now goto `Remote Congig` section in fireabse
  /// Add [appVersion]  as paramerter key and below json in Default vslue
  ///  ``` json
  ///  {
  ///    "key": "1.0.0"
  ///  } ```
  /// After adding app version key click on Publish Change button
  /// For package detail check:-  https://pub.dev/packages/firebase_remote_config#-readme-tab-
  Future<String> _getAppVersionFromFirebaseConfig() async {
    final FirebaseRemoteConfig remoteConfig =
        FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    final String data = remoteConfig.getString('appVersion');
    if (data.isNotEmpty) {
      return data;
    }
    cprint(
        "Please add your app's current version into Remote config in firebase",
        errorIn: "_getAppVersionFromFirebaseConfig");
    return '0.0.0';
  }

  Widget _body() {
    return Container(
      height: fullHeight(context),
      width: fullWidth(context),
      alignment: Alignment.center,
      child: CustomScreenLoader(
        height: 150,
        width: 150,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: state.authStatus == AuthStatus.NOT_DETERMINED
          ? _body()
          : state.authStatus == AuthStatus.NOT_LOGGED_IN
              ? WelcomePage()
              : (state.user?.emailVerified ?? false) ? HomePage() : VerifyEmailPage(),
    );
  }
}
