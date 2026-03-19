import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/widgets/newWidget/customLoader.dart';
import 'package:toldya/widgets/newWidget/rippleButton.dart';

class AppleLoginButton extends StatelessWidget {
  const AppleLoginButton({
    super.key,
    required this.loader,
    this.loginCallback,
  });

  final CustomLoader loader;
  final Function? loginCallback;

  void _appleLogin(BuildContext context) {
    final state = Provider.of<AuthState>(context, listen: false);
    loader.showLoader(context);

    state.handleAppleSignIn().then((_) {
      loader.hideLoader();
      if (state.user != null) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        loginCallback?.call();
      } else {
        cprint('Unable to login', errorIn: '_appleLoginButton');
      }
    }).catchError((Object error, StackTrace stackTrace) {
      loader.hideLoader();
      cprint(error, errorIn: '_appleLogin');

      String message = AppLocalizations.of(context)!.appleSignInFailed;
      if (error is PlatformException) {
        if (error.code == 'sign_in_failed' && error.message?.contains('10') == true) {
          message = AppLocalizations.of(context)!.appleSignInNotConfigured;
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
      onPressed: () => _appleLogin(context),
      borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                    color: const Color(0xffeeeeee),
                    blurRadius: 15,
                    offset: const Offset(5, 5),
                  ),
                ],
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Icon(Icons.apple, size: 22, color: textColor),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.appleSignInButton,
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

