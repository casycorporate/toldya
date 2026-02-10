import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/model/userPegModel.dart';
import 'package:bendemistim/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:bendemistim/state/searchState.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class ToldyaBottomSheet {
  Widget toldyaOptionIcon(BuildContext context,
      {required FeedModel model, required ToldyaType type, required GlobalKey<ScaffoldState> scaffoldKey}) {
    return customInkWell(
        radius: BorderRadius.circular(20),
        context: context,
        onPressed: () {
          _openbottomSheet(context,
              type: type, model: model, scaffoldKey: scaffoldKey);
        },
        child: Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: customIcon(context,
              icon: AppIcon.arrowDown,
              istwitterIcon: true,
              iconColor: AppColor.lightGrey),
        ));
  }

  void _openbottomSheet(BuildContext context,
      {required ToldyaType type,
        required FeedModel model,
        required GlobalKey<ScaffoldState> scaffoldKey}) async {
    var authState = Provider.of<AuthState>(context, listen: false);
    bool isMyTweet = authState.userId == model.userId;
    bool isAdmin = authState.userModel?.role == Role.adminRole;
    bool isReported = model.reportList?.contains(authState.userId) ?? false;
    bool isInBlackList = authState.userModel?.blackList?.contains(model.userId ?? '') ?? false;
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
            padding: EdgeInsets.only(top: 5, bottom: 0),
            height: fullHeight(context) *
                (type == ToldyaType.Toldya
                    ? (isMyTweet ? .50 : .44)
                    : (isMyTweet ? .38 : .52)),
            width: fullWidth(context),
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .bottomSheetTheme
                  .backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: type == ToldyaType.Toldya
                ? _tweetOptions(context,
                isAdmin: isAdmin,
                scaffoldKey: scaffoldKey,
                isMyTweet: isMyTweet,
                model: model,
                isReported: isReported,
                isInBlackList: isInBlackList,
                type: type)
                : _tweetDetailOptions(context,
                scaffoldKey: scaffoldKey,
                isMyTweet: isMyTweet,
                model: model,
                type: type));
      },
    );
  }

  Widget _tweetDetailOptions(BuildContext context,
      {required bool isMyTweet,
        required FeedModel model,
        required ToldyaType type,
        required GlobalKey<ScaffoldState> scaffoldKey}) {
    return Column(
      children: <Widget>[
        Container(
          width: fullWidth(context) * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(context, AppIcon.link,
            text: 'Bağlantıyı kopyala', isEnable: true, onPressed: () async {
              var uri = await Utility.createLinkToCopy(
                context,
                "tweet/${model.key}",
                socialMetaTagParameters: SocialMetaTagParameters(
                    description: model.description ??
                        "${model.user?.displayName ?? ''} bir gönderi paylaştı",
                    title: "Gönderi",
                    imageUrl: Uri.parse(
                        "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw")),
              );

              Navigator.pop(context);
              copyToClipBoard(
                  scaffoldKey: scaffoldKey,
                  text:
                  uri.toString(),
                  message: "Panoya kopyalandı");
            }),
        // isMyTweet
        //     ? _widgetBottomSheetRow(
        //         context,
        //         AppIcon.unFollow,
        //         text: 'Profile sabitle',
        //       )
        //     : _widgetBottomSheetRow(
        //         context,
        //         AppIcon.unFollow,
        //         text: '${model.user.displayName} Takibi bırak ',
        //       ),
        isMyTweet
            ? _widgetBottomSheetRow(
          context,
          AppIcon.delete,
          text: 'Sil',
          onPressed: () {
            _deleteToldya(
              context,
              type,
              model.key ?? '',
              parentkey: model.parentkey,
            );
          },
          isEnable: true,
        )
            : Container(),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(
          context,
          AppIcon.mute,
          text: '${model.user?.displayName ?? ''} sessize al',
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.mute,
          text: 'Bu görüşmeyi sessize al',
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.viewHidden,
          text: 'Gizli yanıtları görüntüle',
        ),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(
          context,
          AppIcon.block,
          text: '${model.user?.displayName ?? ''} engelle',
        ),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(
          context,
          AppIcon.report,
          text: 'Rapor et',
        ),
      ],
    );
  }

  Widget _tweetOptions(BuildContext context,
      {required bool isMyTweet,
        required bool isAdmin,
        required bool isReported,
        required bool isInBlackList,
        required FeedModel model,
        required ToldyaType type,
        required GlobalKey<ScaffoldState> scaffoldKey}) {
    return Column(
      children: <Widget>[
        Container(
          width: fullWidth(context) * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(context, AppIcon.link,
            text: 'Bağlantıyı kopyala', isEnable: true, onPressed: () async {
              var uri = await Utility.createLinkToCopy(
                context,
                "tweet/${model.key ?? ''}",
                socialMetaTagParameters: SocialMetaTagParameters(
                    description: model.description ??
                        "${model.user?.displayName ?? ''} bir gönderi paylaştı.",
                    title: "Gönderi",
                    imageUrl: Uri.parse(
                        "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw")),
              );
              Navigator.pop(context);
              copyToClipBoard(
                  scaffoldKey: scaffoldKey,
                  text:
                  uri.toString(),
                  message: "Panoya kopyalandı");
            }),
        isAdmin
            ? _widgetBottomSheetRow(context, AppIcon.thumbpinFill,
            text: 'onaya gönder', isEnable: true, onPressed: () {
              _sendApproval(context, model, Statu.statusPending,
                  ConfirmWinner.None, scaffoldKey);
            })
            : Container(),
        // _widgetBottomSheetRow(
        //         context,
        //         AppIcon.sadFace,
        //         text: 'Bununla ilgilenmiyorum',
        //         // text: 'Not interested in this',
        //       ),
        // isMyTweet
        //     ? _widgetBottomSheetRow(
        //         context,
        //         AppIcon.thumbpinFill,
        //         text: 'Profile sabitle',
        //       )
        //     : _widgetBottomSheetRow(
        //         context,
        //         AppIcon.sadFace,
        //         text: 'Bununla ilgilenmiyorum',
        //       ),
        isMyTweet
            ? _widgetBottomSheetRow(
          context,
          AppIcon.delete,
          text: 'Sil',
          onPressed: () {
            _deleteToldya(
              context,
              type,
              model.key ?? '',
              parentkey: model.parentkey,
            );
          },
          isEnable: true,
        )
            : Container(),
        // isMyTweet
        //     ? Container()
        //     : _widgetBottomSheetRow(
        //         context,
        //         AppIcon.unFollow,
        //         text: '${model.user.displayName} Takibi bırak',
        //       ),
        // isMyTweet
        //     ? Container()
        //     : _widgetBottomSheetRow(
        //         context,
        //         AppIcon.mute,
        //         text: '${model.user.displayName} sessize al',
        //       ),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(context, AppIcon.block,
            text: isInBlackList
                ? '${model.user?.displayName ?? ''} engeli kaldır'
                : '${model.user?.displayName ?? ''} engelle',
            isEnable: true, onPressed: () {
              _addBlackList(
                context,
                type,
                model.userId ?? '',
                parentkey: model.parentkey,
              );
            }),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(context, AppIcon.report,
            text: isReported ? 'şikayeti geri al' : 'Rapor et',
            onPressed: () {
              _addReportList(context, model, Statu.statusPending,
                  ConfirmWinner.None, scaffoldKey);
            }, isEnable: true),
        _shouldShowDispute(model, isMyTweet, isAdmin)
            ? _widgetBottomSheetRow(context, Icons.gavel_rounded,
            text: _hasDisputed(model, Provider.of<AuthState>(context, listen: false).userId) ? 'İtiraz ettiniz' : 'İtiraz et',
            onPressed: _hasDisputed(model, Provider.of<AuthState>(context, listen: false).userId) ? null : () {
              _addDispute(context, model, scaffoldKey);
            }, isEnable: !_hasDisputed(model, Provider.of<AuthState>(context, listen: false).userId))
            : Container(),
        isAdmin
            ? _widgetBottomSheetRow(context, Icons.check_box, text: 'onayla',
            onPressed: () {
              showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    ConfirmWinner selectedRadio = ConfirmWinner.Like;
                    return AlertDialog(
                      actions: [
                        TextButton(
                          child: Text("İptal"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text("Onayla"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _sendApproval(context, model, Statu.statusOk,
                                selectedRadio, scaffoldKey);
                          },
                        ),
                      ],
                      content: StatefulBuilder(
                        builder:
                            (BuildContext context, StateSetter setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List<Widget>.generate(
                                ConfirmWinner.values.length, (int index) {
                              return Row(
                                children: <Widget>[
                                  Radio<ConfirmWinner>(
                                    value: ConfirmWinner.values[index],
                                    groupValue: selectedRadio,
                                    onChanged: (ConfirmWinner? value) {
                                      if (value != null) setState(() => selectedRadio = value);
                                    },
                                  ),
                                  Text(ConfirmWinner.values[index]
                                      .toString()
                                      .split('.')
                                      .last),
                                ],
                              );
                            }),
                          );
                        },
                      ),
                    );
                  });
            }, isEnable: true)
            : Container(),
        isAdmin
            ? _widgetBottomSheetRow(
          context,
          Icons.dangerous,
          isEnable: true,
          onPressed: () {
            _sendApproval(context, model, Statu.statusDenied,
                ConfirmWinner.None, scaffoldKey);
          },
          text: 'reddet',
        )
            : Container(),
      ],
    );
  }

  Widget continueButton = TextButton(
    child: Text("Continue"),
    onPressed: () {},
  );

  Widget _widgetBottomSheetRow(BuildContext context, IconData icon,
      {String text = '', Function? onPressed, bool isEnable = false}) {
    return Expanded(
      child: customInkWell(
        context: context,
        onPressed: () {
          if (onPressed != null)
            onPressed();
          else {
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              customIcon(
                context,
                icon: icon,
                istwitterIcon: true,
                size: 25,
                paddingIcon: 8,
                iconColor:
                onPressed != null ? AppColor.darkGrey : AppColor.lightGrey,
              ),
              SizedBox(
                width: 15,
              ),
              customText(
                text,
                context: context,
                style: TextStyle(
                  color: isEnable ? AppColor.secondary : AppColor.lightGrey,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendApproval(BuildContext context, FeedModel model, int statu,
      ConfirmWinner selectedRadio, GlobalKey<ScaffoldState> scaffoldKey) async {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    model.feedResult = selectedRadio.index;
    model.statu = statu;
    if (statu == Statu.statusOk) {
      await state.distributeWinnings(model, authState);
      if (ConfirmWinner.Like == selectedRadio) {
        model.likeList?.forEach((element) {
          authState.getuserDetail(element.userId ?? '').then((user) {
            if (user != null) {
              user.rank = (user.rank ?? 0) + calculateRank(model.likeList ?? [], element.pegCount ?? 0);
              authState.createUser(user);
            }
          });
        });
      } else {
        model.unlikeList?.forEach((element) {
          authState.getuserDetail(element.userId ?? '').then((user) {
            if (user != null) {
              user.rank = (user.rank ?? 0) + calculateRank(model.unlikeList ?? [], element.pegCount ?? 0);
              authState.createUser(user);
            }
          });
        });
      }
    }
    state.updateToldya(model);
    if (context.mounted) Navigator.of(context).pop();

    customSnackBar(
        scaffoldKey,
        statu == Statu.statusPending
            ? 'Seçim yapılmak üzere bekleyen statude'
            : 'Gönderi için ' +
            selectedRadio
                .toString()
                .split('.')
                .last +
            ' seçildi ');

    // scaffoldKey.currentState.hideCurrentSnackBar();
    // scaffoldKey.currentState.showSnackBar(
    //     SnackBar(
    //       behavior: SnackBarBehavior.floating,
    //       backgroundColor: ToldyaColor.black,
    //       content: Text(
    //         statu==Statu.statusPending ? 'Seçim yapılmak üzere bekleyen statude' :'Gönderi için ' +selectedRadio.toString().split('.').last + ' seçildi ',
    //         style: TextStyle(color: Colors.white),
    //       ),
    //     ));
  }

  void _addReportList(BuildContext context, FeedModel model, int statu,
      ConfirmWinner selectedRadio, GlobalKey<ScaffoldState> scaffoldKey) {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.addReportToToldya(model, authState.userId ?? '');
    Navigator.of(context).pop();
  }

  bool _shouldShowDispute(FeedModel model, bool isMyTweet, bool isAdmin) {
    if (isMyTweet || isAdmin) return false;
    return model.statu == Statu.statusPending || model.statu == Statu.statusOk;
  }

  bool _hasDisputed(FeedModel model, String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return model.disputeUserIds?.contains(userId) ?? false;
  }

  void _addDispute(BuildContext context, FeedModel model,
      GlobalKey<ScaffoldState> scaffoldKey) {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    final userId = authState.userId ?? '';
    if (model.disputeUserIds?.contains(userId) == true) return;
    state.addDisputeToToldya(model, userId);
    customSnackBar(scaffoldKey, 'İtirazınız kaydedildi');
    Navigator.of(context).pop();
  }

  int calculateRank(List<UserPegModel> list, int userPeg) {
    return ((userPeg / sumOfVote(list)) * 100).round() + 3;
  }

  void _deleteToldya(BuildContext context, ToldyaType type, String toldyaId,
      {String? parentkey}) {
    var state = Provider.of<FeedState>(context, listen: false);
    state.deleteToldya(toldyaId, type, parentkey: parentkey);
    // CLose bottom sheet
    Navigator.of(context).pop();
    if (type == ToldyaType.Detail) {
      // Close Tweet detail page
      Navigator.of(context).pop();
      // Remove last tweet from tweet detail stack page
      state.removeLastTweetDetail(toldyaId);
    }
  }

  void _addBlackList(BuildContext context, ToldyaType type, String userId,
      {String? parentkey}) {
    var state = Provider.of<AuthState>(context, listen: false);
    state.addBlackList(userId);
    Navigator.of(context).pop();
  }

  void openRetoldyabottomSheet(int commentFlag, BuildContext context,
      {required ToldyaType type,
        required FeedModel model,
        required GlobalKey<ScaffoldState> scaffoldKey}) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
            padding: EdgeInsets.only(top: 5, bottom: 0),
            height: fullHeight(context) * 0.30,
            width: fullWidth(context),
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .bottomSheetTheme
                  .backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: _retweet(context, model, type, commentFlag));
      },
    );
  }

  Widget _retweet(BuildContext context, FeedModel model, ToldyaType type,
      int commentFlag) {
    return Column(
      children: <Widget>[
        Container(
          width: fullWidth(context) * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        customText("Kaç Kapak basıyorsunuz?"),
        SizedBox(
          height: 5,
        ),
        // _widgetBottomSheetRow(
        //   context,
        //   AppIcon.heartEmpty,
        //   isEnable: true,
        //   text: 'Kaç Kapak basıyorsunuz?',
        //   onPressed: () {
        //     // var state = Provider.of<FeedState>(context, listen: false);
        //     // var authState = Provider.of<AuthState>(context, listen: false);
        //     // var myUser = authState.userModel;
        //     // myUser = UserModel(
        //     //     displayName: myUser.displayName ?? myUser.email.split('@')[0],
        //     //     profilePic: myUser.profilePic,
        //     //     userId: myUser.userId,
        //     //     isVerified: authState.userModel.isVerified,
        //     //     userName: authState.userModel.userName);
        //     // // Prepare current Tweet model to reply
        //     // FeedModel post = new FeedModel(
        //     //     childRetwetkey: model.key,
        //     //     createdAt: DateTime.now().toUtc().toString(),
        //     //     user: myUser,
        //     //     userId: myUser.userId);
        //     // state.createReTweet(post);
        //     // Navigator.pop(context);
        //   },
        // ),
        SliderInNavigationBar(model: model, commentFlag: commentFlag),
      ],
    );
  }
}

class SliderInNavigationBar extends StatefulWidget {
  final FeedModel model;
  final int commentFlag;

  SliderInNavigationBar({Key? key, required this.model, this.commentFlag = 0})
      : super(key: key);

  @override
  _SliderInNavigationBarScreenState createState() =>
      new _SliderInNavigationBarScreenState();
}

class _SliderInNavigationBarScreenState extends State<SliderInNavigationBar> {
  int _currentIndex = 0;

  //List<Widget> _children;
  int _period = 0;
  int maxVal = 0;
  bool isPressed=false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context, listen: false);
    var state = Provider.of<FeedState>(context, listen: false);

    void _send() async {
      try {
        await state.placeBet(
          authState,
          widget.model,
          authState.userId ?? '',
          _period,
          widget.commentFlag,
        );
        state.setToldyaToReply = widget.model;
        authState.getuserDetail(widget.model.userId ?? '').then((user) {
          final ownUser = authState.userModel;
          if (user != null && ownUser != null && context.mounted) {
            Provider.of<ComposeTweetState>(context, listen: false)
                .sendNotificationToFeed(
                    widget.model, user, ownUser, widget.commentFlag, _period)
                .then((_) {});
          }
        });
        if (context.mounted) Navigator.pop(context);
      } on FirebaseFunctionsException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Bahis gönderilemedi.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bahis gönderilemedi.')),
          );
        }
      }
    }

    final balance = authState.userModel?.pegCount ?? 0;
    final xp = authState.userModel?.xp ?? 0;
    final totalPool = sumOfVote(widget.model.likeList ?? []) +
        sumOfVote(widget.model.unlikeList ?? []);
    maxVal = [
      balance,
      Tokenomics.maxBetByRank(balance, xp),
      Tokenomics.maxBetByPool(totalPool),
    ].reduce((a, b) => a < b ? a : b);
    return new Column(children: <Widget>[

      Container(
        padding: EdgeInsets.all(3),
        // decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(5),
        //     color: Theme.of(context).accentColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      if (_period > 0) {
                        _period--;
                      }
                    });
                  },
                  child: Icon(
                    Icons.remove,
                    color: Color(0xfff7892b),
                    size: 24,
                  )),
              onLongPressStart: (_) async {
                isPressed = true;
                do {
                  setState(() {
                    if (_period > 0) {
                      _period--;
                    }
                  });// for testing
                  await Future.delayed(Duration(milliseconds: 1));
                } while (isPressed);
              },
              onLongPressEnd: (_) => setState(() => isPressed = false),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 3),
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3), color: Colors.white),
              child: Text(
                '$_period',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            GestureDetector(
              child:
              InkWell(
                  onTap: () {
                    setState(() {
                      if (_period < maxVal) {
                        _period++;
                      }
                    });
                  },
                  child: Icon(
                    Icons.add,
                    color: Color(0xfff7892b),
                    size: 24,
                  )),
              onLongPressStart: (_) async {
                isPressed = true;
                do {
                  setState(() {
                    if (_period < maxVal) {
                      _period++;
                    }
                  });
                  await Future.delayed(Duration(milliseconds: 1));
                } while (isPressed);
              },
              onLongPressEnd: (_) => setState(() => isPressed = false),
            ),
          ],
        ),
      ),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: Color(0xfff7892b),
          inactiveTrackColor: Color(0xfffbb448),
          trackShape: RoundedRectSliderTrackShape(),
          trackHeight: 4.0,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
          thumbColor: Color(0xfffbb448),
          overlayColor: Color(0xfff7892b).withAlpha(32),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
          tickMarkShape: RoundSliderTickMarkShape(),
          activeTickMarkColor: Color(0xfff7892b),
          inactiveTickMarkColor: Color(0xfffbb448),
          valueIndicatorShape: PaddleSliderValueIndicatorShape(),
          valueIndicatorColor: Color(0xfffbb448),
          valueIndicatorTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        child: Slider(
            value: _period.toDouble(),
            min: 0.0,
            max: maxVal.toDouble(),
            divisions: maxVal,
            label: '$_period',
            onChanged: (double value) {
              setState(() {
                _period = value.round();
              });
            }),
      ),
      GestureDetector(
        onTap: () {
          _send();
        },
        child: Container(
          width: fullWidth(context) * 0.5,
          padding: EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xfffbb448), Color(0xfff7892b)])),
          child: Text(
            'ben dedim',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    ]);
  }
}
