import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key? key}) : super(key: key);
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late String _image;
  late String _banner;
  late TextEditingController _name;
  late TextEditingController _bio;
  late TextEditingController _location;
  late TextEditingController _dob;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String dob;
  @override
  void initState() {
    super.initState();
    _image = '';
    _banner = '';
    _name = TextEditingController();
    _bio = TextEditingController();
    _location = TextEditingController();
    _dob = TextEditingController();
    dob = '';
    var state = Provider.of<AuthState>(context, listen: false);
    _name.text = state.userModel?.displayName ?? '';
    _bio.text = state.userModel?.bio ?? '';
    _location.text = state.userModel?.location ?? '';
    _dob.text = getdob(state.userModel?.dob ?? '');
  }

  void dispose() {
    _name.dispose();
    _bio.dispose();
    _location.dispose();
    _dob.dispose();
    super.dispose();
  }

  Widget _body() {
    var authstate = Provider.of<AuthState>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 180,
          child: Stack(
            children: <Widget>[
              _bannerImage(authstate),
              Align(
                alignment: Alignment.bottomLeft,
                child: _userImage(authstate),
              ),
            ],
          ),
        ),
        _entry('Name', controller: _name),
        _entry('Bio', controller: _bio, maxLine: 3),
        _entry('Location', controller: _location),
        InkWell(
          onTap: showCalender,
          child: _entry('Date of birth', isenable: false, controller: _dob),
        )
      ],
    );
  }

  Widget _userImage(AuthState authstate) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      height: 90,
      width: 90,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 5),
        shape: BoxShape.circle,
        image: DecorationImage(
            image: customAdvanceNetworkImage(authstate.userModel?.profilePic ?? ''),
            fit: BoxFit.cover),
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundImage: _image != null
            ? NetworkImage(_image)
            : customAdvanceNetworkImage(authstate.userModel?.profilePic ?? ''),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black38,
          ),
          child: Center(
            child: IconButton(
              onPressed: uploadImage,
              icon: Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bannerImage(AuthState authstate) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        image: authstate.userModel?.bannerImage == null
            ? null
            : DecorationImage(
                image:
                    customAdvanceNetworkImage(authstate.userModel?.bannerImage ?? ''),
                fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black45,
        ),
        child: Stack(
          children: [
            _banner != null
                ? Image.network(_banner,
                    fit: BoxFit.fill, width: MediaQuery.of(context).size.width)
                : customNetworkImage(
                    authstate.userModel?.bannerImage ??
                        '',
                    fit: BoxFit.fill),
            Center(
              child: IconButton(
                onPressed: uploadBanner,
                icon: Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entry(String title,
      {required TextEditingController controller,
      int maxLine = 1,
      bool isenable = true}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          customText(title, style: TextStyle(color: Colors.black54)),
          TextField(
            enabled: isenable,
            controller: controller,
            maxLines: maxLine,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            ),
          )
        ],
      ),
    );
  }

  void showCalender() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2019, DateTime.now().month, DateTime.now().day),
      firstDate: DateTime(1950, DateTime.now().month, DateTime.now().day + 3),
      lastDate: DateTime.now().add(Duration(days: 7)),
    );
    setState(() {
      if (picked != null) {
        dob = picked.toString();
        _dob.text = getdob(dob);
      }
    });
  }

  void _submitButton() {
    if (_name.text.length > 27) {
      customSnackBar(_scaffoldKey, 'İsim uzunluğu 27 karakteri aşamaz');
      return;
    }
    var state = Provider.of<AuthState>(context, listen: false);
    final um = state.userModel;
    if (um == null) return;
    var model = um.copyWith(
      key: um.userId,
      displayName: um.displayName,
      bio: um.bio,
      contact: um.contact,
      dob: um.dob,
      email: um.email,
      location: um.location,
      profilePic: um.profilePic,
      userId: um.userId,
      bannerImage: um.bannerImage,
      pegCount: um.pegCount,
      role: um.role,
      rank: um.rank,

    );
    if (_name.text != null && _name.text.isNotEmpty) {
      model.displayName = _name.text;
    }
    if (_bio.text != null && _bio.text.isNotEmpty) {
      model.bio = _bio.text;
    }
    if (_location.text != null && _location.text.isNotEmpty) {
      model.location = _location.text;
    }
    if (dob != null) {
      model.dob = dob;
    }
    state.updateUserProfile(model,_scaffoldKey, image: _image, bannerImage: _banner);
    Navigator.of(context).pop();
  }

  void uploadImage() {
    openImagePicker(context, (file) {
      setState(() {
        _image = file;
      });
    },0);
  }

  void uploadBanner() {
    openImagePicker(context, (file) {
      setState(() {
        _banner = file;
      });
    },1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blue),
        title: customTitleText('Profile Edit'),
        actions: <Widget>[
          InkWell(
            onTap: _submitButton,
            child: Center(
              child: Text(
                'Kaydet',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: _body(),
      ),
    );
  }
}
