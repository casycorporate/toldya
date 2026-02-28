import 'package:flutter/material.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/page/Auth/signup.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../homePage.dart';
import 'signin.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Widget _submitButton() {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          var state = Provider.of<AuthState>(context, listen: false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SignIn(loginCallback: state.getCurrentUser),
            ),
          );
        },
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
            color: theme.colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: (theme.colorScheme.primary).withOpacity(0.35),
                offset: Offset(0, 6),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Text(
            'Giriş',
            style: GoogleFonts.sawarabiMincho(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _signUpButton() {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          var state = Provider.of<AuthState>(context, listen: false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Signup(loginCallback: state.getCurrentUser),
            ),
          );
        },
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          child: Text(
            'Kayıt ol',
            style: GoogleFonts.sawarabiMincho(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  // Widget _label() {
  //   return Container(
  //       margin: EdgeInsets.only(top: 40, bottom: 20),
  //       child: Column(
  //         children: <Widget>[
  //           Text(
  //             'Quick login with Touch ID',
  //             style: TextStyle(color: Colors.white, fontSize: 17),
  //           ),
  //           SizedBox(
  //             height: 20,
  //           ),
  //           Icon(Icons.fingerprint, size: 90, color: Colors.white),
  //           SizedBox(
  //             height: 20,
  //           ),
  //           Text(
  //             'Touch ID',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 15,
  //               decoration: TextDecoration.underline,
  //             ),
  //           ),
  //         ],
  //       ));
  // }

  Widget _title() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 't',
            style: GoogleFonts.portLligatSans(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
            children: [
              TextSpan(
                text: 'old',
                style: TextStyle(color: primary, fontSize: 42),
              ),
              TextSpan(
                text: 'ya',
                style: TextStyle(color: onSurface, fontSize: 42),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Tahminlerini paylaş, demiş mi dememiş mi gör.',
          textAlign: TextAlign.center,
          style: GoogleFonts.sawarabiMincho(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface.withOpacity(0.75),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  //eski
  // Widget _submitButton() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: 15),
  //     width: MediaQuery.of(context).size.width,
  //     child: FlatButton(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  //       color: ToldyaColor.dodgetBlue,
  //       onPressed: () {
  //         var state = Provider.of<AuthState>(context,listen: false);
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => Signup(loginCallback: state.getCurrentUser),
  //           ),
  //         );
  //       },
  //       padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
  //       child: TitleText('Hesap yarat', color: Colors.white),
  //     ),
  //   );
  // }

  Widget _body() {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 40),
                  _title(),
                  SizedBox(height: 64),
                  _submitButton(),
                  SizedBox(height: 16),
                  _signUpButton(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // Widget _body() {
  //   return SafeArea(
  //     child: Container(
  //       padding: EdgeInsets.symmetric(
  //         horizontal: 40,
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: <Widget>[
  //           Container(
  //             width: MediaQuery.of(context).size.width - 80,
  //             height: 40,
  //             child: Image.asset('assets/images/casy.png'),
  //           ),
  //           Spacer(),
  //           TitleText(
  //             'Selam doge coin nasılsın?',
  //             fontSize: 25,
  //           ),
  //           SizedBox(
  //             height: 20,
  //           ),
  //           _submitButton(),
  //           Spacer(),
  //           Wrap(
  //             alignment: WrapAlignment.center,
  //             crossAxisAlignment: WrapCrossAlignment.center,
  //             children: <Widget>[
  //               TitleText(
  //                 'Hesabınız var mı?',
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w300,
  //               ),
  //               InkWell(
  //                 onTap: () {
  //                   var state = Provider.of<AuthState>(context,listen: false);
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) =>
  //                           SignIn(loginCallback: state.getCurrentUser),
  //                     ),
  //                   );
  //                 },
  //                 child: Padding(
  //                   padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
  //                   child: TitleText(
  //                     ' Giriş',
  //                     fontSize: 14,
  //                     color: ToldyaColor.dodgetBlue,
  //                     fontWeight: FontWeight.w300,
  //                   ),
  //                 ),
  //               )
  //             ],
  //           ),
  //           SizedBox(height: 20)
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context, listen: false);
    if (state.authStatus == AuthStatus.NOT_LOGGED_IN ||
        state.authStatus == AuthStatus.NOT_DETERMINED) {
      return _body();
    }
    return HomePage();
  }
}
