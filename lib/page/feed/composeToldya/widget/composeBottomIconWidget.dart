import 'dart:io';

import 'package:flutter/material.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/widgets/customWidgets.dart';

/// Alt çubuk: karakter sayacı. Kamera/galeri kaldırıldı (izin yok); görsel ekleme şimdilik kapalı.
class ComposeBottomIconWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final Function(File) onImageIconSelcted;

  ComposeBottomIconWidget({
    Key? key,
    required this.textEditingController,
    required this.onImageIconSelcted,
  }) : super(key: key);

  @override
  _ComposeBottomIconWidgetState createState() => _ComposeBottomIconWidgetState();
}

class _ComposeBottomIconWidgetState extends State<ComposeBottomIconWidget> {
  late Color wordCountColor;
  String _draftText = '';

  @override
  void initState() {
    wordCountColor = Colors.blue;
    widget.textEditingController.addListener(updateUI);
    super.initState();
  }

  void updateUI() {
    setState(() {
      _draftText = widget.textEditingController.text;
      if (widget.textEditingController.text.isNotEmpty) {
        if (widget.textEditingController.text.length > 259 &&
            widget.textEditingController.text.length < 280) {
          wordCountColor = Colors.orange;
        } else if (widget.textEditingController.text.length >= 280) {
          wordCountColor = Theme.of(context).colorScheme.error;
        } else {
          wordCountColor = Colors.blue;
        }
      }
    });
  }

  Widget _bottomIconWidget() {
    return Container(
      width: fullWidth(context),
      height: 50,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: _draftText.length > 289
                    ? Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: customText(
                          '${280 - _draftText.length}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            value: getToldyaCharLimit(),
                            backgroundColor: Colors.grey,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(wordCountColor),
                          ),
                          _draftText.length > 259
                              ? customText(
                                  '${280 - _draftText.length}',
                                  style: TextStyle(color: wordCountColor))
                              : customText('',
                                  style: TextStyle(color: wordCountColor))
                        ],
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  double getToldyaCharLimit() {
    if (_draftText.isEmpty) {
      return 0.0;
    }
    if (_draftText.length > 280) {
      return 1.0;
    }
    var length = _draftText.length;
    var val = length * 100 / 28000.0;
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _bottomIconWidget(),
    );
  }
}
