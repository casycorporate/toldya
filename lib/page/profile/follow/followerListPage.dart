import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/page/common/usersListPage.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:provider/provider.dart';

class FollowerListPage extends StatelessWidget {
  FollowerListPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return UsersListPage(
      pageTitle: 'Takipçiler',
      userIdsList: state.profileUserModel?.followersList ?? [],
      // appBarIcon: AppIcon.follow,
      emptyScreenText:
          '${state?.profileUserModel?.userName ?? state.userModel?.userName ?? ''} hiç takipçisi yok',
      emptyScreenSubTileText:
          'Biri takip ettiğinde burada listelenir.',
    );
  }
}
