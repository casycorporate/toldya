import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/utility.dart';
class UrlText extends StatelessWidget {
  final String? text;
  final TextStyle? style;
  final TextStyle? urlStyle;
  final Function(String)? onHashTagPressed;

  UrlText({this.text, this.style, this.urlStyle, this.onHashTagPressed});

  List<InlineSpan> getTextSpans() {
    List<InlineSpan> widgets = <InlineSpan>[];
    RegExp reg = RegExp(
        r"([#])\w+| [@]\w+|(https?|ftp|file|#)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]*");
    final textStr = text ?? '';
    Iterable<Match> _matches = reg.allMatches(textStr);
    List<_ResultMatch> resultMatches = <_ResultMatch>[];
    int start = 0;
    for (Match match in _matches) {
      final g = match.group(0);
      if (g != null && g.isNotEmpty) {
        if (start != match.start) {
          _ResultMatch result1 = _ResultMatch();
          result1.isUrl = false;
          result1.text = textStr.substring(start, match.start);
          resultMatches.add(result1);
        }

        _ResultMatch result2 = _ResultMatch();
        result2.isUrl = true;
        result2.text = g;
        resultMatches.add(result2);
        start = match.end;
      }
    }
    if (start < textStr.length) {
      _ResultMatch result1 = _ResultMatch();
      result1.isUrl = false;
      result1.text = textStr.substring(start);
      resultMatches.add(result1);
    }
    for (var result in resultMatches) {
      if (result.isUrl) {
        widgets.add(_LinkTextSpan(
            onHashTagPressed: onHashTagPressed,
            text: result.text,
            style:
                urlStyle ?? TextStyle(color: Colors.blue)));
      } else {
        widgets.add(TextSpan(
            text: result.text,
            style: style ?? TextStyle(color: Colors.black)));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: getTextSpans()),
    );
  }
}

class _LinkTextSpan extends TextSpan {
  final Function(String)? onHashTagPressed;
  _LinkTextSpan({TextStyle? style, String? text, this.onHashTagPressed})
      : super(
            style: style,
            text: text,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                final t = text ?? '';
                if(onHashTagPressed != null && (t.isNotEmpty && (t.substring(0,1).contains("#") || t.substring(0,1).contains("@")))){
                  onHashTagPressed!(t);
                }
                else{
                  launchURL(t);
                }
              });
}

class _ResultMatch {
  bool isUrl = false;
  String text = '';
}