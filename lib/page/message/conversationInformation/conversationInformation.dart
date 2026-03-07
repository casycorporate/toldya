import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/page/settings/widgets/headerWidget.dart';
import 'package:toldya/page/settings/widgets/settingsRowWidget.dart';
import 'package:toldya/state/chats/chatState.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/customUrlText.dart';
import 'package:toldya/widgets/newWidget/rippleButton.dart';
import 'package:provider/provider.dart';

class ConversationInformation extends StatelessWidget {
  const ConversationInformation({Key? key}) : super(key: key);

  Widget _header(BuildContext context, UserModel user) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 25),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: SizedBox(
                height: 80,
                width: 80,
                child: RippleButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed('/ProfilePage/' + (user?.userId ?? ''));
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: customProfileImage(context, user.profilePic, userId: user.userId, height: 80),
                )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              UrlText(
                text: user.displayName ?? '',
                style: onPrimaryTitleText.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                width: 3,
              ),
              (user.isVerified ?? false)
                  ? customIcon(
                      context,
                      icon: AppIcon.blueTick,
                      istwitterIcon: true,
                      iconColor: AppColor.primary,
                      size: 18,
                      paddingIcon: 3,
                    )
                  : SizedBox(width: 0),
            ],
          ),
          customText(
            user.userName ?? '',
            context: context,
            style: onPrimarySubTitleText.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<ChatState>(context).chatUser ?? UserModel();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          AppLocalizations.of(context)!.conversationInformationTitle,
        ),
      ),
      body: ListView(
        children: <Widget>[
          _header(context, user),
          HeaderWidget(AppLocalizations.of(context)!.notificationsTitle),
          SettingRowWidget(
            AppLocalizations.of(context)!.muteConversation,
            visibleSwitch: true,
          ),
          Container(
            height: 15,
            color: Theme.of(context).colorScheme.surface,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.blockUser(user.userName ?? ''),
            textColor: ToldyaColor.dodgetBlue,
            showDivider: false,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.reportUser(user.userName ?? ''),
            textColor: ToldyaColor.dodgetBlue,
            showDivider: false,
          ),
          SettingRowWidget(
            AppLocalizations.of(context)!.deleteConversationTitle,
            textColor: ToldyaColor.ceriseRed,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}
