import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';
import 'package:bendemistim/widgets/newWidget/rippleButton.dart';
import 'package:bendemistim/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({Key? key, required this.loader, this.loginCallback});
  final CustomLoader loader;
  final Function? loginCallback;
  void _googleLogin(BuildContext context) {
    var state = Provider.of<AuthState>(context, listen: false);
    loader.showLoader(context);
    state.handleGoogleSignIn().then((status) {
      loader.hideLoader();
      if (state.user != null) {
        Navigator.pop(context);
        loginCallback?.call();
      } else {
        cprint('Unable to login', errorIn: '_googleLoginButton');
      }
    }).catchError((Object error, StackTrace stackTrace) {
      loader.hideLoader();
      cprint(error, errorIn: '_googleLogin');
      String message = 'Google ile giriş yapılamadı.';
      if (error is PlatformException) {
        if (error.code == 'sign_in_failed' && error.message?.contains('10') == true) {
          message = 'Google girişi yapılandırılmamış. Firebase Console\'da uygulama SHA parmak izini ekleyin.';
        } else if (error.message != null && error.message!.isNotEmpty) {
          message = error.message!;
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RippleButton(
      onPressed: () => _googleLogin(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0xffeeeeee),
              blurRadius: 15,
              offset: Offset(5, 5),
            ),
          ],
        ),
        child: Wrap(
          children: <Widget>[
            Image.asset(
              'assets/images/google_logo.png',
              height: 20,
              width: 20,
            ),
            SizedBox(width: 10),
            TitleText(
              'Google ile Bağlan',
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
