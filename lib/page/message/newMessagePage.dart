import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/state/chats/chatState.dart';
import 'package:toldya/state/searchState.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class NewMessagePage extends StatefulWidget {
  const NewMessagePage({Key? key, this.scaffoldKey}) : super(key: key);
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<StatefulWidget> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  Widget _userTile(UserModel user) {
    return ListTile(
      onTap: () {
        final chatState = Provider.of<ChatState>(context, listen: false);
        chatState.setChatUser = user;
        Navigator.pushNamed(context, '/ChatScreenPage');
      },
      leading: customProfileImage(context, user.profilePic, userId: user.userId, height: 40),
      title: Row(
        children: <Widget>[
          ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: 0, maxWidth: fullWidth(context) - 104),
            child: TitleText(user.displayName ?? '',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 3),
          // user.isVerified
          //     ? customIcon(context,
          //         icon: AppIcon.blueTick,
          //         istwitterIcon: true,
          //         iconColor: AppColor.primary,
          //         size: 13,
          //         paddingIcon: 3)
          //     : SizedBox(width: 0),
        ],
      ),
      subtitle: Text(user.userName ?? ''),
    );
  }

  /// Cleanup when leaving: clear search filter. Back (AppBar BackButton or system) triggers PopScope, then pop.
  void _onPopInvoked(bool didPop, dynamic result) {
    if (didPop) return;
    Provider.of<SearchState>(context, listen: false).filterByUsername("");
    if (Navigator.canPop(context)) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: CustomAppBar(
          scaffoldKey: widget.scaffoldKey,
          isBackButton: true,
          isbootomLine: true,
          title: customTitleText(
            AppLocalizations.of(context)!.newMessageTitle,
          ),
        ),
        body: Consumer<SearchState>(
          builder: (context, state, child) {
            return Column(
              children: <Widget>[
                TextField(
                  onChanged: (text) {
                    state.filterByUsername(text);
                  },
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchPeopleOrGroupsHint,
                    hintStyle: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    prefixIcon: customIcon(
                      context,
                      icon: AppIcon.search,
                      istwitterIcon: true,
                      iconColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      size: 25,
                      paddingIcon: 5,
                    ),
                    border: InputBorder.none,
                    fillColor: Theme.of(context).colorScheme.surface,
                    filled: true,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) => _userTile(
                      (state.userlist ?? [])[index],
                    ),
                    separatorBuilder: (_, index) => Divider(
                      height: 0,
                    ),
                    itemCount: (state.userlist ?? []).length,
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
