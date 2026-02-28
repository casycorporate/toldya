import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/page/profile/profilePage.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class ProfileImageView extends StatelessWidget {
  const ProfileImageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const List<Choice> choices = const <Choice>[
      const Choice(title: 'Share image link', icon: Icons.share),
      const Choice(title: 'Open in browser', icon: Icons.open_in_browser),
      const Choice(title: 'Save', icon: Icons.save),
    ];
    var authstate = Provider.of<AuthState>(context, listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: (d) {
              switch (d.title) {
                case "Share image link":
                  share(authstate.profileUserModel?.profilePic ?? '');
                  break;
                case "Open in browser":
                  launchURL(authstate.profileUserModel?.profilePic ?? '');
                  break;
                case "Save":
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: _buildProfileImage(context, authstate),
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, AuthState authstate) {
    final profilePic = authstate.profileUserModel?.profilePic;
    final path = (profilePic != null && profilePic.trim().isNotEmpty)
        ? profilePic
        : DefaultProfilePics.assetForUser(authstate.profileUserModel?.userId);
    final isAsset = path.startsWith('assets/');
    return Container(
      alignment: Alignment.center,
      width: fullWidth(context),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: isAsset
              ? AssetImage(path)
              : customAdvanceNetworkImage(path),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
