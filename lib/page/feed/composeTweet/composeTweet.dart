import 'dart:io';
import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/helper/topicMap.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:bendemistim/page/feed/composeTweet/widget/composeTweetImage.dart';
import 'package:bendemistim/page/feed/composeTweet/widget/widgetView.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:bendemistim/state/feedState.dart';
import 'package:bendemistim/state/searchState.dart';
import 'package:bendemistim/widgets/customAppBar.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customUrlText.dart';
import 'package:bendemistim/widgets/newWidget/title_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ComposeTweetPage extends StatefulWidget {
  ComposeTweetPage({Key? key, bool? isRetweet, bool? isTweet = true})
      : isRetweet = isRetweet ?? false,
        isTweet = isTweet ?? true,
        super(key: key);

  final bool isRetweet;
  final bool isTweet;

  _ComposeTweetReplyPageState createState() => _ComposeTweetReplyPageState();
}

class _ComposeTweetReplyPageState extends State<ComposeTweetPage> {
  bool isScrollingDown = false;
  late FeedModel model;
  late ScrollController scrollcontroller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  File? _image;
  late TextEditingController _textEditingController;
  late TextEditingController _endDateController;
  late TextEditingController _resolutionDateController;
  late TextEditingController _oracleSourceController;
  late TextEditingController _oracleApiUrlController;
  late TextEditingController _collateralController;
  late String endDate;
  String _selectedTopic = 'spor';

  @override
  void dispose() {
    scrollcontroller.dispose();
    _textEditingController.dispose();
    _endDateController.dispose();
    _resolutionDateController.dispose();
    _oracleSourceController.dispose();
    _oracleApiUrlController.dispose();
    _collateralController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var feedState = Provider.of<FeedState>(context, listen: false);
    model = feedState.toldyaToReplyModel ?? FeedModel();
    scrollcontroller = ScrollController();
    _textEditingController = TextEditingController();
    scrollcontroller..addListener(_scrollListener);
    _endDateController = TextEditingController();
    _resolutionDateController = TextEditingController();
    _oracleSourceController = TextEditingController();
    _oracleApiUrlController = TextEditingController();
    _collateralController = TextEditingController(text: '0');
    final defaultDate = DateTime.now().add(const Duration(hours: 24));
    _endDateController.text = defaultDate.toUtc().toString();
    _resolutionDateController.text = defaultDate.add(const Duration(hours: 1)).toUtc().toString();
    super.initState();
  }

