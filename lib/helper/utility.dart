import 'dart:async';

import 'package:toldya/model/feedModel.dart';
import 'package:toldya/model/userPegModel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/newWidget/customLoader.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;

final kAnalytics = FirebaseAnalytics.instance;
final DatabaseReference kDatabase = FirebaseDatabase.instance.ref();
final kScreenloader = CustomLoader();

/// Logging flags (keep default silent; enable temporarily in debug sessions).
const bool _utilityDebug = false;
const bool _utilityEventDebug = false;

/// Kullanıcı adı gösterimi: baştaki @ kaldırılır, sadece kullanıcı adı döner (örn. "sinanyilmaz").
String formatHandle(String? userName, [String? displayName]) {
  final raw = userName?.trim() ?? displayName?.trim() ?? '';
  if (raw.isEmpty) return '';
  final withoutLeadingAt = raw.startsWith('@') ? raw.substring(1) : raw;
  return withoutLeadingAt.trim();
}

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

/// Tahmin katılımı kapanış tarihinde veya statu kapalıysa true
bool isToldyaStakeClosed(int? statu, String? endDate) {
  if (statu != null && statu != 0) return true; // Statu.statusLive = 0
  if (endDate == null || endDate.isEmpty) return false;
  try {
    return DateTime.now().toUtc().isAfter(DateTime.parse(endDate).toUtc());
  } catch (_) {
    return false;
  }
}

/// Kullanıcı bu tahminde diğer tarafa (Evet/Hayır) zaten katılım gösterdiyse true.
/// commentFlag: 0 = Evet, 1 = Hayır. Diğer tarafta kayıt varsa tek taraf kuralı ihlali.
bool userAlreadyStakedOtherSide(FeedModel model, String? userId, int commentFlag) {
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

/// major.minor.patch sayılarına çevirir (+build ve ilk `-` öncesi segment kullanılır).
List<int> appVersionToComparableParts(String v) {
  final core = v.split('+').first.split('-').first.trim();
  if (core.isEmpty) return [0];
  return core.split('.').map((s) => int.tryParse(s.trim()) ?? 0).toList();
}

/// Yüklü sürüm, Remote Config’teki **minimum desteklenen** sürümden büyük veya eşit mi?
/// Eşitlikte true (kullanıcı tam bu sürümdeyse güncelle zorlanmaz).
bool isInstalledAppVersionAtLeast(String installed, String minimumRequired) {
  final i = appVersionToComparableParts(installed);
  final m = appVersionToComparableParts(minimumRequired);
  final len = i.length > m.length ? i.length : m.length;
  for (var k = 0; k < len; k++) {
    final iv = k < i.length ? i[k] : 0;
    final mv = k < m.length ? m[k] : 0;
    if (iv > mv) return true;
    if (iv < mv) return false;
  }
  return true;
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
    case 7: return 'Yönetici reddi';
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

String getPollTime(BuildContext context, String date) {
  final l10n = AppLocalizations.of(context)!;
  var enddate = DateTime.parse(date);
  if (DateTime.now().isAfter(enddate)) {
    return l10n.pollEnded;
  }
  var dur = enddate.difference(DateTime.now());
  int hr = dur.inHours - dur.inDays * 24;
  int mm = dur.inMinutes - (dur.inHours * 60);
  final parts = <String>[];
  if (dur.inDays > 0) {
    parts.add('${dur.inDays} ${dur.inDays > 1 ? l10n.pollDays : l10n.pollDay}');
  }
  if (hr > 0) {
    parts.add('$hr ${hr > 1 ? l10n.pollHours : l10n.pollHour}');
  }
  if (mm > 0) {
    parts.add('$mm ${l10n.pollMin}');
  }
  return parts.isEmpty ? l10n.pollEnded : '${l10n.pollEndedIn} ${parts.join(' ')}';
}

String? getSocialLinks(String? url) {
  if (url != null && url.isNotEmpty) {
    final String normalized = url.contains("https://www") || url.contains("http://www")
        ? url
        : url.contains("www") &&
                (!url.contains('https') && !url.contains('http'))
            ? 'https://' + url
            : 'https://www.' + url;
    return normalized;
  }
  return null;
}

launchURL(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    cprint('Could not launch $url', errorIn: 'launchURL');
  }
}

void cprint(dynamic data, {String? errorIn, String? event}) {
  if (data == null) return;
  if (errorIn != null && errorIn.isNotEmpty) {
    developer.log(
      errorIn,
      name: 'toldya',
      time: DateTime.now(),
      error: data,
    );
    return;
  }
  if (kDebugMode && _utilityDebug) {
    developer.log(
      data.toString(),
      name: 'toldya',
      time: DateTime.now(),
    );
  }
  if (event != null && event.isNotEmpty) {
    logEvent(event);
  }
}

void logEvent(String event, {Map<String, dynamic>? parameter}) {
  if (event.isEmpty) return;
  if (kReleaseMode) {
    kAnalytics.logEvent(
      name: event,
      parameters: parameter != null ? Map<String, Object>.from(parameter) : null,
    );
    return;
  }
  if (_utilityEventDebug) {
    developer.log(
      event,
      name: 'analytics',
      time: DateTime.now(),
      error: parameter,
    );
  }
}

void debugLog(String log, {dynamic param = ""}) {
  if (!kDebugMode || !_utilityDebug) return;
  developer.log(
    log,
    name: 'debug',
    time: DateTime.now(),
    error: param,
  );
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

/// Firebase Auth [FirebaseAuthException.code] → kullanıcı dilinde kısa mesaj.
String localizedFirebaseAuthError(AppLocalizations l10n, Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        return l10n.authErrorEmailAlreadyInUse;
      case 'invalid-email':
        return l10n.authErrorInvalidEmail;
      case 'wrong-password':
      case 'invalid-credential':
        return l10n.authErrorInvalidCredential;
      case 'user-not-found':
        return l10n.authErrorUserNotFound;
      case 'weak-password':
        return l10n.authErrorWeakPassword;
      case 'user-disabled':
        return l10n.authErrorUserDisabled;
      case 'too-many-requests':
        return l10n.authErrorTooManyRequests;
      case 'operation-not-allowed':
        return l10n.authErrorOperationNotAllowed;
      case 'network-request-failed':
        return l10n.authErrorNetwork;
      case 'requires-recent-login':
        return l10n.authErrorRequiresRecentLogin;
      case 'credential-already-in-use':
        return l10n.authErrorCredentialAlreadyInUse;
      case 'account-exists-with-different-credential':
        return l10n.authErrorAccountExistsDifferentCredential;
      case 'missing-email':
        return l10n.authErrorMissingEmail;
      default:
        return l10n.errorGeneric;
    }
  }
  return l10n.errorGeneric;
}

