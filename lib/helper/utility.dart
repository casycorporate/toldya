import 'dart:async';

import 'package:bendemistim/model/feedModel.dart';
import 'package:bendemistim/model/userPegModel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:bendemistim/widgets/newWidget/customLoader.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;

final kAnalytics = FirebaseAnalytics.instance;
final DatabaseReference kDatabase = FirebaseDatabase.instance.ref();
final kScreenloader = CustomLoader();

String getPostTime2(String date) {
  if (date == null || date.isEmpty) {
    return '';
  }
  var dt = DateTime.parse(date).toLocal();
  var dat =
  DateFormat.yMMMEd('tr_TR').format(dt) + ' - ' + DateFormat.jm('tr_TR').format(dt);
      // DateFormat.jm().format(dt) + ' - ' + DateFormat("dd MMM yy").format(dt);
  return dat;
}

int sumOfVote(List<UserPegModel> list){
  int sum=0;
  list.forEach((e) {sum+=e.pegCount;});
  return sum;

}

/// Bahisler kapanış tarihinde veya statu kapalıysa true
bool isBettingClosed(int? statu, String? endDate) {
  if (statu != null && statu != 0) return true; // Statu.statusLive = 0
  if (endDate == null || endDate.isEmpty) return false;
  try {
    return DateTime.now().toUtc().isAfter(DateTime.parse(endDate).toUtc());
  } catch (_) {
    return false;
  }
}

/// Kullanıcı bu tahminde diğer tarafa (Evet/Hayır) zaten bahis yaptıysa true.
/// commentFlag: 0 = Evet, 1 = Hayır. Diğer tarafta kayıt varsa tek bahis kuralı ihlali.
bool userAlreadyBetOnOtherSide(FeedModel model, String? userId, int commentFlag) {
  if (userId == null || userId.isEmpty) return false;
  if (commentFlag == 0) return (model.unlikeList ?? []).any((e) => e.userId == userId);
  return (model.likeList ?? []).any((e) => e.userId == userId);
}

