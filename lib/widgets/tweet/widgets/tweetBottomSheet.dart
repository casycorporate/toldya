import 'package:toldya/model/user.dart';
import 'package:toldya/model/userPegModel.dart';
import 'package:toldya/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:toldya/state/searchState.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/utility.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/widgets/customWidgets.dart';
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
    bool isMyToldya = authState.userId == model.userId;
    bool isAdmin = authState.userModel?.role == Role.adminRole;
    bool isReported = model.reportList?.contains(authState.userId) ?? false;
    bool isInBlackList = authState.userModel?.blackList?.contains(model.userId ?? '') ?? false;
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
            padding: EdgeInsets.only(bottom: 0),
            height: fullHeight(context) *
                (type == ToldyaType.Toldya
                    ? (isMyToldya ? .50 : .44)
                    : (isMyToldya ? .38 : .52)),
            width: fullWidth(context),
            decoration: BoxDecoration(
              color: Color(0xFF1A1F2E).withOpacity(0.95),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: type == ToldyaType.Toldya
                ? _tweetOptions(context,
                isAdmin: isAdmin,
                scaffoldKey: scaffoldKey,
                isMyToldya: isMyToldya,
                model: model,
                isReported: isReported,
                isInBlackList: isInBlackList,
                type: type)
                : _tweetDetailOptions(context,
                scaffoldKey: scaffoldKey,
                isMyToldya: isMyToldya,
                model: model,
                type: type));
      },
    );
  }

  Widget _tweetDetailOptions(BuildContext context,
      {required bool isMyToldya,
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
            text: AppLocalizations.of(context)!.copyLink, isEnable: true, onPressed: () async {
              var uri = await Utility.createLinkToCopy(
                context,
                "toldya/${model.key}",
                socialMetaTagParameters: SocialMetaTagParameters(
                    description: model.description ??
                        AppLocalizations.of(context)!.sharedPostDescription(model.user?.displayName ?? ''),
                    title: AppLocalizations.of(context)!.postTitle,
                    imageUrl: Uri.parse(
                        "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw")),
              );

              Navigator.pop(context);
              copyToClipBoard(
                  scaffoldKey: scaffoldKey,
                  text: uri.toString(),
                  message: AppLocalizations.of(context)!.copiedToClipboard);
            }),
        // isMyToldya
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
        isMyToldya
            ? _widgetBottomSheetRow(
          context,
          AppIcon.delete,
          text: AppLocalizations.of(context)!.delete,
          onPressed: () {
            _deleteToldya(
              context,
              type,
              model.key ?? '',
              parentkey: model.parentkey,
            );
          },
          isEnable: true,
          isDestructive: true,
        )
            : Container(),
        isMyToldya
            ? Container()
            : _widgetBottomSheetRow(
          context,
          AppIcon.mute,
          text: AppLocalizations.of(context)!.muteUser(model.user?.displayName ?? ''),
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.mute,
          text: AppLocalizations.of(context)!.muteConversation,
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.viewHidden,
          text: AppLocalizations.of(context)!.viewHiddenReplies,
        ),
        isMyToldya
            ? Container()
            : _widgetBottomSheetRow(
          context,
          AppIcon.block,
          text: AppLocalizations.of(context)!.blockUser(model.user?.displayName ?? ''),
        ),
        isMyToldya
            ? Container()
            : _widgetBottomSheetRow(
          context,
          AppIcon.report,
          text: AppLocalizations.of(context)!.report,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _tweetOptions(BuildContext context,
      {required bool isMyToldya,
        required bool isAdmin,
        required bool isReported,
        required bool isInBlackList,
        required FeedModel model,
        required ToldyaType type,
        required GlobalKey<ScaffoldState> scaffoldKey}) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 12, bottom: 8),
          height: 4,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        _widgetBottomSheetRow(context, AppIcon.link,
            text: AppLocalizations.of(context)!.copyLink, isEnable: true, onPressed: () async {
              var uri = await Utility.createLinkToCopy(
                context,
                "toldya/${model.key ?? ''}",
                socialMetaTagParameters: SocialMetaTagParameters(
                    description: model.description ??
                        AppLocalizations.of(context)!.sharedPostDescription(model.user?.displayName ?? ''),
                    title: AppLocalizations.of(context)!.postTitle,
                    imageUrl: Uri.parse(
                        "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw")),
              );
              Navigator.pop(context);
              copyToClipBoard(
                  scaffoldKey: scaffoldKey,
                  text: uri.toString(),
                  message: AppLocalizations.of(context)!.copiedToClipboard);
            }),
        isAdmin
            ? _widgetBottomSheetRow(context, AppIcon.thumbpinFill,
            text: AppLocalizations.of(context)!.sendForApproval, isEnable: true, onPressed: () {
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
        // isMyToldya
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
        isMyToldya
            ? _widgetBottomSheetRow(
          context,
          AppIcon.delete,
          text: AppLocalizations.of(context)!.delete,
          onPressed: () {
            _deleteToldya(
              context,
              type,
              model.key ?? '',
              parentkey: model.parentkey,
            );
          },
          isEnable: true,
          isDestructive: true,
        )
            : Container(),
        // isMyToldya
        //     ? Container()
        //     : _widgetBottomSheetRow(
        //         context,
        //         AppIcon.unFollow,
        //         text: '${model.user.displayName} Takibi bırak',
        //       ),
        // isMyToldya
        //     ? Container()
        //     : _widgetBottomSheetRow(
        //         context,
        //         AppIcon.mute,
        //         text: '${model.user.displayName} sessize al',
        //       ),
        isMyToldya
            ? Container()
            : _widgetBottomSheetRow(context, AppIcon.block,
            text: isInBlackList
                ? AppLocalizations.of(context)!.unblockUser(model.user?.displayName ?? '')
                : AppLocalizations.of(context)!.blockUser(model.user?.displayName ?? ''),
            isEnable: true, onPressed: () {
              _addBlackList(
                context,
                type,
                model.userId ?? '',
                parentkey: model.parentkey,
              );
            }),
        isMyToldya
            ? Container()
            : _widgetBottomSheetRow(context, AppIcon.report,
            text: isReported ? AppLocalizations.of(context)!.withdrawReport : AppLocalizations.of(context)!.report,
            onPressed: () {
              _addReportList(context, model, Statu.statusPending,
                  ConfirmWinner.None, scaffoldKey);
            }, isEnable: true),
        _shouldShowDispute(model, isMyToldya, isAdmin)
            ? _widgetBottomSheetRow(context, Icons.gavel_rounded,
            text: _hasDisputed(model, Provider.of<AuthState>(context, listen: false).userId) ? AppLocalizations.of(context)!.disputed : AppLocalizations.of(context)!.dispute,
            onPressed: _hasDisputed(model, Provider.of<AuthState>(context, listen: false).userId) ? null : () {
              _addDispute(context, model, scaffoldKey);
            }, isEnable: !_hasDisputed(model, Provider.of<AuthState>(context, listen: false).userId))
            : Container(),
        isAdmin
            ? _widgetBottomSheetRow(context, Icons.check_box, text: AppLocalizations.of(context)!.approve,
            onPressed: () {
              showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    ConfirmWinner selectedRadio = ConfirmWinner.Like;
                    return AlertDialog(
                      actions: [
                        TextButton(
                          child: Text(AppLocalizations.of(context)!.cancel),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(AppLocalizations.of(context)!.confirm),
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
          text: AppLocalizations.of(context)!.reject,
        )
            : Container(),
        SizedBox(height: 20),
      ],
    );
  }

  Widget continueButton(BuildContext context) => TextButton(
    child: Text(AppLocalizations.of(context)!.continueAction),
    onPressed: () {},
  );

  Widget _widgetBottomSheetRow(BuildContext context, IconData icon,
      {String text = '', Function? onPressed, bool isEnable = false, bool isDestructive = false}) {
    final bool hasAction = onPressed != null;
    final Color iconColor = isDestructive
        ? Colors.redAccent
        : (hasAction ? Colors.white : Colors.white70);
    final Color textColor = isDestructive
        ? Colors.redAccent
        : (isEnable ? Colors.white : Colors.white70);
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
                iconColor: iconColor,
              ),
              SizedBox(
                width: 15,
              ),
              customText(
                text,
                context: context,
                style: TextStyle(
                  color: textColor,
                  fontSize: isDestructive ? 16 : 18,
                  fontWeight: isDestructive ? FontWeight.w500 : FontWeight.w400,
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

  bool _shouldShowDispute(FeedModel model, bool isMyToldya, bool isAdmin) {
    if (isMyToldya || isAdmin) return false;
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
    customSnackBar(scaffoldKey, AppLocalizations.of(context)!.disputeRecorded);
    Navigator.of(context).pop();
  }

  int calculateRank(List<UserPegModel> list, int userPeg) {
    return ((userPeg / sumOfVote(list)) * 100).round() + 3;
  }

  void _deleteToldya(BuildContext context, ToldyaType type, String toldyaId,
      {String? parentkey}) async {
    var state = Provider.of<FeedState>(context, listen: false);
    Navigator.of(context).pop();
    try {
      await state.deleteToldya(toldyaId, type, parentkey: parentkey);
      if (type == ToldyaType.Detail && context.mounted) {
        Navigator.of(context).pop();
        state.removeLastToldyaDetail(toldyaId);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.predictionDeleted)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorDeleteFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addBlackList(BuildContext context, ToldyaType type, String userId,
      {String? parentkey}) {
    var authState = Provider.of<AuthState>(context, listen: false);
    try {
      authState.addBlackList(userId);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.userBlocked)),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorGeneric),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).padding.bottom + 20),
            constraints: BoxConstraints(maxHeight: fullHeight(context) * 0.6),
            width: fullWidth(context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: _retweet(context, model, type, commentFlag));
      },
    );
  }

  Widget _retweet(BuildContext context, FeedModel model, ToldyaType type,
      int commentFlag) {
    final totalLike = sumOfVote(model.likeList ?? []);
    final totalUnlike = sumOfVote(model.unlikeList ?? []);
    final total = totalLike + totalUnlike;
    final evetPercent = total > 0 ? (totalLike * 100 / total).round() : 50;
    final hayirPercent = total > 0 ? (totalUnlike * 100 / total).round() : 50;
    final isEvet = commentFlag == 0;
    const evetGreen = Color(0xFFE8F5E9);
    const hayirGray = Color(0xFFF5F5F5);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          Text(
            model.description ?? AppLocalizations.of(context)!.prediction,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isEvet ? evetGreen : hayirGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEvet ? Color(0xFF4CAF50) : Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.yes, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                      Text('$evetPercent%', style: TextStyle(fontSize: 14, color: isEvet ? Color(0xFF2E7D32) : Color(0xFF757575))),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: !isEvet ? Color(0xFFFFEBEE) : hayirGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: !isEvet ? Color(0xFFE53935) : Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.no, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                      Text('$hayirPercent%', style: TextStyle(fontSize: 14, color: !isEvet ? Color(0xFFC62828) : Color(0xFF757575))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          SliderInNavigationBar(model: model, commentFlag: commentFlag),
        ],
      ),
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
  bool isPressed = false;
  bool _isPlacingBet = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context, listen: false);
    var state = Provider.of<FeedState>(context, listen: false);

    void _send() async {
      debugPrint('=== BEN DEDIM BUTONUNA BASILDI ===');
      debugPrint('_period: $_period');
      debugPrint('maxVal: $maxVal');
      debugPrint('commentFlag: ${widget.commentFlag}');
      debugPrint('userId: ${authState.userId}');
      debugPrint('model.key: ${widget.model.key}');
      
      // Miktar kontrolü
      if (_period <= 0) {
        debugPrint('[HATA] Bahis miktarı 0 veya negatif!');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.pleaseSelectBetAmount),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      if (_period > maxVal) {
        debugPrint('[HATA] Bahis miktarı maksimumdan fazla! $_period > $maxVal');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.maxBetTokens('$maxVal')),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Bir tahminde yalnızca tek tarafa (Evet veya Hayır) bahis yapılabilir
      final userId = authState.userId;
      if (userAlreadyBetOnOtherSide(widget.model, userId, widget.commentFlag)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.betOnOneSideOnly,
              ),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.orange.shade800,
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      setState(() => _isPlacingBet = true);

      try {
        debugPrint('[BAHIS] placeBet çağrılıyor...');
        await state.placeBet(
          authState,
          widget.model,
          authState.userId ?? '',
          _period,
          widget.commentFlag,
        );
        debugPrint('[BAHIS] placeBet başarılı!');

        state.setToldyaToReply = widget.model;
        debugPrint('[BAHIS] Bildirim gönderiliyor...');
        authState.getuserDetail(widget.model.userId ?? '').then((user) {
          final ownUser = authState.userModel;
          if (user != null && ownUser != null && context.mounted) {
            Provider.of<ComposeToldyaState>(context, listen: false)
                .sendNotificationToFeed(
                    widget.model, user, ownUser, widget.commentFlag, _period)
                .then((_) {
                  debugPrint('[BAHIS] Bildirim gönderildi');
                });
          }
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.betPlaced)),
          );
          Navigator.pop(context);
        }
      } on PlatformException catch (e) {
        // Native Android hataları PlatformException olarak gelir
        debugPrint('[BAHIS HATASI] PlatformException');
        debugPrint('[BAHIS HATASI] code: ${e.code}');
        debugPrint('[BAHIS HATASI] message: ${e.message}');
        debugPrint('[BAHIS HATASI] details: ${e.details}');
        debugPrint('[BAHIS HATASI] stacktrace: ${e.stacktrace}');
        if (context.mounted) {
          setState(() => _isPlacingBet = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.gmsError(e.message ?? e.code ?? AppLocalizations.of(context)!.unknownError)),
              duration: Duration(seconds: 6),
              backgroundColor: Colors.red,
            ),
          );
        }
      } on FirebaseFunctionsException catch (e) {
        // Konsol + Logcat'te görünmesi için (Android Studio Run/Debug sekmesi)
        debugPrint('[BAHIS HATASI] FirebaseFunctionsException');
        debugPrint('[BAHIS HATASI] code: ${e.code}');
        debugPrint('[BAHIS HATASI] message: ${e.message}');
        debugPrint('[BAHIS HATASI] details: ${e.details}');
        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          String errorMessage = l10n.betErrorGeneric;
          if (e.code == 'internal' || e.code == 'INTERNAL') {
            errorMessage = l10n.gmsUpdateMessage;
          } else if (e.code == 'unauthenticated') {
            errorMessage = l10n.loginRequired;
          } else if (e.code == 'deadline-exceeded') {
            errorMessage = l10n.betTimeout;
          } else if (e.message != null && e.message!.isNotEmpty) {
            errorMessage = e.message!;
          } else if (e.code.isNotEmpty) {
            errorMessage = l10n.errorWithMessage(e.code);
          }
          setState(() => _isPlacingBet = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: Duration(seconds: 6),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e, stackTrace) {
        debugPrint('[BAHIS HATASI] Genel Exception');
        debugPrint('[BAHIS HATASI] Type: ${e.runtimeType}');
        debugPrint('[BAHIS HATASI] Message: $e');
        debugPrint('[BAHIS HATASI] Stack trace: $stackTrace');
        if (context.mounted) {
          setState(() => _isPlacingBet = false);
          final msg = e.toString().length > 120
              ? '${e.toString().substring(0, 120)}...'
              : e.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.errorWithMessage(msg)),
              duration: Duration(seconds: 6),
              backgroundColor: Colors.red,
            ),
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

    const presetAmounts = [10, 25, 50, 100];
    final validPresets = presetAmounts.where((a) => a <= maxVal).toList();
    const greenPrimary = Color(0xFF4CAF50);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Bahis miktarı',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE0E0E0)),
          ),
          child: Text(
            '$_period token',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: validPresets.map((amount) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _period = (_period + amount).clamp(0, maxVal)),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFFE0E0E0)),
                  ),
                  child: Text(
                    '+$amount',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 24),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isPlacingBet
                ? null
                : () {
                    if (_period <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectBetAmount), duration: Duration(seconds: 2)),
                      );
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text(AppLocalizations.of(context)!.confirmBet, style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 18)),
                        content: Text(
                          AppLocalizations.of(context)!.confirmBetMessage('$_period'),
                          style: TextStyle(color: Color(0xFF616161)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Color(0xFF757575))),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _send();
                            },
                            child: Text(AppLocalizations.of(context)!.confirm, style: TextStyle(color: greenPrimary, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    );
                  },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _isPlacingBet ? Colors.grey : greenPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isPlacingBet
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Bahsi Onayla',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
