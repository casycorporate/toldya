import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customUrlText.dart';
import 'package:provider/provider.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  static const double _headerPaddingH = 20.0;
  static const double _avatarSize = 56.0;
  static const double _avatarRingWidth = 1.5;

  Widget _menuHeader() {
    final state = Provider.of<AuthState>(context);
    if (state.userModel == null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed('/SignIn'),
          borderRadius: BorderRadius.circular(radiusMedium),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: _headerPaddingH),
            child: Center(
              child: Text(
                'Devam etmek için giriş yapın',
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
            onTap: () => _navigateTo('ProfilePage'),
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
                    child: Image(
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
                      SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: _tappbleText(
                              context,
                              '${state.userModel?.getFollower() ?? 0}',
                              ' Takipçiler',
                              'FollowerListPage',
                            ),
                          ),
                          SizedBox(width: 12),
                          Flexible(
                            child: _tappbleText(
                              context,
                              '${state.userModel?.getFollowing() ?? 0}',
                              ' Takipler',
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
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed != null ? () => onPressed() : null,
        borderRadius: BorderRadius.circular(radiusSmall),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _headerPaddingH, vertical: 14),
          child: Row(
            children: <Widget>[
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 22,
                  color: isEnable
                      ? Colors.grey.shade300
                      : Colors.grey.shade500,
                ),
                SizedBox(width: 16),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isEnable
                        ? Colors.white
                        : Colors.grey.shade500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey.shade600,
              ),
            ],
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
    Navigator.pop(context);
    state.logoutCallback();
  }

  void _navigateTo(String path) {
    Navigator.pop(context);
    Navigator.of(context).pushNamed('/$path');
  }

  @override
  Widget build(BuildContext context) {
    const double _curveRadius = 250.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: ClipRRect(
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
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(_curveRadius),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            left: 8,
                            top: 8,
                            right: _headerPaddingH,
                            bottom: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.grey.shade400,
                                  size: 24,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.06),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(radiusSmall),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 24),
                            children: <Widget>[
                              _menuHeader(),
                              Divider(
                                height: 24,
                                thickness: 0.5,
                                color: Colors.white.withOpacity(0.08),
                              ),
                              _menuListRowButton(
                                'Profil',
                                icon: Icons.person_outline,
                                isEnable: true,
                                onPressed: () => _navigateTo('ProfilePage'),
                              ),
                              _menuListRowButton(
                                'Ayarlar',
                                icon: Icons.settings_outlined,
                                isEnable: true,
                                onPressed: () => _navigateTo('SettingsAndPrivacyPage'),
                              ),
                              Divider(
                                height: 24,
                                thickness: 0.5,
                                color: Colors.white.withOpacity(0.08),
                              ),
                              _menuListRowButton(
                                'Çıkış',
                                icon: Icons.logout_rounded,
                                onPressed: _logOut,
                                isEnable: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