/// Gönderi statu değeri için kısa etiket (UI’da kullanılır).
/// statu değerini int'e çevirir (Firebase/JSON'dan gelen dynamic tip için).
int? parseStatu(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String getStatuLabel(int? statu) {
  if (statu == null) return '';
  switch (statu) {
    case 0: return 'Yayında';
    case 1: return 'Beklemede';
    case 2: return 'Onaylanan';
    case 3: return 'Reddedilen';
    case 4: return 'Tamamlanan';
    case 5: return 'Kilitli';
    case 6: return 'İncelemede';
    case 7: return 'AI reddi';
    default: return 'Durum $statu';
  }
}

String k_m_b_generator(num) {
  if (num > 999 && num < 99999) {
    return "${(num / 1000).toStringAsFixed(1)} K";
  } else if (num > 99999 && num < 999999) {
    return "${(num / 1000).toStringAsFixed(0)} K";
  } else if (num > 999999 && num < 999999999) {
    return "${(num / 1000000).toStringAsFixed(1)} M";
  } else if (num > 999999999) {
    return "${(num / 1000000000).toStringAsFixed(1)} B";
  } else {
    return num.toString();
  }
}

String getdob(String date) {
  if (date == null || date.isEmpty) {
    return '';
  }
  var dt = DateTime.parse(date).toLocal();
  var dat = DateFormat.yMMMEd('tr_TR').format(dt);
  return dat;
}

String getJoiningDate(String date) {
  if (date == null || date.isEmpty) {
    return '';
  }
  var dt = DateTime.parse(date).toLocal();
  var dat = DateFormat.yMMMEd('tr_TR').format(dt);
  return '$dat tarihinde katıldı';
}

String getChatTime(String date) {
  if (date == null || date.isEmpty) {
    return '';
  }
  String msg = '';
  var dt = DateTime.parse(date).toLocal();

  if (DateTime.now().toLocal().isBefore(dt)) {
    return DateFormat.jm().format(DateTime.parse(date).toLocal()).toString();
  }

  var dur = DateTime.now().toLocal().difference(dt);
  if (dur.inDays > 0) {
    msg = '${dur.inDays} g';
    return dur.inDays == 1 ? '1g' : DateFormat.yMMMd('tr_TR').format(dt);
  } else if (dur.inHours > 0) {
    msg = '${dur.inHours} s';
  } else if (dur.inMinutes > 0) {
    msg = '${dur.inMinutes} dk';
  } else if (dur.inSeconds > 0) {
    msg = '${dur.inSeconds} sn';
  } else {
    msg = 'şimdi';
  }
  return msg;
}

String getEndTime(String date) {
  if (date == null || date.isEmpty) {
    return '';
  }
  String msg = '';
  var dt = DateTime.parse(date).toLocal();

  if (DateTime.now().toLocal().isAfter(dt)) {
    return  'bitti';
  }

  var dur = dt.difference(DateTime.now().toLocal());
  if (dur.inDays > 0) {
    msg = '${dur.inDays} g';
    return dur.inDays == 1 ? '1g' : DateFormat.yMMMd('tr_TR').format(dt);
  } else if (dur.inHours > 0) {
    msg = '${dur.inHours} s';
  } else if (dur.inMinutes > 0) {
    msg = '${dur.inMinutes} dk';
  } else if (dur.inSeconds > 0) {
    msg = '${dur.inSeconds} sn';
  } else {
    msg = 'bitti';
  }
  return msg;
}

/// Görsel: "2d 14h 35m 12s" formatı (parlak kırmızı countdown)
String getCountdownLong(String? date) {
  if (date == null || date.isEmpty) return '';
  try {
    final dt = DateTime.parse(date).toLocal();
    if (DateTime.now().toLocal().isAfter(dt)) return 'Bitti';
    final d = dt.difference(DateTime.now().toLocal());
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    parts.add('${hours}h');
    parts.add('${minutes}m');
    parts.add('${seconds}s');
    return parts.join(' ');
  } catch (_) {
    return '';
  }
}

/// Kalan süre oranı (0.0 = bitti, 1.0 = tam süre). Daire göstergesi için.
double getCountdownProgress(String? endDate, String? createdAt) {
  if (endDate == null || endDate.isEmpty) return 0;
  try {
    final end = DateTime.parse(endDate).toLocal();
    final now = DateTime.now().toLocal();
    if (now.isAfter(end)) return 0;
    final start = createdAt != null && createdAt.isNotEmpty
        ? DateTime.parse(createdAt).toLocal()
        : now.subtract(Duration(days: 7));
    final total = end.difference(start).inSeconds;
    final remaining = end.difference(now).inSeconds;
    if (total <= 0) return 1;
    return (remaining / total).clamp(0.0, 1.0);
  } catch (_) {
    return 0.5;
  }
}

String getPollTime(String date) {
  int hr, mm;
  String msg = 'Poll ended';
  var enddate = DateTime.parse(date);
  if (DateTime.now().isAfter(enddate)) {
    return msg;
  }
  msg = 'Poll ended in';
  var dur = enddate.difference(DateTime.now());
  hr = dur.inHours - dur.inDays * 24;
  mm = dur.inMinutes - (dur.inHours * 60);
  if (dur.inDays > 0) {
    msg = ' ' + dur.inDays.toString() + (dur.inDays > 1 ? ' Days ' : ' Day');
  }
  if (hr > 0) {
    msg += ' ' + hr.toString() + ' hour';
  }
  if (mm > 0) {
    msg += ' ' + mm.toString() + ' min';
  }
  return (dur.inDays).toString() +
      ' Days ' +
      ' ' +
      hr.toString() +
      ' Hours ' +
      mm.toString() +
      ' min';
}

String? getSocialLinks(String? url) {
  if (url != null && url.isNotEmpty) {
    final String normalized = url.contains("https://www") || url.contains("http://www")
        ? url
        : url.contains("www") &&
                (!url.contains('https') && !url.contains('http'))
            ? 'https://' + url
            : 'https://www.' + url;
    cprint('Launching URL : $normalized');
    return normalized;
  }
  return null;
}

launchURL(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    cprint('Could not launch $url');
  }
}

void cprint(dynamic data, {String? errorIn, String? event}) {
  if (errorIn != null) {
    print(
        '****************************** error ******************************');
    developer.log('[Error]', time: DateTime.now(), error: data, name: errorIn);
    print(
        '****************************** error ******************************');
  } else if (data != null) {
    developer.log(
      data,
      time: DateTime.now(),
    );
  }
  if (event != null) {
    // logEvent(event);
  }
}

void logEvent(String event, {Map<String, dynamic>? parameter}) {
  kReleaseMode
      ? kAnalytics.logEvent(name: event, parameters: parameter != null ? Map<String, Object>.from(parameter) : null)
      : print("[EVENT]: $event");
}

