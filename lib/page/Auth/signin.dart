import 'dart:io';

import 'package:flutter/material.dart';
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
    // _emailController.text="sinanylmaz07@gmail.com";
    // _passwordController.text="1qa2ws3ED";
    return Scaffold(
        body: Container(
          height: fullHeight(context),
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: -fullHeight(context) * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: BezierContainer()),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
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
        ));
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        var state = Provider.of<AuthState>(context,listen: false);
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
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Hemen kaydol',
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

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('veya'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
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


  Widget _entryFeild(String hint,
      {required TextEditingController controller, bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color:Color(0xfff7892b))),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _labelButton(String title, {VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Text(
        title,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
    // return FlatButton(
    //   onPressed: () {
    //     if (onPressed != null) {
    //       onPressed();
    //     }
    //   },
    //   splashColor: Colors.grey.shade200,
    //   child: Text(
    //     title,
    //         style: TextStyle(
    //             fontSize: 14, fontWeight: FontWeight.w500),
    //   ),
    // );
  }

  Widget _emailLoginButton(BuildContext context) {

    return GestureDetector(
      onTap: _emailLogin,
      child:   Container(
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
          'Giriş',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );


    // return Container(
    //   width: fullWidth(context),
    //   margin: EdgeInsets.symmetric(vertical: 35),
    //   child: FlatButton(
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    //     color: ToldyaColor.dodgetBlue,
    //     onPressed: _emailLogin,
    //     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    //     child: TitleText('Kaydol', color: Colors.white),
    //   ),
    // );
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
