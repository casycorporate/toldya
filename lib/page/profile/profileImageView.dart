import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/page/profile/profilePage.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/toldya_logo.dart';
import 'package:provider/provider.dart';

class ProfileImageView extends StatelessWidget {
  const ProfileImageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Choice> choices = [
      Choice(title: l10n.shareImageLink, icon: Icons.share),
      Choice(title: l10n.openInBrowser, icon: Icons.open_in_browser),
      Choice(title: l10n.save, icon: Icons.save),
    ];
    var authstate = Provider.of<AuthState>(context, listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: (d) {
              if (d.title == l10n.shareImageLink) {
                share(authstate.profileUserModel?.profilePic ?? '');
              } else if (d.title == l10n.openInBrowser) {
                launchURL(authstate.profileUserModel?.profilePic ?? '');
              } else if (d.title == l10n.save) {
                // Save action
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
    if (path == kToldyaLogo) {
      return Center(
        child: ToldyaLogo(
          width: fullWidth(context) * 0.6,
          fit: BoxFit.contain,
        ),
      );
    }
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