void showLocalizedFirebaseAuthSnackBar(
    GlobalKey<ScaffoldState>? scaffoldKey, Object error) {
  if (scaffoldKey == null) return;
  final ctx = scaffoldKey.currentContext;
  if (ctx == null) return;
  final l10n = AppLocalizations.of(ctx);
  if (l10n == null) return;
  customSnackBar(scaffoldKey, localizedFirebaseAuthError(l10n, error));
}

bool validateCredentials(BuildContext context,
    GlobalKey<ScaffoldState> _scaffoldKey, String email, String password) {
  final l10n = AppLocalizations.of(context)!;
  if (email.isEmpty) {
    customSnackBar(_scaffoldKey, l10n.pleaseEnterEmail);
    return false;
  } else if (password.isEmpty) {
    customSnackBar(_scaffoldKey, l10n.pleaseEnterPassword);
    return false;
  } else if (password.length < kMinPasswordLength) {
    customSnackBar(_scaffoldKey, l10n.passwordMinLength(kMinPasswordLength));
    return false;
  }

  var status = validateEmal(email);
  if (!status) {
    customSnackBar(_scaffoldKey, l10n.validEmailRequired);
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
  /// Paylaşım linkleri Firebase Dynamic Links ile üretilir.
  /// Üretimde domain ve [AndroidParameters.packageName] değerleri Firebase / Play ile eşleşmelidir.
  static Future<void> createLinkToShare(BuildContext context, String id,
      {SocialMetaTagParameters? socialMetaTagParameters}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://casycorporate.page.link/',
      link: Uri.parse('https://casycorporate.page.link/$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.casycorporate.toldya',
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
    share(url.toString(), subject: "Toldya");
    // return url;
    // Uri urlYeni = Uri.tryParse("https://play.google.com/store/apps/details?id=com.casycorporate.toldya");
    //return url;
  }

  static Future<Uri> createLinkToCopy(BuildContext context, String id,
      {SocialMetaTagParameters? socialMetaTagParameters}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://casycorporate.page.link/',
      link: Uri.parse('https://casycorporate.page.link/$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.casycorporate.toldya',
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
    // Uri urlYeni = Uri.tryParse("https://play.google.com/store/apps/details?id=com.casycorporate.toldya");
    //return url;
  }

 static createLinkAndShare(BuildContext context, String id,
      {SocialMetaTagParameters? socialMetaTagParameters}) async {
    var url = createLinkToShare(context, id,
        socialMetaTagParameters: socialMetaTagParameters);

    share(url.toString(), subject: "Toldya");
    // share('https://play.google.com/store/apps/details?id=com.casycorporate.toldya', subject: "Toldya");
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
