import 'package:flutter/material.dart';
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
  Widget _body(BuildContext context){
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
            Text('Back',
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
  Widget _entryFeild(String hint,{required TextEditingController controller,bool isPassword = false}){
  return Container(
    margin: EdgeInsets.symmetric(vertical: 15),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(30)
    ),
    child: TextField(
      focusNode: _focusNode,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(fontStyle: FontStyle.normal,fontWeight: FontWeight.normal),
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,

        border: InputBorder.none,
        focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color:  Color(0xfff7892b))),
        contentPadding:EdgeInsets.symmetric(vertical: 15,horizontal: 10)
      ),
    ),
  );
}
  Widget _submitButton(BuildContext context){
    return GestureDetector(
        onTap:_submit,
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
            'Register Now',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ));
    // return Container(
    //   margin: EdgeInsets.symmetric(vertical: 15),
    //   width: MediaQuery.of(context).size.width,
    //   child: FlatButton(
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    //     color: ToldyaColor.dodgetBlue,
    //     onPressed:_submit,
    //     padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
    //     child: Text('Submit',style:TextStyle(color: Colors.white)),
    //   )
    // );
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
      // appBar: AppBar(
      //   title: customText('Forget Password',context: context,style: TextStyle(fontSize: 20)),
      //   centerTitle: true,
      // ),
      body: _body(context),
    );
  }
  
}