void debugLog(String log, {dynamic param = ""}) {
  final String time = DateFormat("mm:ss:mmm").format(DateTime.now());
  print("[$time][Log]: $log, $param");
}

void share(String message, {String? subject}) {
  Share.share(message, subject: subject ?? '');
}

List<String> getHashTags(String text) {
  RegExp reg = RegExp(
      r"([#])\w+|(https?|ftp|file|#)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]*");
  Iterable<Match> _matches = reg.allMatches(text);
  List<String> resultMatches = <String>[];
  for (Match match in _matches) {
    final tag = match.group(0);
    if (tag != null && tag.isNotEmpty) {
      resultMatches.add(tag);
    }
  }
  return resultMatches;
}

String getUserName({
  String? id,
  String? name,
}) {
  String userName = '';
  final n = name ?? '';
  final i = id ?? '';
  if (n.length > 15) {
    return '@${n.substring(0, 6)}${i.substring(0, 4).toLowerCase()}';
  }
  final namePart = n.split(' ').first;
  final idPart = i.substring(0, i.length >= 4 ? 4 : i.length).toLowerCase();
  userName = '@$namePart$idPart';
  return userName;
}

bool validateCredentials(
    GlobalKey<ScaffoldState> _scaffoldKey, String email, String password) {
  if (email == null || email.isEmpty) {
    customSnackBar(_scaffoldKey, 'Lütfen e-posta adresini girin');
    return false;
  } else if (password == null || password.isEmpty) {
    customSnackBar(_scaffoldKey, 'Lütfen şifrenizi giriniz');
    return false;
  } else if (password.length < 8) {
    customSnackBar(_scaffoldKey, 'Şifre en az 8 karakter uzunluğunda olmalı');
    return false;
  }

  var status = validateEmal(email);
  if (!status) {
    customSnackBar(_scaffoldKey, 'Lütfen geçerli bir e-posta adresi girin');
    return false;
  }
  return true;
}

bool validateEmal(String email) {
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  RegExp regExp = new RegExp(p);

  var status = regExp.hasMatch(email);
  return status;
}
class Utility {
  static Future<void> createLinkToShare(BuildContext context, String id,
      {SocialMetaTagParameters? socialMetaTagParameters}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://casycorporate.page.link/',
      link: Uri.parse('https://casycorporate.page.link/$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.casycorporate.casy',
        minimumVersion: 0,
      ),
      // dynamicLinkParametersOptions: DynamicLinkParametersOptions(
      //   shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      // ),
      // socialMetaTagParameters: socialMetaTagParameters
    );
    Uri url;
    final ShortDynamicLink shortLink =
    await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    url = shortLink.shortUrl;
    share(url.toString(), subject: "casy");
    // return url;
    // Uri urlYeni = Uri.tryParse("https://play.google.com/store/apps/details?id=com.casycorporate.casy");
    //return url;
  }

  static Future<Uri> createLinkToCopy(BuildContext context, String id,
      {SocialMetaTagParameters? socialMetaTagParameters}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://casycorporate.page.link/',
      link: Uri.parse('https://casycorporate.page.link/$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.casycorporate.casy',
        minimumVersion: 0,
      ),
      // dynamicLinkParametersOptions: DynamicLinkParametersOptions(
      //   shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      // ),
      // socialMetaTagParameters: socialMetaTagParameters
    );
    Uri url;
    final ShortDynamicLink shortLink =
    await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    url = shortLink.shortUrl;

     return url;
    // Uri urlYeni = Uri.tryParse("https://play.google.com/store/apps/details?id=com.casycorporate.casy");
    //return url;
  }

 static createLinkAndShare(BuildContext context, String id,
      {SocialMetaTagParameters? socialMetaTagParameters}) async {
    var url = createLinkToShare(context, id,
        socialMetaTagParameters: socialMetaTagParameters);

    share(url.toString(), subject: "casy");
    // share('https://play.google.com/store/apps/details?id=com.casycorporate.casy', subject: "casy");
  }
}
void copyToClipBoard({
  GlobalKey<ScaffoldState>? scaffoldKey,
  String? text,
  String? message,
}) {
  if (message == null || text == null) return;
  var data = ClipboardData(text: text);
  Clipboard.setData(data);
  if (scaffoldKey != null) customSnackBar(scaffoldKey, message);
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
