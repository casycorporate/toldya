import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/page/Auth/selectAuthMethod.dart';
import 'package:toldya/page/Auth/verifyEmail.dart';
import 'package:toldya/page/common/updateApp.dart';
import 'package:toldya/page/homePage.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/customLoader.dart';
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
      if (!kEnablePostDetail) {
        return;
      }
      var feedstate = Provider.of<FeedState>(context, listen: false);
      feedstate.getpostDetailFromDatabase(id);
      Navigator.of(context).pushNamed('/FeedPostDetail/' + id);
    }
  }

  void timer() async {
    // Startup optimization:
    // - don't block login/navigation behind Remote Config version check
    // - kick off auth load immediately, then check version in background
    final state = Provider.of<AuthState>(context, listen: false);
    Future.microtask(() => state.getCurrentUser());

    // Version check is still enforced (release), but runs after auth begins.
    _checkAppVersion();
  }

  /// Remote Config minimum sürümü; altındaysa güncelle ekranı (release ile aynı).
  /// Debug'da sadece güncelle ekranını atlamak için `kSkipVersionUpdateScreenInDebug`.
  Future<bool> _checkAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final currentAppVersion = packageInfo.version.trim();
    final minimumVersion = await _getAppVersionFromFirebaseConfig();
    // Boş = parametre yok → güncelle ekranına gönderme (eskiden '0.0.0' herkesi blokluyordu).
    if (minimumVersion.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[RemoteConfig] appVersion boş — sürüm kapısı yok (installed=$currentAppVersion)',
        );
      }
      return true;
    }
    final needsUpdate =
        !isInstalledAppVersionAtLeast(currentAppVersion, minimumVersion);
    if (kDebugMode && !needsUpdate) {
      debugPrint(
        '[RemoteConfig] OK installed=$currentAppVersion >= minimum=$minimumVersion',
      );
    }
    if (needsUpdate) {
      if (kDebugMode) {
        debugPrint(
          '[RemoteConfig] version gate: installed=$currentAppVersion '
          'minimum=$minimumVersion → redirect to update',
        );
      }
      if (kDebugMode && kSkipVersionUpdateScreenInDebug) {
        return true;
      }
      if (!mounted) return false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UpdateApp()),
      );
      return false;
    }
    return true;
  }

  /// Remote Config `appVersion`: **minimum desteklenen** sürüm (örn. `1.0.0`).
  /// Yüklü sürüm >= bu değerse giriş serbest; düşükse güncelle ekranı.
  /// Boş bırakılırsa sürüm kapısı uygulanmaz.
  /// Firebase Console → Remote Config → String `appVersion` = düz metin `1.0.0` (JSON değil).
  Future<String> _getAppVersionFromFirebaseConfig() async {
    final FirebaseRemoteConfig remoteConfig =
        FirebaseRemoteConfig.instance;
    final updated = await remoteConfig.fetchAndActivate();
    if (kDebugMode) {
      debugPrint(
        '[RemoteConfig] fetchAndActivate updated=$updated '
        'appVersion(raw)=${remoteConfig.getString('appVersion')}',
      );
    }
    final String data = remoteConfig.getString('appVersion').trim();
    if (data.isNotEmpty) {
      return data;
    }
    cprint(
        "Remote Config [appVersion] boş — sürüm kontrolü atlanıyor. Minimum zorunlu ise "
        "Firebase’de string parametre ekleyin (örn. 1.0.0).",
        errorIn: "_getAppVersionFromFirebaseConfig");
    return '';
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
