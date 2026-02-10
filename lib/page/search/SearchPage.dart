import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/state/searchState.dart';
import 'package:bendemistim/widgets/customAppBar.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/title_text.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<SearchState>(context, listen: false);
      state.resetFilterList();
    });
    super.initState();
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/TrendsPage');
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<SearchState>(context);
    final list = state.userlist;
    return Scaffold(
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey ?? GlobalKey<ScaffoldState>(),
        // icon: AppIcon.settings,
        // onActionPressed: onSettingIconPressed,
        onSearchChanged: (text) {
          state.filterByUsername(text);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          state.getDataFromDatabase();
          return Future.value(true);
        },
        child: ListView.separated(
          addAutomaticKeepAlives: false,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) => _UserTile(user: (list ?? [])[index]),
          separatorBuilder: (_, index) => Divider(
            height: 0,
          ),
          itemCount: list?.length ?? 0,
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({Key? key, this.user}) : super(key: key);
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    if (user == null) return SizedBox.shrink();
    return ListTile(
      onTap: () {
        kAnalytics.logViewSearchResults(searchTerm: user!.userName ?? '');
        Navigator.of(context).pushNamed('/ProfilePage/${user!.userId}');
      },
      leading: customImage(context, user!.profilePic ?? '', height: 40),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: TitleText(user!.displayName ?? '',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 3),
          // user.isVerified
          //     ? customIcon(
          //         context,
          //         icon: AppIcon.blueTick,
          //         istwitterIcon: true,
          //         iconColor: AppColor.primary,
          //         size: 13,
          //         paddingIcon: 3,
          //       )
          //     : SizedBox(width: 0),
        ],
      ),
      subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(user!.userName ?? ''),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: <Widget>[
                  ratingBar(user!.rank ?? 0,3,context,itemSize: 16.0),
                  SizedBox(width: 10),
                  customText(
                    (user!.rank ?? 0).toString() ,
                    // getJoiningDate(user.createdAt),
                    style: TextStyle(color: AppColor.darkGrey),
                  ),
                ],
              ),
            ),
          ]),
    );
  }
}
