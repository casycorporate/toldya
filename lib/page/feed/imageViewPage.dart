import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/tweet/widgets/tweetIconsRow.dart';
import 'package:provider/provider.dart';

class ImageViewPge extends StatefulWidget {
  _ImageViewPgeState createState() => _ImageViewPgeState();
}

class _ImageViewPgeState extends State<ImageViewPge> {
  bool isToolAvailable = true;

  late FocusNode _focusNode;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _textEditingController = TextEditingController();
  }

  Widget _body() {
    var state = Provider.of<FeedState>(context);
    final FeedModel? detailModel = state.toldyaDetailModel?.isNotEmpty == true
        ? state.toldyaDetailModel!.last
        : state.toldyaToReplyModel;
    final String imagePath = detailModel?.imagePath ?? '';

    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            constraints: BoxConstraints(
              maxHeight: fullHeight(context),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  isToolAvailable = !isToolAvailable;
                });
              },
              child: _imageFeed(imagePath),
            ),
          ),
        ),
        !isToolAvailable
            ? Container()
            : Align(
                alignment: Alignment.topLeft,
                child: SafeArea(
                  child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
                      ),
                      child: Wrap(
                        children: <Widget>[
                          BackButton(
                            color: Colors.white,
                          ),
                        ],
                      )),
                )),
        !isToolAvailable || detailModel == null
            ? Container()
            : Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      ToldyaIconsRow(
                        model: detailModel,
                        iconColor: Theme.of(context).colorScheme.onPrimary,
                        iconEnableColor:
                            Theme.of(context).colorScheme.onPrimary,
                        size: 20,
                        type: ToldyaType.Detail,
                        scaffoldKey: GlobalKey<ScaffoldState>(),
                      ),
                      Container(
                        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
                        padding:
                            EdgeInsets.only(right: 10, left: 10, bottom: 10),
                        child: TextField(
                          controller: _textEditingController,
                          maxLines: null,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            fillColor: Colors.blue,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                _submitButton();
                              },
                              icon: Icon(Icons.send, color: Colors.white),
                            ),
                            focusColor: Colors.black,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            hintText: AppLocalizations.of(context)!.commentHint,
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _imageFeed(String _image) {
    return _image == null
        ? Container()
        : Container(
            alignment: Alignment.center,
            child: Container(
                child: InteractiveViewer(
              child: customNetworkImage(
                _image,
                fit: BoxFit.fitWidth,
              ),
            )),
          );
  }

  void _submitButton() async {
    if (_textEditingController.text.isEmpty || _textEditingController.text.length > 280) {
      return;
    }
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    var user = authState.userModel;
    var name = authState.userModel?.displayName ??
        ((authState.userModel?.email ?? '').split('@').isNotEmpty
            ? (authState.userModel?.email ?? '').split('@')[0]
            : '');
    var pic = authState.userModel?.profilePic ?? dummyProfilePic;
    var tags = getHashTags(_textEditingController.text);

    UserModel commentedUser = UserModel(
        displayName: name,
        userName: authState.userModel?.userName ?? '',
        isVerified: authState.userModel?.isVerified ?? false,
        profilePic: pic,
        userId: authState.userId);

    var detailList = state.toldyaDetailModel;
    final FeedModel? currentDetail = detailList?.isNotEmpty == true
        ? detailList!.last
        : state.toldyaToReplyModel;
    var postId = currentDetail?.key;

    FeedModel reply = FeedModel(
      description: _textEditingController.text,
      user: commentedUser,
      createdAt: DateTime.now().toUtc().toString(),
      tags: tags,
      userId: commentedUser.userId,
      parentkey: postId,
    );
    try {
      await state.addcommentToPost(reply);
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
        setState(() => _textEditingController.text = '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.commentAdded)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.commentFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body());
  }
}
