import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/page/Auth/signup.dart';
import 'package:bendemistim/page/Auth/widget/bezierContainer.dart';
import 'package:bendemistim/page/Auth/widget/googleLoginButton.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignIn extends StatefulWidget {
  final VoidCallback? loginCallback;

  const SignIn({Key? key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late CustomLoader loader;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    loader = CustomLoader();
  }
  @override
  void dispose() { 
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Widget _body(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        height: fullHeight(context),
        color: theme.scaffoldBackgroundColor,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -fullHeight(context) * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer(),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: fullHeight(context) * .2),
                      _title(),
                      SizedBox(height: 50),
                      _entryFeild('Lütfen E-mail giriniz', controller: _emailController),
                      _entryFeild('Lütfen şifre giriniz',
                          controller: _passwordController, isPassword: true),
                      SizedBox(height: 20),
                      _emailLoginButton(context),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.centerRight,
                        child: _labelButton('Şifreyi unuttum?', onPressed: () {
                          Navigator.of(context).pushNamed('/ForgetPasswordPage');
                        }),
                        // child: Text('Forgot Password ?',
                        //     style: TextStyle(
                        //         fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                      _divider(),
                      GoogleLoginButton(
                        loginCallback: widget.loginCallback,
                        loader: loader,
                      ),
                      Platform.isIOS ? _divider() :SizedBox(),
                      // Platform.isIOS ? SignInWithAppleButton(text: "Apple ile Bağlan",
                      //   style: SignInWithAppleButtonStyle.white,
                      //   iconAlignment: IconAlignment.center,
                      //   onPressed: () {
                      //     context.read<AuthState>().signInWithApple();
                      //   },
                      // ) : SizedBox(),
                      SizedBox(height: fullHeight(context) * .055),
                      _createAccountLabel(),
                    ],
                  ),
                ),
              ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }

  Widget _createAccountLabel() {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        var state = Provider.of<AuthState>(context, listen: false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Signup(loginCallback: state.getCurrentUser),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Henüz bir hesabın yok mu?',
              style: GoogleFonts.sawarabiMincho(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Hemen kaydol',
              style: GoogleFonts.sawarabiMincho(
                color: theme.colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
                color: theme.dividerColor,
              ),
            ),
          ),
          Text(
            'veya',
            style: GoogleFonts.sawarabiMincho(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
                color: theme.dividerColor,
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }
  Widget _backButton() {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(
                Icons.keyboard_arrow_left,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Geri',
              style: GoogleFonts.sawarabiMincho(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 't',
        style: GoogleFonts.portLligatSans(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        children: [
          TextSpan(text: 'old', style: TextStyle(color: primary, fontSize: 30)),
          TextSpan(text: 'ya', style: TextStyle(color: onSurface, fontSize: 30)),
        ],
      ),
    );
  }


  Widget _entryFeild(String hint,
      {required TextEditingController controller, bool isPassword = false}) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: GoogleFonts.sawarabiMincho(
          fontSize: 16,
          color: theme.colorScheme.onSurface,
        ),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontSize: 16,
          ),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _labelButton(String title, {VoidCallback? onPressed}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      child: Text(
        title,
        style: GoogleFonts.sawarabiMincho(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _emailLoginButton(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _emailLogin,
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
                color: theme.colorScheme.primary.withOpacity(0.35),
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

  void _emailLogin() {
    var state = Provider.of<AuthState>(context, listen: false);
    if (state.isbusy) {
      return;
    }
    loader.showLoader(context);
    var isValid = validateCredentials(
        _scaffoldKey, _emailController.text, _passwordController.text);
    if (isValid) {
      state
          .signIn(_emailController.text, _passwordController.text,
              scaffoldKey: _scaffoldKey)
          .then((status) {
        if (state.user != null) {
          loader.hideLoader();
          Navigator.pop(context);
          widget.loginCallback?.call();
        } else {
          cprint('Giriş yapılamıyor', errorIn: '_emailLoginButton');
          loader.hideLoader();
        }
      });
    } else {
      loader.hideLoader();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // appBar: AppBar(
      //   title: customText('Sign in',
      //       context: context, style: TextStyle(fontSize: 20)),
      //   centerTitle: true,
      // ),
      body: _body(context),
    );
  }
}
