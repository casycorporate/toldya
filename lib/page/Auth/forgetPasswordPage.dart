import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/page/Auth/widget/bezierContainer.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
class ForgetPasswordPage extends StatefulWidget{
  final VoidCallback? loginCallback;

  const ForgetPasswordPage({Key? key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ForgetPasswordPageState();

}

class _ForgetPasswordPageState extends State<ForgetPasswordPage>{
  late FocusNode _focusNode;
  late TextEditingController _emailController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() { 
    super.initState();
    _focusNode = FocusNode();
    _emailController = TextEditingController();
    _emailController.text = '';
    _focusNode.requestFocus();
    super.initState();
  }
  @override
  void dispose(){
    _focusNode.dispose();
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
            padding: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding),
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
                  _entryFeild('Enter email',controller: _emailController),
                  SizedBox(
                    height: 20,
                  ),
                  _submitButton(context),
                  SizedBox(height: fullHeight(context) * .14),
                  // _loginAccountLabel(),
                ],
              ),
            ),
          ),
          Positioned(top: 40, left: 0, child: _backButton()),
        ],
      ),
    );
  // return Container(
  //   height: fullHeight(context),
  //   padding: EdgeInsets.symmetric(horizontal: 30),
  //     child:Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: <Widget>[
  //         _label(),
  //         SizedBox(height: 50,),
  //         _entryFeild('Enter email',controller: _emailController),
  //         // SizedBox(height: 10,),
  //         _submitButton(context),
  //     ],)
  // );
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
              child: Icon(Icons.keyboard_arrow_left, color: theme.colorScheme.onSurface),
            ),
            Text('Geri',
                style: GoogleFonts.sawarabiMincho(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface))
          ],
        ),
      ),
    );
  }

  Widget _title() {
    final theme = Theme.of(context);
    final onS = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 't',
        style: GoogleFonts.portLligatSans(fontSize: 30, fontWeight: FontWeight.w700, color: onS),
        children: [
          TextSpan(text: 'old', style: TextStyle(color: primary, fontSize: 30)),
          TextSpan(text: 'ya', style: TextStyle(color: onS, fontSize: 30)),
        ],
      ),
    );
  }
  Widget _entryFeild(String hint, {required TextEditingController controller, bool isPassword = false}) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: TextField(
        focusNode: _focusNode,
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: GoogleFonts.sawarabiMincho(fontSize: 16, color: theme.colorScheme.onSurface),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
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
        onTap: _submit,
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
            color: theme.colorScheme.primary,
          ),
          child: Text(
            'Şifre sıfırlama bağlantısı gönder',
            style: GoogleFonts.sawarabiMincho(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }

  // Widget _label(){
  //   return Container(
  //     child:Column(
  //       children: <Widget>[
  //         customText('Forget Password',style:TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
  //         SizedBox(height: 15),
  //         Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 20),
  //           child: customText('Enter your email address below to receive password reset instruction',
  //         style:TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black54),textAlign: TextAlign.center),
  //
  //         )
  //       ],
  //     )
  //   );
  // }
  void _submit(){
    if(_emailController.text == null || _emailController.text.isEmpty){
      customSnackBar(_scaffoldKey, 'E-posta alanı boş olamaz');
      return;
    }
    var isValidEmail = validateEmal(_emailController.text, );
    if(!isValidEmail){
       customSnackBar(_scaffoldKey, 'Lütfen geçerli bir e-posta adresi girin');
      return;
    }

    _focusNode.unfocus();
    var state = Provider.of<AuthState>(context,listen: false);
    state.forgetPassword(_emailController.text,scaffoldKey:_scaffoldKey);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _body(context),
    );
  }
}