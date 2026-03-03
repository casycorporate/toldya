import 'package:flutter/material.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/page/common/widget/userListWidget.dart';
import 'package:toldya/state/searchState.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/emptyList.dart';
import 'package:provider/provider.dart';

class UsersListPage extends StatelessWidget {
  UsersListPage({
    Key? key,
    this.pageTitle = "",
    this.appBarIcon = Icons.person,
    this.emptyScreenText = '',
    this.emptyScreenSubTileText = '',
    this.userIdsList = const [],
  }) : super(key: key);

  final String pageTitle;
  final String emptyScreenText;
  final String emptyScreenSubTileText;
  final IconData appBarIcon;
  final List<String> userIdsList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ToldyaColor.mystic,
      appBar: CustomAppBar(
          isBackButton: true,
          title: customTitleText(pageTitle),
          icon: appBarIcon),
      body: Consumer<SearchState>(
        builder: (context, state, child) {
          final userList = userIdsList.isNotEmpty
              ? state.getuserDetail(userIdsList)
              : <UserModel>[];
          return userList.isEmpty
              ? Container(
                  width: fullWidth(context),
                  padding: EdgeInsets.only(top: 0, left: 30, right: 30),
                  child: NotifyText(
                    title: emptyScreenText,
                    subTitle: emptyScreenSubTileText,
                  ),
                )
              : UserListWidget(
                  list: userList,
                  emptyScreenText: emptyScreenText,
                  emptyScreenSubTileText: emptyScreenSubTileText,
                );
        },
      ),
    );
  }
}
