import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/page/Auth/signin.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/emptyList.dart';
import 'package:bendemistim/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class VerifyEmailPage extends StatefulWidget {
  final VoidCallback? loginCallback;

  const VerifyEmailPage({Key? key, this.loginCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _body(BuildContext context) {
    var state = Provider.of<AuthState>(context, listen: false);
    return Container(
      height: fullHeight(context),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: (state.user?.emailVerified ?? false)
            ? <Widget>[
                NotifyText(
                  title: 'Your email address is verified',
                  subTitle:
                      'You have got your blue tick on your name. Cheers !!',
                ),
              ]
            : <Widget>[
                NotifyText(
                  title: 'Verify your email address',
                  subTitle:
                      'Send email verification email link to ${state.user?.email ?? ''} to verify address',
                ),
                SizedBox(
                  height: 30,
                ),
                _submitButton(context),
              ],
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Wrap(
        children: <Widget>[
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            color: Colors.blueAccent,
            onPressed: _submit,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: TitleText(
              'Send Link',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    var state = Provider.of<AuthState>(context, listen: false);
    state.sendEmailVerification(_scaffoldKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ToldyaColor.mystic,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            var state = Provider.of<AuthState>(context, listen: false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SignIn(loginCallback: state.getCurrentUser),
              ),
            );
          },
        ),
        title: customText(
          'Email Verification',
          context: context,
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _body(context),
    );
  }
}
