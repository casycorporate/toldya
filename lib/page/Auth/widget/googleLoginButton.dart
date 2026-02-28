import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';
import 'package:bendemistim/widgets/newWidget/rippleButton.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? theme.colorScheme.surface : Colors.white;
    final textColor = theme.colorScheme.onSurface.withOpacity(0.9);
    return RippleButton(
      onPressed: () => _googleLogin(context),
      borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: isDark
              ? null
              : <BoxShadow>[
                  BoxShadow(
                    color: Color(0xffeeeeee),
                    blurRadius: 15,
                    offset: Offset(5, 5),
                  ),
                ],
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/google_logo.png',
              height: 22,
              width: 22,
            ),
            SizedBox(width: 12),
            Text(
              'Google ile Bağlan',
              style: GoogleFonts.sawarabiMincho(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
