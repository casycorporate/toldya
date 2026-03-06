import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/widgets/toldya_logo.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/page/common/splash.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/title_text.dart';

class UpdateApp extends StatefulWidget {
  const UpdateApp({Key? key}) : super(key: key);

  @override
  _UpdateAppState createState() => _UpdateAppState();
}

class _UpdateAppState extends State<UpdateApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SplashPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ToldyaColor.mystic,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ToldyaLogo(
              height: 80,
              fit: BoxFit.contain,
            ),
            TitleText(
              AppLocalizations.of(context)!.newUpdateAvailable,
              fontSize: 25,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TitleText(
              AppLocalizations.of(context)!.unsupportedVersionMessage,
              fontSize: 14,
              color: AppColor.darkGrey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Container(
              width: fullWidth(context),
              margin: EdgeInsets.symmetric(vertical: 35),
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: ToldyaColor.dodgetBlue,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                onPressed: () {
                  launchURL(
                      "https://play.google.com/store/apps/details?id=com.casycorporate.casy");
                },
                child: TitleText(AppLocalizations.of(context)!.updateNow, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
