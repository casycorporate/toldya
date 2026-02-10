import 'package:flutter/material.dart';
import 'package:bendemistim/helper/enum.dart';
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
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Color(0xffdf8e33).withAlpha(100),
                  offset: Offset(2, 4),
                  blurRadius: 8,
                  spreadRadius: 2)
            ],
            color: Colors.white),
        child: Text(
          'Giriş',
          style: TextStyle(fontSize: 20, color: Color(0xfff7892b)),
        ),
      ),
    );
  }

  Widget _signUpButton() {
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
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          'Kayıt ol',
          style: TextStyle(fontSize: 20, color: Colors.white),
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
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'c',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: 'as',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'y',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
          ]),
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

  Widget _body(){
    return Scaffold(
      body:SingleChildScrollView(
        child:Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xfffbb448), Color(0xffe46b10)])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _title(),
              SizedBox(
                height: 80,
              ),
              _submitButton(),
              SizedBox(
                height: 20,
              ),
              _signUpButton(),
              SizedBox(
                height: 20,
              ),
              // _label()
            ],
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
  //             child: Image.asset('assets/images/icon-480.png'),
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
    var state = Provider.of<AuthState>(context,listen: false);
    return Scaffold(
      body: state.authStatus == AuthStatus.NOT_LOGGED_IN ||
              state.authStatus == AuthStatus.NOT_DETERMINED
          ? _body()
          : HomePage(),
    );
  }
}
