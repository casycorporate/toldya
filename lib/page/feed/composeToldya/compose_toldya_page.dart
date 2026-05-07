import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/page/feed/composeToldya/state/compose_toldya_state.dart';
import 'package:toldya/page/feed/composeToldya/widget/compose_toldya_image.dart';
import 'package:toldya/page/feed/composeToldya/widget/widgetView.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:toldya/state/searchState.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/customUrlText.dart';
import 'package:toldya/widgets/newWidget/title_text.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

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
  bool _isEditMode = false;

  // Dark create-prediction spec
  static const Color _screenBg = Color(0xFF0F172A);
  static const Color _cardBg = Color(0xFF111827);
  static const Color _primary = Color(0xFF2563EB);
  static const Color _textColor = Color(0xFFE5E7EB);

  File? _image;
  late TextEditingController _textEditingController;
  DateTime? _selectedEndDate;
  int? _selectedEndPresetIndex;
  @override
  void dispose() {
    scrollcontroller.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final feedState = Provider.of<FeedState>(context, listen: false);
    final composeState = Provider.of<ComposeToldyaState>(context, listen: false);

    if (feedState.toldyaToEditModel != null) {
      model = feedState.toldyaToEditModel!;
      _isEditMode = true;
      final initial = model.description ?? '';
      _textEditingController = TextEditingController(text: initial);

      // Defer provider mutations until after first frame to avoid
      // "setState()/markNeedsBuild called during build" from notifyListeners().
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        feedState.clearToldyaToEdit();
        composeState.setInitialDescription(initial);
      });
    } else {
      model = feedState.toldyaRetoldyaSourceModel ?? FeedModel();
      _textEditingController = TextEditingController();
    }
    scrollcontroller = ScrollController();
    scrollcontroller..addListener(_scrollListener);

    // Default selected: 24s (24 hours) for create prediction.
    if (widget.isToldya) {
      if (!_isEditMode) {
        final nowUtc = DateTime.now().toUtc();
        _selectedEndPresetIndex = 1; // 24s
        _selectedEndDate = nowUtc.add(const Duration(days: 1));
      } else {
        final endDateIso = model.endDate;
        if (endDateIso != null) {
          final parsed = DateTime.tryParse(endDateIso);
          if (parsed != null) _selectedEndDate = parsed.toUtc();
        }
      }
    }
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

  void _onEndPresetSelected(int index) {
    HapticFeedback.selectionClick();
    final now = DateTime.now().toUtc();
    Duration delta;
    switch (index) {
      case 0:
        delta = Duration(hours: 1);
        break;
      case 1:
        delta = Duration(days: 1);
        break;
      case 2:
        delta = Duration(hours: 72);
        break;
      default:
        delta = Duration(hours: 1);
    }
    setState(() {
      _selectedEndPresetIndex = index;
      _selectedEndDate = now.add(delta);
    });
  }

  Future<void> _pickCustomEndDate(BuildContext context) async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final initialDate = (_selectedEndDate ?? now.add(Duration(hours: 1))).toLocal();
    final firstDate = now;
    final lastDate = now.add(Duration(days: 365 * 2));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (pickedTime == null) return;

    final local = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() {
      _selectedEndPresetIndex = null;
      _selectedEndDate = local.toUtc();
    });
  }

  Widget _buildEndDateSection(BuildContext context) {
    if (!widget.isToldya) return SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final chips = <Widget>[];

    final hourShort = l10n.pollHour.isNotEmpty ? l10n.pollHour[0] : 's';
    final labels = <String>['1$hourShort', '24$hourShort', '72$hourShort'];

    for (var i = 0; i < 3; i++) {
      final isSelected = _selectedEndPresetIndex == i;
      chips.add(Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: ChoiceChip(
          label: Text(
            labels[i],
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : _textColor.withOpacity(0.9),
            ),
          ),
          selected: isSelected,
          onSelected: (_) => _onEndPresetSelected(i),
          selectedColor: _primary,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected
                  ? _primary
                  : _textColor.withOpacity(0.15),
            ),
          ),
          pressElevation: 0,
          shadowColor: Colors.transparent,
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timelapse_rounded,
                  size: 18,
                  color: _primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.composeToldyaDateSectionTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _textColor.withOpacity(0.95),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(children: chips),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  side: BorderSide(
                    color: _primary.withOpacity(0.65),
                    width: 1.1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: Colors.transparent,
                ),
                onPressed: () => _pickCustomEndDate(context),
                icon: Icon(Icons.calendar_today_rounded, size: 18, color: _primary),
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    l10n.composeToldyaPickCustomDate,
                    style: const TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toldya gönderimini Realtime Database'e yazar.
  void _submitButton() async {
    if (_textEditingController.text.isEmpty ||
        _textEditingController.text.length > ComposeToldyaState.kToldyaMaxLength) {
      return;
    }
    if (widget.isToldya && _selectedEndDate == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminModerationInvalidForm)),
      );
      return;
    }
    var state = Provider.of<FeedState>(context, listen: false);
    kScreenloader.showLoader(context);

    try {
      if (_isEditMode) {
        model.description = _textEditingController.text;
        await state.updateToldya(model);
        if (!mounted) return;
        kScreenloader.hideLoader();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.predictionUpdated)),
        );
        if (Navigator.canPop(context)) Navigator.of(context).pop();
        return;
      }

      FeedModel toldyaModel = createToldyaModel();

      if (!widget.isToldya && _image != null) {
        final imagePath = await state.uploadFile(_image!);
        if (imagePath != null) toldyaModel.imagePath = imagePath;
      }

      if (widget.isToldya) {
        await state.createToldya(toldyaModel);
      } else if (widget.isRetoldya) {
        await state.createReToldya(toldyaModel);
      } else {
        // Yorum oluşturma desteği kaldırıldı; bu durumda herhangi bir veri yazmıyoruz.
        kScreenloader.hideLoader();
        return;
      }
      debugPrint("[FeedDebug] Compose: post published, toldyaKey=${toldyaModel.key ?? 'unknown'}");

      if (!widget.isToldya) {
        await Provider.of<ComposeToldyaState>(context, listen: false)
            .sendNotification(
                toldyaModel, Provider.of<SearchState>(context, listen: false));
      }

      if (!mounted) return;
      kScreenloader.hideLoader();
      final l10n = AppLocalizations.of(context)!;
      if (widget.isToldya) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.composeToldyaReviewPending),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else if (widget.isRetoldya) {
        state.clearToldyaRetoldyaSource();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.shared)),
        );
      }
      if (Navigator.canPop(context)) Navigator.pop(context);
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

  /// Yeni toldya veya retoldya için [FeedModel] üretir.
  /// Ana tahmin: `parentkey` ve `childRetoldyaKey` null.
  /// Retoldya: `childRetoldyaKey` kaynak tahmin key'i.
  FeedModel createToldyaModel() {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    final userModel = authState.userModel!;
    if (!widget.isToldya) {
      userModel.rank = (userModel.rank ?? 0) + 2;
    }
    authState.createUser(userModel);
    var myUser = userModel;
    final ownerId = (myUser.userId ?? authState.userId).trim();
    if (ownerId.isEmpty) {
      throw StateError('Cannot create toldya without ownerId');
    }
    myUser.userId = ownerId;
    var profilePic = myUser.profilePic ?? dummyProfilePic;
    var commentedUser = UserModel(
        displayName: myUser.displayName ?? (myUser.email ?? '').split('@')[0],
        profilePic: profilePic,
        userId: ownerId,
        isVerified: authState.userModel?.isVerified ?? false,
        userName: authState.userModel?.userName ?? '');
    var tags = getHashTags(_textEditingController.text);
    final nowUtc = DateTime.now().toUtc();
    final endDateIso = widget.isToldya && _selectedEndDate != null
        ? _selectedEndDate!.toIso8601String()
        : null;
    FeedModel reply = FeedModel(
        statu: widget.isToldya ? Statu.statusPendingAdminReview : Statu.statusLive,
        topic: widget.isToldya ? null : state.toldyaRetoldyaSourceModel?.topic,
        description: _textEditingController.text,
        user: commentedUser,
        createdAt: nowUtc.toIso8601String(),
        endDate: endDateIso,
        collateralAmount: null,
        tags: tags,
        parentkey: null,
        childRetoldyaKey: widget.isToldya
            ? null
            : widget.isRetoldya
                ? model.key
                : null,
        userId: ownerId);
    reply.normalizeOwnershipForWrite();
    return reply;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: customTitleText(''),
        onActionPressed: widget.isToldya ? null : _submitButton,
        isCrossButton: true,
        submitButtonText: widget.isToldya
            ? null
            : widget.isRetoldya
                ? AppLocalizations.of(context)!.retoldyaSubmitButton
                : null,
        isSubmitDisable:
            !Provider.of<ComposeToldyaState>(context).enableSubmitButton ||
                Provider.of<FeedState>(context).isBusy,
        isbootomLine: Provider.of<ComposeToldyaState>(context).isScrollingDown,
      ),
      backgroundColor: _screenBg,
      bottomNavigationBar: widget.isToldya ? _buildStickyShareButton(context) : null,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                controller: scrollcontroller,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom +
                        (widget.isToldya ? 96 : 0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.isRetoldya
                          ? _ComposeRetoldya(this)
                          : _ComposeToldya(this),
                    ],
                  ),
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
      ),
    );
  }

  Widget _buildStickyShareButton(BuildContext context) {
    final feedState = Provider.of<FeedState>(context, listen: false);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Consumer<ComposeToldyaState>(
          builder: (context, composeState, _) {
            final l10n = AppLocalizations.of(context)!;
            final hasText = composeState.description.isNotEmpty;
            final hasClosing = _selectedEndDate != null;
            final isTextReady = composeState.enableSubmitButton;
            final isDisabled =
                !hasText || !isTextReady || !hasClosing || feedState.isBusy;

            return SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isDisabled
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        _submitButton();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDisabled ? _primary.withOpacity(0.25) : _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.composeToldyaShare,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ComposeRetoldya
    extends WidgetView<ComposeToldyaPage, _ComposeToldyaReplyPageState> {
  _ComposeRetoldya(this.viewState) : super(viewState);

  final _ComposeToldyaReplyPageState viewState;

  Widget _embeddedParentToldya(BuildContext context, FeedModel model) {
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
                  enableMentions: true,
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
                      child: _embeddedParentToldya(context, viewState.model),
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
    final textEditor = Container(
      decoration: BoxDecoration(
        color: _ComposeToldyaReplyPageState._cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: customImage(
              context,
              authState.user?.photoURL ?? '',
              height: 40,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _TextField(
              isToldya: widget.isToldya,
              isRetoldya: widget.isRetoldya,
              textEditingController: viewState._textEditingController,
              enableMentions: !widget.isToldya || widget.isRetoldya,
            ),
          )
        ],
      ),
    );

    if (viewState.widget.isToldya) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 10),
            textEditor,
            viewState._buildEndDateSection(context),
          ],
        ),
      );
    }

    return Container(
      height: fullHeight(context),
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _tweerCard(context),
          const SizedBox(height: 10),
          textEditor,
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
      this.isRetoldya = false,
      this.enableMentions = true})
      : super(key: key);
  final TextEditingController textEditingController;
  final bool isToldya;
  final bool isRetoldya;
  final bool enableMentions;

  @override
  Widget build(BuildContext context) {
    final searchState = Provider.of<SearchState>(context, listen: false);
    final theme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: textEditingController,
          inputFormatters: [
            LengthLimitingTextInputFormatter(ComposeToldyaState.kToldyaMaxLength),
          ],
          onChanged: (text) {
            Provider.of<ComposeToldyaState>(context, listen: false)
                .onDescriptionChanged(text, searchState,
                    enableMentionSearch: enableMentions);
          },
          maxLines: null,
          style: TextStyle(
            color: _ComposeToldyaReplyPageState._textColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: isToldya
                  ? AppLocalizations.of(context)!.composeToldyaHint
                  : isRetoldya
                      ? 'Add a comment'
                      : 'Bu tahmine yorum yap',
              hintStyle: TextStyle(
                fontSize: 18,
                color: _ComposeToldyaReplyPageState._textColor.withOpacity(0.6),
              )),
        ),
        if (isToldya)
          Consumer<ComposeToldyaState>(
            builder: (context, state, _) {
              final color = state.isOverLimit
                  ? theme.colorScheme.error
                  : state.isNearLimit
                      ? Colors.orange
                      : _ComposeToldyaReplyPageState._textColor.withOpacity(0.7);
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${state.characterCount} / ${ComposeToldyaState.kToldyaMaxLength}',
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
    return Consumer<ComposeToldyaState>(
      builder: (context, state, _) {
        final key = ValueKey(state.isOverLimit ? 'over' : 'under');
        final child = KeyedSubtree(
          key: key,
          child: state.isOverLimit
              ? content.animate().shake(duration: 300.ms, hz: 4, curve: Curves.easeInOut)
              : content,
        );
        return child;
      },
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
            color: _ComposeToldyaReplyPageState._cardBg,
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
