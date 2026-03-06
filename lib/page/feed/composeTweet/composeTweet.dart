import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:toldya/page/feed/composeTweet/widget/composeTweetImage.dart';
import 'package:toldya/page/feed/composeTweet/widget/widgetView.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/state/searchState.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/customUrlText.dart';
import 'package:toldya/widgets/newWidget/title_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ComposeToldyaPage extends StatefulWidget {
  ComposeToldyaPage({Key? key, bool? isRetoldya, bool? isToldya = true})
      : isRetoldya = isRetoldya ?? false,
        isToldya = isToldya ?? true,
        super(key: key);

  final bool isRetoldya;
  final bool isToldya;

  _ComposeToldyaReplyPageState createState() => _ComposeToldyaReplyPageState();
}

class _ComposeToldyaReplyPageState extends State<ComposeToldyaPage> {
  bool isScrollingDown = false;
  late FeedModel model;
  late ScrollController scrollcontroller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  File? _image;
  late TextEditingController _textEditingController;
  /// Meydan okuma: seçilen tek kullanıcı (1v1)
  UserModel? _challengeeUser;

  @override
  void dispose() {
    scrollcontroller.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var feedState = Provider.of<FeedState>(context, listen: false);
    model = feedState.toldyaToReplyModel ?? FeedModel();
    scrollcontroller = ScrollController();
    _textEditingController = TextEditingController();
    scrollcontroller..addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (scrollcontroller.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!isScrollingDown) {
        Provider.of<ComposeToldyaState>(context, listen: false)
            .setIsScrolllingDown = true;
      }
    }
    if (scrollcontroller.position.userScrollDirection ==
        ScrollDirection.forward) {
      Provider.of<ComposeToldyaState>(context, listen: false)
          .setIsScrolllingDown = false;
    }
  }

  void _onCrossIconPressed() {
    setState(() {
      _image = null;
    });
  }

  void _onImageIconSelcted(File file) {
    setState(() {
      _image = file;
    });
  }

  /// Submit tweet to save in firebase database
  void _submitButton() async {
    if (_textEditingController.text == null ||
        _textEditingController.text.isEmpty ||
        _textEditingController.text.length > 280) {
      return;
    }
    var state = Provider.of<FeedState>(context, listen: false);
    kScreenloader.showLoader(context);

    try {
      FeedModel toldyaModel = createToldyaModel();

      if (_image != null) {
        final imagePath = await state.uploadFile(_image!);
        if (imagePath != null) toldyaModel.imagePath = imagePath;
      }

      if (widget.isToldya) {
        await state.createToldya(toldyaModel);
      } else if (widget.isRetoldya) {
        await state.createReToldya(toldyaModel);
      } else {
        await state.addcommentToPost(toldyaModel);
      }

      await Provider.of<ComposeToldyaState>(context, listen: false)
          .sendNotification(
              toldyaModel, Provider.of<SearchState>(context, listen: false));

      if (!mounted) return;
      kScreenloader.hideLoader();
      final l10n = AppLocalizations.of(context)!;
      if (widget.isToldya) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.postUnderReview),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else if (widget.isRetoldya) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.shared)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commentAdded)),
        );
      }
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        kScreenloader.hideLoader();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorTryAgain),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Return Tweet model which is either a new Tweet , retweet model or comment model
  /// If tweet is new tweet then `parentkey` and `childRetwetkey` should be null
  /// IF tweet is a comment then it should have `parentkey`
  /// IF tweet is a retweet then it should have `childRetwetkey`
  FeedModel createToldyaModel() {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    final userModel = authState.userModel!;
    userModel.rank = (userModel.rank ?? 0) + 2;
    authState.createUser(userModel);
    var myUser = userModel;
    var profilePic = myUser.profilePic ?? dummyProfilePic;
    var commentedUser = UserModel(
        displayName: myUser.displayName ?? (myUser.email ?? '').split('@')[0],
        profilePic: profilePic,
        userId: myUser.userId,
        isVerified: authState.userModel?.isVerified ?? false,
        userName: authState.userModel?.userName ?? '');
    var tags = getHashTags(_textEditingController.text);
    FeedModel reply = FeedModel(
        statu: (widget.isToldya || (state.toldyaToReplyModel != null && !widget.isRetoldya))
            ? Statu.statusPendingAiReview
            : Statu.statusLive,
        topic: widget.isToldya ? null : state.toldyaToReplyModel?.topic,
        description: _textEditingController.text,
        user: commentedUser,
        createdAt: DateTime.now().toUtc().toString(),
        endDate: null,
        resolutionDate: null,
        oracleSource: null,
        oracleApiUrl: null,
        collateralAmount: null,
        tags: tags,
        parentkey: widget.isToldya
            ? null
            : widget.isRetoldya
                ? null
                : state.toldyaToReplyModel?.key,
        childRetoldyaKey: widget.isToldya
            ? null
            : widget.isRetoldya
                ? model.key
                : null,
        userId: myUser.userId);
    if (widget.isToldya && _challengeeUser?.userId != null) {
      reply.challengeeUserId = _challengeeUser!.userId;
    }
    return reply;
  }

  Widget _buildChallengeeRow() {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.challengeLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          if (_challengeeUser != null) ...[
            Text(
              '@${_challengeeUser!.userName ?? ''}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _challengeeUser = null),
              child: Icon(Icons.close, size: 18, color: theme.colorScheme.onSurface),
            ),
          ] else
            TextButton.icon(
              onPressed: _openChallengeePicker,
              icon: Icon(Icons.person_add, size: 18),
              label: Text(AppLocalizations.of(context)!.selectUser),
            ),
        ],
      ),
    );
  }

  void _openChallengeePicker() {
    final searchState = Provider.of<SearchState>(context, listen: false);
    final authState = Provider.of<AuthState>(context, listen: false);
    final myId = authState.userId;
    final followingIds = authState.profileUserModel?.followingList ?? [];
    if (searchState.userlist == null) {
      searchState.getDataFromDatabase();
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) => SafeArea(
        child: Consumer<SearchState>(
          builder: (ctx, searchState, _) {
            // Sadece takip edilenler: AuthState.followingList + getuserDetail
            final list = searchState
                .getuserDetail(followingIds)
                .where((u) => u.userId != null && u.userId != myId)
                .toList();
            final isLoading = searchState.isBusy && searchState.userlist == null;
            if (isLoading) {
              return Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    AppLocalizations.of(context)!.challengePickTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (list.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      followingIds.isEmpty
                          ? AppLocalizations.of(context)!.followingListEmpty
                          : AppLocalizations.of(context)!.followingListLoadingOrEmpty,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (ctx, i) {
                        final u = list[i];
                        return ListTile(
                          leading: customProfileImage(context, u.profilePic,
                              userId: u.userId, height: 40),
                          title: Text(u.displayName ?? ''),
                          subtitle: Text('@${u.userName ?? ''}'),
                          onTap: () {
                            setState(() => _challengeeUser = u);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: customTitleText(''),
        onActionPressed: _submitButton,
        isCrossButton: true,
        submitButtonText: widget.isToldya
            ? 'diyorum'
            : widget.isRetoldya
                ? 'Retweet'
                : 'Yorum Yap',
        isSubmitDisable:
            !Provider.of<ComposeToldyaState>(context).enableSubmitButton ||
                Provider.of<FeedState>(context).isBusy,
        isbootomLine: Provider.of<ComposeToldyaState>(context).isScrollingDown,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: scrollcontroller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isToldya) _buildChallengeeRow(),
                  widget.isRetoldya
                      ? _ComposeRetoldya(this)
                      : _ComposeToldya(this),
                ],
              ),
            ),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: ComposeBottomIconWidget(
            //     textEditingController: _textEditingController,
            //     onImageIconSelcted: _onImageIconSelcted,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _ComposeRetoldya
    extends WidgetView<ComposeToldyaPage, _ComposeToldyaReplyPageState> {
  _ComposeRetoldya(this.viewState) : super(viewState);

  final _ComposeToldyaReplyPageState viewState;

  Widget _tweet(BuildContext context, FeedModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // SizedBox(width: 10),

        SizedBox(width: 20),
        Container(
          width: fullWidth(context) - 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    width: 25,
                    height: 25,
                    child: customProfileImage(context, model.user?.profilePic, userId: model.user?.userId),
                  ),
                  SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: 0, maxWidth: fullWidth(context) * .5),
                    child: TitleText(model.user?.displayName ?? '',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: 3),
                  (model.user?.isVerified ?? false)
                      ? customIcon(
                          context,
                          icon: AppIcon.blueTick,
                          istwitterIcon: true,
                          iconColor: AppColor.primary,
                          size: 13,
                          paddingIcon: 3,
                        )
                      : SizedBox(width: 0),
                  SizedBox(width: (model.user?.isVerified ?? false) ? 5 : 0),
                  Flexible(
                    child: customText(
                      '${model.user?.userName ?? ''}',
                      style: userNameStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4),
                  customText('· ${getChatTime(model.createdAt ?? '')}',
                      style: userNameStyle),
                  Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ),
        UrlText(
          text: model.description ?? '',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          urlStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context);
    return Container(
      height: fullHeight(context),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child:
                    customImage(context, authState.user?.photoURL ?? '', height: 40),
              ),
              Expanded(
                child: _TextField(
                  isToldya: false,
                  isRetoldya: true,
                  textEditingController: viewState._textEditingController,
                ),
              ),
              SizedBox(
                width: 16,
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 16, left: 80, bottom: 8),
            child: ComposeToldyaImage(
              image: viewState._image,
              onCrossIconPressed: viewState._onCrossIconPressed,
            ),
          ),
          Flexible(
            child: Stack(
              children: <Widget>[
                Wrap(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 75, right: 16, bottom: 16),
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColor.extraLightGrey, width: .5),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: _tweet(context, viewState.model),
                    ),
                  ],
                ),
                _UserList(
                  list: Provider.of<SearchState>(context).userlist ?? [],
                  textEditingController: viewState._textEditingController,
                )
              ],
            ),
          ),
          SizedBox(height: 50)
        ],
      ),
    );
  }
}