  Future<void> showPickerDateTime(BuildContext context) async {
    final now = DateTime.now();
    final minDate = now.add(const Duration(hours: 12));
    final initialDate = _endDateController.text.isNotEmpty
        ? DateTime.tryParse(_endDateController.text)?.toLocal() ?? minDate
        : minDate;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(minDate) ? initialDate : minDate,
      firstDate: minDate,
      lastDate: DateTime(now.year + 10),
      helpText: "Bitiş tarihini seçiniz",
    );
    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: "Bitiş saatini seçiniz",
    );
    if (pickedTime == null || !mounted) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() {
      _endDateController.text = combined.toUtc().toString();
      if (DateTime.parse(_resolutionDateController.text).isBefore(combined)) {
        _resolutionDateController.text = combined.add(const Duration(hours: 1)).toUtc().toString();
      }
    });
  }

  Future<void> showPickerResolutionDateTime(BuildContext context) async {
    final closeDate = DateTime.tryParse(_endDateController.text) ?? DateTime.now().add(const Duration(hours: 24));
    final minDate = closeDate;
    final initialDate = _resolutionDateController.text.isNotEmpty
        ? DateTime.tryParse(_resolutionDateController.text)?.toLocal() ?? minDate
        : minDate.add(const Duration(hours: 1));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(minDate) ? minDate : initialDate,
      firstDate: minDate,
      lastDate: DateTime(DateTime.now().year + 10),
      helpText: "Sonuçlanma tarihini seçiniz",
      cancelText: "İptal",
      confirmText: "Tamam",
    );
    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: "Sonuçlanma saatini seçiniz",
      cancelText: "İptal",
      confirmText: "Tamam",
    );
    if (pickedTime == null || !mounted) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    if (combined.isBefore(closeDate)) return;
    setState(() {
      _resolutionDateController.text = combined.toUtc().toString();
    });
  }

  Widget _dateTimePicker() {
    final dateLabel = getPostTime2(_endDateController.text);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showPickerDateTime(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColor.primary.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: AppColor.primary,
                  size: 22,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Bitiş tarihi",
                      style: GoogleFonts.crimsonPro(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodySmall?.color ?? AppColor.darkGrey,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      dateLabel,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_calendar_rounded,
                color: AppColor.primary.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resolutionDateTimePicker() {
    final dateLabel = getPostTime2(_resolutionDateController.text);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showPickerResolutionDateTime(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColor.primary.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: AppColor.primary,
                  size: 22,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Sonuçlanma tarihi",
                      style: GoogleFonts.crimsonPro(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodySmall?.color ?? AppColor.darkGrey,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      dateLabel,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_calendar_rounded,
                color: AppColor.primary.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _oracleSourceField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.primary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.source_rounded, color: AppColor.primary, size: 22),
          SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _oracleSourceController,
              decoration: InputDecoration(
                hintText: 'Kanıt kaynağı (örn: Resmi haber sitesi, maç skoru)',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _oracleApiUrlField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.primary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.api_rounded, color: AppColor.primary, size: 22),
          SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _oracleApiUrlController,
              decoration: InputDecoration(
                hintText: 'API URL (otomatik sonuç, opsiyonel)',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _collateralField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.primary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.security_rounded, color: AppColor.primary, size: 22),
          SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _collateralController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Teminat (Kapak, 0 = yok)',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _scrollListener() {
    if (scrollcontroller.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!isScrollingDown) {
        Provider.of<ComposeTweetState>(context, listen: false)
            .setIsScrolllingDown = true;
      }
    }
    if (scrollcontroller.position.userScrollDirection ==
        ScrollDirection.forward) {
      Provider.of<ComposeTweetState>(context, listen: false)
          .setIsScrolllingDown = false;
    }
  }

  void onGenderSelected(String genderKey) {
    setState(() {
      _selectedTopic = genderKey;
    });
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
    var dt = DateTime.parse(_endDateController.text.toString()).toLocal();
    var dur = dt.difference(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        DateTime.now().hour + 12,
        DateTime.now().minute).toLocal());
    if (_endDateController.text == null ||
        _endDateController.text.isEmpty ||
        dur.inHours<0) {
      customSnackBar(_scaffoldKey, '❗LÜTFEN BİTİŞ TARİHİNİ EN AZ 12 SAAT İÇİNDE BİTECEK DURUMDA AYARLAYINIZ ❗');
      return;
    }
    final resolutionDt = DateTime.tryParse(_resolutionDateController.text);
    if (resolutionDt != null && resolutionDt.isBefore(dt)) {
      customSnackBar(_scaffoldKey, '❗Sonuçlanma tarihi kapanış tarihinden sonra olmalıdır ❗');
      return;
    }
    final collateral = int.tryParse(_collateralController.text) ?? 0;
    if (collateral < 0) {
      customSnackBar(_scaffoldKey, '❗Teminat negatif olamaz ❗');
      return;
    }
    final authState = Provider.of<AuthState>(context, listen: false);
    if (collateral > 0 && (authState.userModel?.pegCount ?? 0) < collateral) {
      customSnackBar(_scaffoldKey, '❗Teminat için yeterli Kapak bulunmuyor ❗');
      return;
    }
    var state = Provider.of<FeedState>(context, listen: false);
    kScreenloader.showLoader(context);

    FeedModel toldyaModel = createToldyaModel();

    /// If tweet contain image
    /// First image is uploaded on firebase storage
    /// After sucessfull image upload to firebase storage it returns image path
    /// Add this image path to tweet model and save to firebase database
    if (_image != null) {
      final imageFile = _image!;
      await state.uploadFile(imageFile).then((imagePath) {
        if (imagePath != null) {
          toldyaModel.imagePath = imagePath;

          /// If type of toldya is new toldya
          if (widget.isTweet) {
            state.createToldya(toldyaModel);
          }

          /// If type of toldya is retoldya
          else if (widget.isRetweet) {
            state.createReToldya(toldyaModel);
          }

          /// If type of toldya is new comment
          else {
            state.addcommentToPost(toldyaModel);
          }
        }
      });
    }

    /// If toldya did not contain image
    else {
      if (widget.isTweet) {
        state.createToldya(toldyaModel);
      }
      else if (widget.isRetweet) {
        state.createReToldya(toldyaModel);
      }
      else {
        state.addcommentToPost(toldyaModel);
      }
    }

    /// Checks for username in tweet description
    /// If foud sends notification to all tagged user
    /// If no user found or not compost tweet screen is closed and redirect back to home page.
    await Provider.of<ComposeTweetState>(context, listen: false)
        .sendNotification(
            toldyaModel, Provider.of<SearchState>(context, listen: false))
        .then((_) {
      /// Hide running loader on screen
      kScreenloader.hideLoader();

      /// Yeni tahmin gönderisinde: inceleme alındı mesajı
      if (widget.isTweet && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gönderiniz incelemeye alındı. Onaylandığında akışta görünecektir.',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }

      /// Navigate back to home page
      Navigator.pop(context);
    });
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
    final collateral = int.tryParse(_collateralController.text) ?? 0;
    if (collateral > 0 && widget.isTweet) {
      userModel.pegCount = (userModel.pegCount ?? 0) - collateral;
      authState.createUser(userModel);
    } else {
      authState.createUser(userModel);
    }
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
        statu: widget.isTweet ? Statu.statusPendingAiReview : Statu.statusLive,
        topic: _selectedTopic,
        description: _textEditingController.text,
        user: commentedUser,
        createdAt: DateTime.now().toUtc().toString(),
        endDate: _endDateController.text,
        resolutionDate: widget.isTweet ? _resolutionDateController.text : null,
        oracleSource: widget.isTweet ? (_oracleSourceController.text.trim().isEmpty ? null : _oracleSourceController.text.trim()) : null,
        oracleApiUrl: widget.isTweet ? (_oracleApiUrlController.text.trim().isEmpty ? null : _oracleApiUrlController.text.trim()) : null,
        collateralAmount: widget.isTweet ? (int.tryParse(_collateralController.text) ?? 0) : null,
        tags: tags,
        parentkey: widget.isTweet
            ? null
            : widget.isRetweet
                ? null
                : state.toldyaToReplyModel?.key,
        childRetwetkey: widget.isTweet
            ? null
            : widget.isRetweet
                ? model.key
                : null,
        userId: myUser.userId);
    return reply;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: customTitleText(''),
        onActionPressed: _submitButton,
        isCrossButton: true,
        submitButtonText: widget.isTweet
            ? 'diyorum'
            : widget.isRetweet
                ? 'Retweet'
                : 'Reply',
        isSubmitDisable:
            !Provider.of<ComposeTweetState>(context).enableSubmitButton ||
                Provider.of<FeedState>(context).isBusy,
        isbootomLine: Provider.of<ComposeTweetState>(context).isScrollingDown,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: scrollcontroller,
              child: widget.isRetweet
                  ? _ComposeRetweet(this)
                  : _ComposeTweet(this),
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

class _ComposeRetweet
    extends WidgetView<ComposeTweetPage, _ComposeTweetReplyPageState> {
  _ComposeRetweet(this.viewState) : super(viewState);

  final _ComposeTweetReplyPageState viewState;

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
                    child: customImage(context, model.user?.profilePic ?? ''),
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
            color: Colors.black,
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
                  isTweet: false,
                  isRetweet: true,
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
            child: ComposeTweetImage(
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

class _ComposeTweet
    extends WidgetView<ComposeTweetPage, _ComposeTweetReplyPageState> {
  _ComposeTweet(this.viewState) : super(viewState);

  final _ComposeTweetReplyPageState viewState;

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
                        color: Colors.black,
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
                        'Replying to ${viewState.model.user?.userName ?? viewState.model.user?.displayName ?? ""}',
                    style: TextStyle(
                      color: ToldyaColor.paleSky,
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
                customImage(context, viewState.model.user?.profilePic ?? '',
                    height: 40),
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
          viewState.widget.isTweet ? SizedBox.shrink() : _tweerCard(context),
          viewState._dateTimePicker(),
          if (viewState.widget.isTweet) ...[
            SizedBox(height: 12),
            viewState._resolutionDateTimePicker(),
            SizedBox(height: 12),
            viewState._oracleSourceField(),
            SizedBox(height: 12),
            viewState._oracleApiUrlField(),
            SizedBox(height: 12),
            viewState._collateralField(),
          ],
          SizedBox(height: 10),
          CupertinoRadioChoice(
              selectedColor: AppColor.primary,
              choices: topic.topicMap,
              onChange: viewState.onGenderSelected,
              initialKeyValue: viewState._selectedTopic),
          SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              customImage(context, authState.user?.photoURL ?? '', height: 40),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: _TextField(
                  isTweet: widget.isTweet,
                  textEditingController: viewState._textEditingController,
                ),
              )
            ],
          ),
          Flexible(
            child: Stack(
              children: <Widget>[
                ComposeTweetImage(
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
      this.isTweet = false,
      this.isRetweet = false})
      : super(key: key);
  final TextEditingController textEditingController;
  final bool isTweet;
  final bool isRetweet;

  @override
  Widget build(BuildContext context) {
    final searchState = Provider.of<SearchState>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: textEditingController,
          onChanged: (text) {
            Provider.of<ComposeTweetState>(context, listen: false)
                .onDescriptionChanged(text, searchState);
          },
          maxLines: null,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: isTweet
                  ? 'Gelecek tahminlerini paylaş'
                  : isRetweet
                      ? 'Add a comment'
                      : 'Tweet your reply',
              hintStyle: TextStyle(fontSize: 18)),
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
    return !Provider.of<ComposeTweetState>(context).displayUserList ||
            list.isEmpty
        ? SizedBox.shrink()
        : Container(
            padding: EdgeInsetsDirectional.only(bottom: 50),
            color: ToldyaColor.white,
            constraints:
                BoxConstraints(minHeight: 30, maxHeight: double.infinity),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return _UserTile(
                  user: list[index],
                  onUserSelected: (user) {
                    textEditingController.text =
                        (Provider.of<ComposeTweetState>(context, listen: false)
                                .getDescription(user.userName ?? '') ?? '') +
                            " ";
                    textEditingController.selection = TextSelection.collapsed(
                        offset: textEditingController.text.length);
                    Provider.of<ComposeTweetState>(context, listen: false)
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
      leading: customImage(context, user.profilePic ?? '', height: 35),
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
