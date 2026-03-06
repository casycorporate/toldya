import 'package:flutter/material.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/page/common/usersListPage.dart';
import 'package:toldya/state/authState.dart';
import 'package:provider/provider.dart';

class FollowerListPage extends StatelessWidget {
  FollowerListPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    final username = state.profileUserModel?.userName ?? state.userModel?.userName ?? '';
    return UsersListPage(
      pageTitle: AppLocalizations.of(context)!.followersTitle,
      userIdsList: state.profileUserModel?.followersList ?? [],
      // appBarIcon: AppIcon.follow,
      emptyScreenText: AppLocalizations.of(context)!.noFollowersYet(username),
      emptyScreenSubTileText: AppLocalizations.of(context)!.followersWillAppearHere,
    );
  }
}