class _ComposeToldya
    extends WidgetView<ComposeToldyaPage, _ComposeToldyaReplyPageState> {
  _ComposeToldya(this.viewState) : super(viewState);

  final _ComposeToldyaReplyPageState viewState;

  Widget _tweerCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 30),
              margin: EdgeInsets.only(left: 20, top: 20, bottom: 3),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 2.0,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: fullWidth(context) - 72,
                    child: UrlText(
                      text: viewState.model.description ?? '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      urlStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  UrlText(
                    text:
                        '${viewState.model.user?.userName ?? viewState.model.user?.displayName ?? ""} tahminine yanıt',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                customProfileImage(context, viewState.model.user?.profilePic,
                    userId: viewState.model.user?.userId, height: 40),
                SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: 0, maxWidth: fullWidth(context) * .5),
                  child: TitleText(viewState.model.user?.displayName ?? '',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: 3),
                (viewState.model.user?.isVerified ?? false)
                    ? customIcon(
                        context,
                        icon: AppIcon.blueTick,
                        istwitterIcon: true,
                        iconColor: AppColor.primary,
                        size: 13,
                        paddingIcon: 3,
                      )
                    : SizedBox(width: 0),
                SizedBox(width: (viewState.model.user?.isVerified ?? false) ? 5 : 0),
                customText('${viewState.model.user?.userName ?? ''}',
                    style: userNameStyle.copyWith(fontSize: 15)),
                SizedBox(width: 5),
                Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: customText(
                      '- ${getChatTime(viewState.model.createdAt ?? '')}',
                      style: userNameStyle.copyWith(fontSize: 12)),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context, listen: false);
    return Container(
      height: fullHeight(context),
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          viewState.widget.isToldya ? SizedBox.shrink() : _tweerCard(context),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              customImage(context, authState.user?.photoURL ?? '', height: 40),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: _TextField(
                  isToldya: widget.isToldya,
                  textEditingController: viewState._textEditingController,
                ),
              )
            ],
          ),
          Flexible(
            child: Stack(
              children: <Widget>[
                ComposeToldyaImage(
                  image: viewState._image,
                  onCrossIconPressed: viewState._onCrossIconPressed,
                ),
                _UserList(
                  list: Provider.of<SearchState>(context).userlist ?? [],
                  textEditingController: viewState._textEditingController,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField(
      {Key? key,
      required this.textEditingController,
      this.isToldya = false,
      this.isRetoldya = false})
      : super(key: key);
  final TextEditingController textEditingController;
  final bool isToldya;
  final bool isRetoldya;

  @override
  Widget build(BuildContext context) {
    final searchState = Provider.of<SearchState>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: textEditingController,
          onChanged: (text) {
            Provider.of<ComposeToldyaState>(context, listen: false)
                .onDescriptionChanged(text, searchState);
          },
          maxLines: null,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
          ),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: isToldya
                  ? 'Gelecek tahminlerini paylaş'
                  : isRetoldya
                      ? 'Add a comment'
                      : 'Bu tahmine yorum yap',
              hintStyle: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              )),
        ),
      ],
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList({Key? key, required this.list, required this.textEditingController})
      : super(key: key);
  final List<UserModel> list;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return !Provider.of<ComposeToldyaState>(context).displayUserList ||
            list.isEmpty
        ? SizedBox.shrink()
        : Container(
            padding: EdgeInsetsDirectional.only(bottom: 50),
            color: Theme.of(context).colorScheme.surface,
            constraints:
                BoxConstraints(minHeight: 30, maxHeight: double.infinity),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return _UserTile(
                  user: list[index],
                  onUserSelected: (user) {
                    textEditingController.text =
                        (Provider.of<ComposeToldyaState>(context, listen: false)
                                .getDescription(user.userName ?? '') ?? '') +
                            " ";
                    textEditingController.selection = TextSelection.collapsed(
                        offset: textEditingController.text.length);
                    Provider.of<ComposeToldyaState>(context, listen: false)
                        .onUserSelected();
                  },
                );
              },
            ),
          );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({Key? key, required this.user, required this.onUserSelected}) : super(key: key);
  final UserModel user;
  final ValueChanged<UserModel> onUserSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onUserSelected(user);
      },
      leading: customProfileImage(context, user.profilePic, userId: user.userId, height: 35),
      title: Row(
        children: <Widget>[
          ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: 0, maxWidth: fullWidth(context) * .5),
            child: TitleText(user.displayName ?? '',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 3),
          (user.isVerified ?? false)
              ? customIcon(
                  context,
                  icon: AppIcon.blueTick,
                  istwitterIcon: true,
                  iconColor: AppColor.primary,
                  size: 13,
                  paddingIcon: 3,
                )
              : SizedBox(width: 0),
        ],
      ),
      subtitle: Text(user.userName ?? ''),
    );
  }
}
