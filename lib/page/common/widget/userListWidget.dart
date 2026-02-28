import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/rippleButton.dart';
import 'package:bendemistim/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class UserListWidget extends StatelessWidget {
  final List<UserModel> list;
  final String emptyScreenText;
  final String emptyScreenSubTileText;
  UserListWidget({
    Key? key,
    required this.list,
    this.emptyScreenText = '',
    this.emptyScreenSubTileText = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context, listen: false);
    String myId = state.userModel?.key ?? '';
    return ListView.separated(
      itemBuilder: (context, index) {
        return UserTile(
          user: list[index],
          myId: myId,
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 0,
        );
      },
      itemCount: list.length,
    );
    // : LinearProgressIndicator();
  }
}

class UserTile extends StatelessWidget {
  const UserTile({Key? key, required this.user, required this.myId}) : super(key: key);
  final UserModel user;
  final String myId;

  /// Return empty string for default bio
  /// Max length of bio is 100
  String getBio(String? bio) {
    if (bio != null && bio.isNotEmpty && bio != "Edit profile to update bio") {
      if (bio.length > 100) {
        return bio.substring(0, 100) + '...';
      }
      return bio;
    }
    return '';
  }

  /// Check if user followerlist contain your or not
  /// If your id exist in follower list it mean you are following him
  bool isFollowing() {
    if (user.followersList != null &&
        user.followersList!.any((x) => x == myId)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var authstate = Provider.of<AuthState>(context, listen: false);
    bool isFollow = isFollowing();
    isBlackList() {
      final bl = user.blackList;
      if (bl != null && bl.isNotEmpty) {
        return bl.any((x) => x == myId);
      }
      return false;
    }
    //
    // isFollower() {
    //   if (authstate.profileUserModel.followersList != null &&
    //       authstate.profileUserModel.followersList.isNotEmpty) {
    //     return (authstate.profileUserModel.followersList
    //         .any((x) => x == authstate.userModel.userId));
    //   } else {
    //     return false;
    //   }
    // }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: ToldyaColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/ProfilePage/' + (user.userId ?? ''));
            },
            leading: RippleButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/ProfilePage/' + (user.userId ?? ''));
              },
              borderRadius: BorderRadius.all(Radius.circular(60)),
              child: customProfileImage(context, user.profilePic, userId: user.userId, height: 55),
            ),
            title: Row(
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: 0, maxWidth: fullWidth(context) * .4),
                  child: TitleText(user.displayName ?? '',
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
            subtitle: Text(user.userName ?? ''),
            // trailing: RippleButton(
            //   onPressed: () {
            //     if (isBlackList()) {
            //       // authstate.addBlackList(authstate.profileUserModel.userId,removeBlackList: isBlackList());
            //     }else {
            //       authstate.followUser(
            //         removeFollower: isFollow,
            //       );
            //     }
            //   },
            //   splashColor: ToldyaColor.dodgetBlue_50.withAlpha(100),
            //   borderRadius: BorderRadius.circular(25),
            //   child: Container(
            //     padding: EdgeInsets.symmetric(
            //       horizontal: isFollow ? 15 : 20,
            //       vertical: 3,
            //     ),
            //     decoration: BoxDecoration(
            //       color:
            //           isFollow ? ToldyaColor.dodgetBlue : ToldyaColor.white,
            //       border: Border.all(color: ToldyaColor.dodgetBlue, width: 1),
            //       borderRadius: BorderRadius.circular(25),
            //     ),
            //     child: Text(
            //       isBlackList()
            //           ? 'engellendin'
            //           :isFollow ? 'Takip Ediliyor' : 'Takip Et',
            //       style: TextStyle(
            //         color: isFollow ? ToldyaColor.white : Colors.blue,
            //         fontSize: 17,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
          ),
          getBio(user.bio) == null
              ? SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.only(left: 90),
                  child: Text(
                    getBio(user.bio),
                  ),
                )
        ],
      ),
    );
  }
}
