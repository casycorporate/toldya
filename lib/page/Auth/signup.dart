import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/page/Auth/signin.dart';
import 'package:bendemistim/page/Auth/widget/bezierContainer.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  final VoidCallback? loginCallback;

  const Signup({Key? key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmController;
  late CustomLoader loader;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    loader = CustomLoader();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: fullHeight(context),
      color: theme.scaffoldBackgroundColor,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -MediaQuery.of(context).size.height * .15,
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
                  _entryFeild('İsim', controller: _nameController),
                  _entryFeild('E-mail giriniz',
                      controller: _emailController, isEmail: true),
                  _entryFeild('Şifre giriniz',
                      controller: _passwordController, isPassword: true),
                  _entryFeild('Tekrar şifre giriniz',
                      controller: _confirmController, isPassword: true),
                  SizedBox(height: 20),
                  _submitButton(context),
                  SizedBox(height: fullHeight(context) * .14),
                  _loginAccountLabel(),
                ],
              ),
            ),
          ),
          Positioned(top: 40, left: 0, child: _backButton()),
        ],
      ),
    );
    // return Container(
    //   height: fullHeight(context) - 88,
    //   padding: EdgeInsets.symmetric(horizontal: 30),
    //   child: Form(
    //     key: _formKey,
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: <Widget>[
    //         _entryFeild('İsim', controller: _nameController),
    //         _entryFeild('E-mail giriniz',
    //             controller: _emailController, isEmail: true),
    //         // _entryFeild('Mobile no',controller: _mobileController),
    //         _entryFeild('Şifre giriniz',
    //             controller: _passwordController, isPassword: true),
    //         _entryFeild('Tekrar şifre giriniz',
    //             controller: _confirmController, isPassword: true),
    //         _submitButton(context),
    //         SizedBox(height: 30),
    //         // _googleLoginButton(context),
    //         GoogleLoginButton(
    //           loginCallback: widget.loginCallback,
    //           loader: loader,
    //         ),
    //         SizedBox(height: 30),
    //       ],
    //     ),
    //   ),
    // );
  }
  Widget _loginAccountLabel() {
    final theme = Theme.of(context);
    return InkWell(
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
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Zaten bir hesabın var mı?',
              style: GoogleFonts.sawarabiMincho(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Giriş Yap',
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

  Widget _entryFeild(String hint,
      {required TextEditingController controller,
      bool isPassword = false,
      bool isEmail = false}) {
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
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
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

  Widget _submitButton(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _submitForm,
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
            'Hemen Kaydol',
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

  // void _googleLogin() {
  //   var state = Provider.of<AuthState>(context, listen: false);
  //   if (state.isbusy) {
  //     return;
  //   }
  //   loader.showLoader(context);
  //   state.handleGoogleSignIn().then((status) {
  //     // print(status)
  //     if (state.user != null) {
  //       loader.hideLoader();
  //       Navigator.pop(context);
  //       widget.loginCallback();
  //     } else {
  //       loader.hideLoader();
  //       cprint('Giriş yapılamıyor', errorIn: '_googleLoginButton');
  //     }
  //   });
  // }

  void _submitForm() {
    if (_nameController.text.isEmpty) {
      customSnackBar(_scaffoldKey, 'Lütfen isim giriniz');
      return;
    }
    if (_nameController.text.length > 27) {
      customSnackBar(_scaffoldKey, 'İsim uzunluğu 27 karakteri geçemez');
      return;
    }
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty) {
      customSnackBar(_scaffoldKey, 'Lütfen formu dikkatlice doldurunuz');
      return;
    } else if (_passwordController.text != _confirmController.text) {
      customSnackBar(
          _scaffoldKey, 'Parola ve doğrulama parolası eşleşmedi');
      return;
    }

    loader.showLoader(context);
    var state = Provider.of<AuthState>(context, listen: false);
    Random random = new Random();
    int randomNumber = random.nextInt(8);

    UserModel user = UserModel(
      email: _emailController.text.toLowerCase(),
      bio: 'Edit profile to update bio',
      // contact:  _mobileController.text,
      displayName: _nameController.text,
      dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
          .toString(),
      location: 'Evrende bir yerde',
      profilePic: dummyProfilePicList[randomNumber],
      isVerified: false,
      pegCount: AppIcon.pegCount,
      stashCount: 0,
      xp: 0,
      rank: AppIcon.defaultRank,
      predictorScore: 0,
      role: Role.defaultRole

    );
    state
        .signUp(
      user,
      password: _passwordController.text,
      scaffoldKey: _scaffoldKey,
    )
        .then((status) {
      print(status);
    }).whenComplete(
      () {
        loader.hideLoader();
        if (state.authStatus == AuthStatus.LOGGED_IN) {
          Navigator.pop(context);
          widget.loginCallback?.call();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _body(context),
    );
  }
}
