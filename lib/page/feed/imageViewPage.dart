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
import 'package:toldya/widgets/toldya/widgets/toldya_icons_row.dart';
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
    final FeedModel? detailModel =
        state.toldyaDetailModel?.isNotEmpty == true ? state.toldyaDetailModel!.last : null;
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

  void _submitButton() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body());
  }
}
