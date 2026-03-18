import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/customUrlText.dart';
import 'package:toldya/widgets/rank/rankBadgeWidget.dart';
import 'package:toldya/widgets/toldya_logo.dart';
import 'package:provider/provider.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  static const double _headerPaddingH = 16.0;
  static const double _avatarSize = 56.0;
  static const double _avatarRingWidth = 1.5;

  Widget _menuHeader() {
    final state = Provider.of<AuthState>(context);
    final l10n = AppLocalizations.of(context)!;
    if (state.userModel == null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _navigateTo('SignIn');
          },
          borderRadius: BorderRadius.circular(radiusMedium),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: _headerPaddingH),
            child: Center(
              child: Text(
                l10n.signInToContinue,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(_headerPaddingH, 12, _headerPaddingH, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () => _navigateTo('profile/${state.userId}'),
            child: Row(
              children: <Widget>[
                Container(
                  height: _avatarSize,
                  width: _avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: _avatarRingWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: (state.userModel?.profilePic ?? dummyProfilePic) == kToldyaLogo
                        ? ToldyaLogo(
                            width: _avatarSize,
                            height: _avatarSize,
                            fit: BoxFit.cover,
                          )
                        : Image(
                            image: customAdvanceNetworkImage(
                              state.userModel?.profilePic ?? dummyProfilePic,
                            ),
                            fit: BoxFit.cover,
                            width: _avatarSize,
                            height: _avatarSize,
                          ),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      UrlText(
                        text: state.userModel?.displayName ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        state.userModel?.userName ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RankBadgeWidget(
                          xp: state.userModel?.xp ?? 0,
                          compact: true,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: _tappbleText(
                              context,
                              '${state.userModel?.getFollower() ?? 0}',
                              l10n.followersTitle,
                              'FollowerListPage',
                            ),
                          ),
                          SizedBox(width: 12),
                          Flexible(
                            child: _tappbleText(
                              context,
                              '${state.userModel?.getFollowing() ?? 0}',
                              l10n.followingCountLabel,
                              'FollowingListPage',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade500,
                  size: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tappbleText(
    BuildContext context,
    String count,
    String text,
    String navigateTo,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Provider.of<AuthState>(context, listen: false).getProfileUser();
          _navigateTo(navigateTo);
        },
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                count,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuListRowButton(
    String title, {
    Function? onPressed,
    IconData? icon,
    bool isEnable = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed != null
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed();
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppNeon.cyan.withOpacity(0.12),
          child: Container(
            decoration: BoxDecoration(
              color: MockupDesign.card.withOpacity(0.72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MockupDesign.cardBorder.withOpacity(0.7),
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              minVerticalPadding: 0,
              leading: icon != null
                  ? Icon(
                      icon,
                      size: 22,
                      color: isEnable ? AppNeon.cyan : Colors.grey.shade500,
                    )
                  : null,
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isEnable ? Colors.white : Colors.grey.shade500,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey.shade600,
              ),
              tileColor: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  // Positioned _footer() {
  //   return Positioned(
  //     bottom: 0,
  //     right: 0,
  //     left: 0,
  //     child: Column(
  //       children: <Widget>[
  //         Divider(height: 0),
  //         Row(
  //           children: <Widget>[
  //             SizedBox(
  //               width: 10,
  //               height: 45,
  //             ),
  //             customIcon(context,
  //                 icon: AppIcon.bulbOn,
  //                 istwitterIcon: true,
  //                 size: 25,
  //                 iconColor: ToldyaColor.dodgetBlue),
  //             Spacer(),
  //             Image.asset(
  //               "assets/images/qr.png",
  //               height: 25,
  //             ),
  //             SizedBox(
  //               width: 10,
  //               height: 45,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _logOut() {
    final state = Provider.of<AuthState>(context, listen: false);
    if (Navigator.canPop(context)) Navigator.pop(context);
    state.logoutCallback();
  }

  void _navigateTo(String path) {
    if (Navigator.canPop(context)) Navigator.pop(context);
    Navigator.of(context).pushNamed('/$path');
  }

  Widget _walletCard(AuthState authState) {
    final l10n = AppLocalizations.of(context)!;
    final pegCount = authState.userModel?.pegCount ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MockupDesign.card.withOpacity(0.72),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: MockupDesign.cardBorder.withOpacity(0.75),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.drawerWalletTitle,
                  style: TextStyle(
                    color: MockupDesign.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$pegCount',
                  style: TextStyle(
                    color: AppNeon.orange,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppNeon.cyan.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppNeon.cyan.withOpacity(0.25)),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoutFooter() {
    final l10n = AppLocalizations.of(context)!;
    final neonRed = AppNeon.red;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _logOut();
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: neonRed.withOpacity(0.18),
          child: Container(
            decoration: BoxDecoration(
              color: neonRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: neonRed.withOpacity(0.45), width: 1),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              minVerticalPadding: 0,
              leading: Icon(Icons.logout_rounded, size: 22, color: neonRed),
              title: Text(
                l10n.logout,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: neonRed,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                size: 20,
                color: neonRed.withOpacity(0.9),
              ),
              tileColor: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double _curveRadius = 250.0;
    final authState = Provider.of<AuthState>(context);
    final l10n = AppLocalizations.of(context)!;
    final isSignedIn = authState.userModel != null && authState.userId.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(_curveRadius),
      ),
      child: SizedBox(
        width: 280,
        child: Drawer(
          backgroundColor: Colors.transparent,
          child: SafeArea(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(_curveRadius),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: MockupDesign.background.withOpacity(0.90),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(_curveRadius),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _menuHeader(),
                      if (isSignedIn) _walletCard(authState),
                      if (isSignedIn)
                        Expanded(
                          child: ListView(
                            physics: BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            children: <Widget>[
                              _menuListRowButton(
                                l10n.drawerActivePredictions,
                                icon: Icons.play_arrow_rounded,
                                onPressed: () => _navigateTo('profile/${authState.userId}'),
                              ),
                              _menuListRowButton(
                                l10n.drawerWeeklyLeague,
                                icon: Icons.emoji_events_outlined,
                                onPressed: () => _navigateTo('LeaderboardPage'),
                              ),
                              _menuListRowButton(
                                l10n.drawerSettingsAndPrivacy,
                                icon: Icons.settings_outlined,
                                onPressed: () => _navigateTo('SettingsAndPrivacyPage'),
                              ),
                              _menuListRowButton(
                                l10n.profile,
                                icon: Icons.person_outline,
                                onPressed: () => _navigateTo('profile/${authState.userId}'),
                              ),
                              FutureBuilder<bool>(
                                // Force refresh: admin bayrağı sonradan verilse bile menü güncellensin.
                                future: authState.isAdminUser(forceRefresh: true),
                                builder: (context, snap) {
                                  final isAdmin = snap.data == true;
                                  if (!isAdmin) return const SizedBox.shrink();
                                  return _menuListRowButton(
                                    l10n.adminModeration,
                                    icon: Icons.admin_panel_settings_outlined,
                                    onPressed: () => _navigateTo('AdminModerationPage'),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      else
                        const Expanded(child: SizedBox.shrink()),
                      if (isSignedIn) _logoutFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // return Drawer(
    //   child: SafeArea(
    //     child: Stack(
    //       children: <Widget>[
    //         Padding(
    //           padding: EdgeInsets.only(bottom: 45),
    //           child: ListView(
    //             physics: BouncingScrollPhysics(),
    //             children: <Widget>[
    //               Container(
    //                 child: _menuHeader(),
    //               ),
    //               Divider(),
    //               _menuListRowButton('Profile',
    //                   icon: AppIcon.profile, isEnable: true, onPressed: () {
    //                 _navigateTo('ProfilePage');
    //               }),
    //               // state.userModel.role == AppIcon.adminRole
    //               //     ? _menuListRowButton('Lists',
    //               //         icon: AppIcon.lists, isEnable: true, onPressed: () {
    //               //         _navigateTo('FeedPage');
    //               //       })
    //               //     : _menuListRowButton('Lists',
    //               //         icon: AppIcon.lists,),
    //               // _menuListRowButton('Bookmark', icon: AppIcon.bookmark),
    //               // _menuListRowButton('Momentss', icon: AppIcon.moments),
    //               // _menuListRowButton('Fwitter ads', icon: AppIcon.twitterAds),
    //               Divider(),
    //               _menuListRowButton('Settings and privacy', isEnable: true,
    //                   onPressed: () {
    //                 _navigateTo('SettingsAndPrivacyPage');
    //               }),
    //               _menuListRowButton('Help Center'),
    //               Divider(),
    //               _menuListRowButton('Logout',
    //                   icon: null, onPressed: _logOut, isEnable: true),
    //             ],
    //           ),
    //         ),
    //         // _footer()
    //       ],
    //     ),
    //   ),
    // );
  }
}
