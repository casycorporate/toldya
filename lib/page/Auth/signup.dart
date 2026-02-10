import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
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

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _body(BuildContext context) {

    return  Container(
        height: fullHeight(context),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer(),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: fullHeight(context) * .2),
                    _title(),
                    SizedBox(
                      height: 50,
                    ),
                            _entryFeild('İsim', controller: _nameController),
                            _entryFeild('E-mail giriniz',
                                controller: _emailController, isEmail: true),
                            // _entryFeild('Mobile no',controller: _mobileController),
                            _entryFeild('Şifre giriniz',
                                controller: _passwordController, isPassword: true),
                            _entryFeild('Tekrar şifre giriniz',
                                controller: _confirmController, isPassword: true),
                    SizedBox(
                      height: 20,
                    ),
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
    return InkWell(
      onTap: () {
        var state = Provider.of<AuthState>(context,listen: false);
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
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Giriş Yap',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'c',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.headlineLarge,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xffe46b10),
          ),
          children: [
            TextSpan(
              text: 'as',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'y',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            ),
          ]),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Geri',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryFeild(String hint,
      {required TextEditingController controller,
      bool isPassword = false,
      bool isEmail = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
            borderSide: BorderSide(color: Color(0xfff7892b)),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return GestureDetector(
      onTap:_submitForm,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)])),
        child: Text(
          'Hemen Kaydol',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );

    // return Container(
    //   margin: EdgeInsets.symmetric(vertical: 15),
    //   width: MediaQuery.of(context).size.width,
    //   child: FlatButton(
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    //     color: ToldyaColor.dodgetBlue,
    //     onPressed: _submitForm,
    //     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    //     child: Text('Kayıt', style: TextStyle(color: Colors.white)),
    //   ),
    // );
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
    if (_emailController.text.isEmpty) {
      customSnackBar(_scaffoldKey, 'Lütfen isim giriniz');
      return;
    }
    if (_emailController.text.length > 27) {
      customSnackBar(_scaffoldKey, 'İsim uzunluğu 27 karakteri geçemez');
      return;
    }
    if (_emailController.text == null ||
        _emailController.text.isEmpty ||
        _passwordController.text == null ||
        _passwordController.text.isEmpty ||
        _confirmController.text == null) {
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
    return Scaffold(
      key: _scaffoldKey,
      // appBar: AppBar(
      //   title: customText(
      //     'Kaydol',
      //     context: context,
      //     style: TextStyle(fontSize: 20),
      //   ),
      //   centerTitle: true,
      // ),
      body: SingleChildScrollView(child: _body(context)),
    );
  }
}
