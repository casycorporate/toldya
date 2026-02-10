import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/page/common/usersListPage.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:provider/provider.dart';

class FollowingListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return UsersListPage(
        pageTitle: 'Takip Et',
        userIdsList: state.profileUserModel?.followingList ?? [],
        // appBarIcon: AppIcon.follow,
        emptyScreenText:
            '${state?.profileUserModel?.userName ?? state.userModel?.userName ?? ''} kimseyi takip etmiyor',
        emptyScreenSubTileText: 'Takip ettiğinde burada listelenirler.');
  }
}
