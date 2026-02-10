import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/page/common/widget/userListWidget.dart';
import 'package:bendemistim/state/searchState.dart';
import 'package:bendemistim/widgets/customAppBar.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/emptyList.dart';
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
