import 'package:flutter/material.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';

class UnavailableToldya extends StatelessWidget {
  const UnavailableToldya({Key? key, required this.snapshot, required this.type}) : super(key: key);

  final AsyncSnapshot<FeedModel?> snapshot;
  final ToldyaType type;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 16),
      margin: EdgeInsets.only(
          right: 16,
          top: 5,
          left: type == ToldyaType.Toldya || type == ToldyaType.ParentToldya
              ? 70
              : 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColor.extraLightGrey.withValues(alpha: .3),
        border: Border.all(color: AppColor.extraLightGrey, width: .5),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: snapshot.connectionState == ConnectionState.waiting
          ? Center(
              child: CustomScreenLoader(
                height: 40,
                width: 40,
                backgroundColor: Colors.transparent,
              ),
            )
          : Text('This Tweet is unavailable', style: userNameStyle),
    );
  }
}
