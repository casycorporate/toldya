import 'package:app_links/app_links.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:toldya/generated/l10n/app_localizations.dart';

import 'package:toldya/main.dart';

import 'package:toldya/page/Auth/selectAuthMethod.dart';

import 'package:toldya/page/Auth/verifyEmail.dart';

import 'package:toldya/page/homePage.dart';

import 'package:toldya/state/authState.dart';



/// Android App Links + https deep link dinleyicisi.

class AppLinkService {

  AppLinkService._();



  static final AppLinks _appLinks = AppLinks();

  static bool _initialized = false;

  static bool _handlingDeepLink = false;



  static const String _host = 'casy-570c4.web.app';



  static Future<void> init() async {

    if (_initialized || kIsWeb) return;

    _initialized = true;



    try {

      final initial = await _appLinks.getInitialLink();

      if (initial != null) {

        await _handleUri(initial);

      }

    } catch (e, st) {

      debugPrint('[AppLink] getInitialLink failed: $e\n$st');

    }



    _appLinks.uriLinkStream.listen(

      (uri) => _handleUri(uri),

      onError: (Object e) => debugPrint('[AppLink] stream error: $e'),

    );

  }



  static Future<void> handleDeepLinkUri(Uri uri) async {

    await _handleUri(uri);

  }



  static bool _isHostedLink(Uri uri) {

    final host = uri.host.toLowerCase();

    return host == _host || host == 'casy-570c4.firebaseapp.com';

  }



  static bool isEmailVerificationLink(Uri uri) {

    if (!_isHostedLink(uri)) return false;

    final segments = uri.pathSegments;

    if (segments.isEmpty) return false;

    if (segments.first == 'email-verified') return true;

    if (segments.length > 1 &&

        segments.first == 'auth' &&

        segments[1] == 'verified') {

      return true;

    }

    return false;

  }



  static bool isPasswordResetDoneLink(Uri uri) {

    if (!_isHostedLink(uri)) return false;

    final segments = uri.pathSegments;

    return segments.isNotEmpty && segments.first == 'password-reset-done';

  }



  static Future<void> _handleUri(Uri uri) async {

    if (_handlingDeepLink) return;

    if (isEmailVerificationLink(uri)) {

      _handlingDeepLink = true;

      try {

        await completeEmailVerificationFromLink();

      } finally {

        _handlingDeepLink = false;

      }

      return;

    }

    if (isPasswordResetDoneLink(uri)) {

      _handlingDeepLink = true;

      try {

        await completePasswordResetFromLink();

      } finally {

        _handlingDeepLink = false;

      }

    }

  }



  static Future<void> completeEmailVerificationFromLink() async {

    final ctx = navigatorKey.currentContext;

    if (ctx == null) {

      debugPrint('[AppLink] navigator context not ready');

      return;

    }



    final authState = Provider.of<AuthState>(ctx, listen: false);

    await authState.getCurrentUser();

    final verified = await authState.reloadAndCheckEmailVerified();



    final nav = navigatorKey.currentState;

    if (nav == null) return;



    if (verified) {

      await authState.promoteToVerifiedAndContinue();

      nav.pushAndRemoveUntil(

        MaterialPageRoute(builder: (_) => HomePage()),

        (route) => false,

      );

    } else {

      nav.pushAndRemoveUntil(

        MaterialPageRoute(builder: (_) => const VerifyEmailPage()),

        (route) => false,

      );

    }

  }



  static Future<void> completePasswordResetFromLink() async {

    final nav = navigatorKey.currentState;

    if (nav == null) return;



    nav.pushAndRemoveUntil(

      MaterialPageRoute(builder: (_) => WelcomePage()),

      (route) => false,

    );



    WidgetsBinding.instance.addPostFrameCallback((_) {

      final ctx = navigatorKey.currentContext;

      if (ctx == null) return;

      final l10n = AppLocalizations.of(ctx);

      if (l10n == null) return;

      ScaffoldMessenger.of(ctx).showSnackBar(

        SnackBar(content: Text(l10n.passwordResetWebCompleteMessage)),

      );

    });

  }

}


