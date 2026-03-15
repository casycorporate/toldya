import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
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
import 'package:flutter_animate/flutter_animate.dart';
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
  bool _isEditMode = false;

  File? _image;
  late TextEditingController _textEditingController;
  /// V1: Kapanış zamanı (sadece yeni Toldya). En az 1 saat sonra.
  DateTime? _closesAt;

  @override
  void dispose() {
    scrollcontroller.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var feedState = Provider.of<FeedState>(context, listen: false);
    var composeState = Provider.of<ComposeToldyaState>(context, listen: false);
    if (feedState.toldyaToEditModel != null) {
      model = feedState.toldyaToEditModel!;
      _isEditMode = true;
      feedState.clearToldyaToEdit();
      final initial = model.description ?? '';
      _textEditingController = TextEditingController(text: initial);
      composeState.setInitialDescription(initial);
    } else {
      model = feedState.toldyaToReplyModel ?? FeedModel();
      _textEditingController = TextEditingController();
      if (widget.isToldya) {
        _closesAt = DateTime.now().add(const Duration(hours: 24));
      }
    }
    scrollcontroller = ScrollController();
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
    if (_textEditingController.text.isEmpty ||
        _textEditingController.text.length > ComposeToldyaState.kToldyaMaxLength) {
      return;
    }
    if (widget.isToldya && !_isEditMode) {
      final now = DateTime.now();
      final minClose = now.add(const Duration(hours: 1));
      if (_closesAt == null || _closesAt!.isBefore(minClose)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.closingTimeMinOneHour),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        return;
      }
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
      debugPrint("[FeedDebug] Compose: post published, toldyaKey=${toldyaModel.key ?? 'unknown'}");

      await Provider.of<ComposeToldyaState>(context, listen: false)
          .sendNotification(
              toldyaModel, Provider.of<SearchState>(context, listen: false));

      if (!mounted) return;
      kScreenloader.hideLoader();
      final l10n = AppLocalizations.of(context)!;
      if (widget.isToldya) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.predictionPublished),
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
      if (Navigator.canPop(context)) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        kScreenloader.hideLoader();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorTryAgain),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Return Tweet model which is either a new Tweet , retweet model or comment model
  /// V1: New Toldya → statu OPEN (0), endDate = _closesAt (en az 1 saat sonra).
  FeedModel createToldyaModel() {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    final userModel = authState.userModel!;
    userModel.rank = (userModel.rank ?? 0) + 2;
    authState.createUser(userModel);
    var myUser = userModel;
    var profilePic = myUser.profilePic ?? dummyProfilePic;
    final displayName = myUser.displayName ?? (myUser.email ?? '').split('@')[0];
    final userName = (authState.userModel?.userName?.trim().isNotEmpty == true)
        ? authState.userModel!.userName!
        : (displayName.isNotEmpty ? displayName : 'user');
    var commentedUser = UserModel(
        displayName: displayName,
        profilePic: profilePic,
        userId: myUser.userId,
        isVerified: authState.userModel?.isVerified ?? false,
        userName: userName);
    var tags = getHashTags(_textEditingController.text);
    final isNewToldya = widget.isToldya && state.toldyaToReplyModel == null && !widget.isRetoldya;
    FeedModel reply = FeedModel(
        statu: Statu.statusLive,
        topic: widget.isToldya ? null : state.toldyaToReplyModel?.topic,
        description: _textEditingController.text,
        user: commentedUser,
        createdAt: DateTime.now().toUtc().toIso8601String(),
        endDate: isNewToldya && _closesAt != null ? _closesAt!.toUtc().toIso8601String() : null,
        resolutionDate: null,
        oracleSource: null,
        oracleApiUrl: null,
        collateralAmount: null,
        tags: tags,
        parentkey: widget.isToldya ? null : widget.isRetoldya ? null : state.toldyaToReplyModel?.key,
        childRetoldyaKey: widget.isToldya ? null : widget.isRetoldya ? model.key : null,
        userId: myUser.userId);
    return reply;
  }

  static DateTime _minClosingTime() =>
      DateTime.now().add(const Duration(hours: 1));

  /// Preset: 1 hour from now.
  DateTime _presetOneHourLater() => _minClosingTime();

  /// Preset: tonight 21:00, or tomorrow 21:00 if already past.
  DateTime _presetTonight2100() {
    final now = DateTime.now();
    var d = DateTime(now.year, now.month, now.day, 21, 0);
    if (d.isBefore(_minClosingTime())) d = d.add(const Duration(days: 1));
    return d;
  }

  /// Preset: tomorrow 12:00.
  DateTime _presetTomorrow1200() {
    final t = DateTime.now().add(const Duration(days: 1));
    return DateTime(t.year, t.month, t.day, 12, 0);
  }

  /// Preset: tomorrow 21:00.
  DateTime _presetTomorrow2100() {
    final t = DateTime.now().add(const Duration(days: 1));
    return DateTime(t.year, t.month, t.day, 21, 0);
  }

  void _applyPreset(DateTime value) {
    final minClose = _minClosingTime();
    setState(() {
      _closesAt = value.isBefore(minClose) ? minClose : value;
    });
  }

  String _formatClosingSummary(DateTime? dt) {
    if (dt == null) return '';
    final locale = Localizations.localeOf(context).toString();
    final datePart = DateFormat('d MMM EEE', locale).format(dt);
    final timePart = DateFormat('HH:mm', locale).format(dt);
    return '$datePart • $timePart';
  }

  void _showCustomClosingTimeSheet() {
    final now = DateTime.now();
    final minClose = _minClosingTime();
    DateTime selectedDate = _closesAt != null && _closesAt!.isAfter(now)
        ? DateTime(_closesAt!.year, _closesAt!.month, _closesAt!.day)
        : DateTime(minClose.year, minClose.month, minClose.day);
    int selectedHour = _closesAt != null ? _closesAt!.hour : 21;
    int selectedMinute = _closesAt != null ? _closesAt!.minute : 0;

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            DateTime combined = DateTime(
                selectedDate.year, selectedDate.month, selectedDate.day,
                selectedHour, selectedMinute);
            if (combined.isBefore(minClose)) combined = minClose;

            final dayOptions = List<DateTime>.generate(14, (i) => now.add(Duration(days: i)));
            const timeSlots = [9, 12, 15, 18, 21];

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(ctx).viewPadding.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.closingTimeLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dayOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final d = dayOptions[i];
                        final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
                        final isSelected = d.year == selectedDate.year &&
                            d.month == selectedDate.month && d.day == selectedDate.day;
                        final label = isToday
                            ? l10n.todayLabel
                            : i == 1
                                ? l10n.tomorrowLabel
                                : DateFormat('d MMM', locale).format(d);
                        return Material(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () => setModalState(() => selectedDate = d),
                            borderRadius: BorderRadius.circular(8),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  label,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: isSelected ? FontWeight.w600 : null,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: timeSlots.map((h) {
                      final isSelected = selectedHour == h && selectedMinute == 0;
                      final timeStr = '${h.toString().padLeft(2, '0')}:00';
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () => setModalState(() {
                              selectedHour = h;
                              selectedMinute = 0;
                            }),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Text(
                                timeStr,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: isSelected ? FontWeight.w600 : null,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        DateTime result = DateTime(selectedDate.year, selectedDate.month,
                            selectedDate.day, selectedHour, selectedMinute);
                        if (result.isBefore(minClose)) result = minClose;
                        setState(() => _closesAt = result);
                        Navigator.of(ctx).pop();
                      },
                      child: Text(l10n.confirm),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Kapanış zamanı: hızlı preset’ler + özet + isteğe bağlı özel seçim.
  Widget _buildClosingTimeRow() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.closingTimeLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _presetChip(theme, l10n.closingPreset1Hour, () => _applyPreset(_presetOneHourLater())),
              _presetChip(theme, l10n.closingPresetTonight, () => _applyPreset(_presetTonight2100())),
              _presetChip(theme, l10n.closingPresetTomorrow12, () => _applyPreset(_presetTomorrow1200())),
              _presetChip(theme, l10n.closingPresetTomorrow21, () => _applyPreset(_presetTomorrow2100())),
              _presetChip(theme, l10n.closingPresetCustom, _showCustomClosingTimeSheet),
            ],
          ),
          if (_closesAt != null) ...[
            const SizedBox(height: 10),
            Text(
              '${l10n.closingSelected} ${_formatClosingSummary(_closesAt)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                l10n.closingTimeHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _presetChip(ThemeData theme, String label, VoidCallback onTap) {
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
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
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.isToldya) _buildClosingTimeRow(),
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
          urlStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w400),
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
                    color: Theme.of(context).colorScheme.outline,
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
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  UrlText(
                    text:
                        '${viewState.model.user?.userName ?? viewState.model.user?.displayName ?? ""} tahminine yanıt',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
          if (!viewState.widget.isToldya)
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
    final theme = Theme.of(context);
    final content = Column(
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
            color: theme.colorScheme.onSurface,
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              )),
        ),
        Consumer<ComposeToldyaState>(
          builder: (context, state, _) {
            final color = state.isOverLimit
                ? theme.colorScheme.error
                : state.isNearLimit
                    ? Theme.of(context).colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7);
            return Padding(
              padding: EdgeInsets.only(top: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${state.characterCount} / ${ComposeToldyaState.kToldyaMaxLength}',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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
