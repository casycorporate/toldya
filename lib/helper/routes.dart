import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/page/Auth/selectAuthMethod.dart';
import 'package:toldya/page/Auth/verifyEmail.dart';
import 'package:toldya/page/common/splash.dart';
import 'package:toldya/page/admin/admin_moderation_page.dart';
import 'package:toldya/page/feed/composeToldya/compose_toldya_page.dart';
import 'package:toldya/page/feed/composeToldya/state/compose_toldya_state.dart';
import 'package:toldya/page/feed/feedPage.dart';
import 'package:toldya/page/message/conversationInformation/conversationInformation.dart';
import 'package:toldya/page/message/newMessagePage.dart';
import 'package:toldya/page/profile/profileImageView.dart';
import 'package:toldya/page/search/SearchPage.dart';
import 'package:toldya/page/settings/accountSettings/about/aboutTwitter.dart';
import 'package:toldya/page/settings/accountSettings/accessibility/accessibility.dart';
import 'package:toldya/page/settings/accountSettings/accountSettingsPage.dart';
import 'package:toldya/page/settings/accountSettings/contentPrefrences/contentPreference.dart';
import 'package:toldya/page/settings/accountSettings/contentPrefrences/trends/trendsPage.dart';
import 'package:toldya/page/settings/accountSettings/dataUsage/dataUsagePage.dart';
import 'package:toldya/page/settings/accountSettings/displaySettings/displayAndSoundPage.dart';
import 'package:toldya/page/settings/accountSettings/notifications/notificationPage.dart';
import 'package:toldya/page/notification/notificationPage.dart'
    as notification_feed;
import 'package:toldya/page/settings/accountSettings/privacyAndSafety/directMessage/directMessage.dart';
import 'package:toldya/page/settings/accountSettings/privacyAndSafety/blockedAccounts/blockedAccountsPage.dart';
import 'package:toldya/page/settings/accountSettings/privacyAndSafety/privacyAndSafetyPage.dart';
import 'package:toldya/page/settings/accountSettings/privacyAndSafety/mutedWords/mutedWordsPage.dart';
import 'package:toldya/page/settings/accountSettings/privacyAndSafety/legal/legalUrlPage.dart';
import 'package:toldya/page/settings/accountSettings/proxy/proxyPage.dart';
import 'package:toldya/page/settings/languagePage.dart';
import 'package:toldya/page/settings/settingsAndPrivacyPage.dart';
import 'package:provider/provider.dart';
import 'package:toldya/state/authState.dart';
import '../page/Auth/signin.dart';
import '../helper/customRoute.dart';
import '../page/feed/imageViewPage.dart';
import '../page/Auth/forgetPasswordPage.dart';
import '../page/Auth/signup.dart';
import '../page/feed/feedPostDetail.dart';
import '../page/profile/EditProfilePage.dart';
import '../page/profile/leaderboard/leaderboardPage.dart';
import '../page/profile/token_earn_page.dart';
import '../page/message/chatScreenPage.dart';
import '../page/profile/profilePage.dart';
import '../widgets/customWidgets.dart';

class Routes {
  static dynamic route() {
    return {
      'SplashPage': (BuildContext context) => SplashPage(),
    };
  }

  static void sendNavigationEventToFirebase(String path) {
    if (path.isNotEmpty) {
      // analytics.setCurrentScreen(screenName: path);
    }
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final String name = settings.name ?? '';
    if (name.isEmpty || !name.startsWith('/')) return null;

    final uri = Uri.tryParse(name);
    final segments = uri?.pathSegments ?? const <String>[];
    if (segments.isEmpty) return null;

    final routeName = segments.first;
    String segmentAt(int index) =>
        segments.length > index ? segments[index] : '';

    switch (routeName) {
      /// Aliases (deep link friendly):
      /// - /profile/{id} -> ProfilePage(profileId)
      /// - /toldya/{id}  -> FeedPostDetail(postId)
      case 'auth':
        if (segmentAt(1) == 'verified') {
          return CustomRoute<bool>(
            builder: (BuildContext context) => const EmailVerifiedLandingPage(),
          );
        }
        return onUnknownRoute(RouteSettings(name: '/Feature'));
      case 'email-verified':
        return CustomRoute<bool>(
          builder: (BuildContext context) => const EmailVerifiedLandingPage(),
        );
      case 'profile':
        final profileId = segmentAt(1);
        return CustomRoute<bool>(
          builder: (BuildContext context) => ProfilePage(profileId: profileId),
        );
      case 'toldya':
        final postId = segmentAt(1);
        if (!kEnablePostDetail) {
          return MaterialPageRoute(
            builder: (_) => const _SilentBlockedRoutePopPage(),
            settings: const RouteSettings(name: 'SilentBlocked'),
          );
        }
        return SlideLeftRoute<bool>(
          builder: (BuildContext context) =>
              FeedPostDetail(postId: postId.isEmpty ? null : postId),
          settings: const RouteSettings(name: 'FeedPostDetail'),
        );

      /// Existing routes (keep unchanged for NotificationService/pushNamed callers).
      case "ComposeToldyaPage":
        final mode = segmentAt(1); // e.g. toldya / retoldya / toldya/{id}
        final isRetoldya = mode.contains('retoldya');
        final isToldya =
            mode.contains('toldya') && !isRetoldya && segments.length < 3;
        return CustomRoute<bool>(
          builder: (BuildContext context) =>
              ChangeNotifierProvider<ComposeToldyaState>(
            create: (_) => ComposeToldyaState(),
            child:
                ComposeToldyaPage(isRetoldya: isRetoldya, isToldya: isToldya),
          ),
        );
      case "FeedPostDetail":
        final postId = segmentAt(1);
        if (!kEnablePostDetail) {
          return MaterialPageRoute(
            builder: (_) => const _SilentBlockedRoutePopPage(),
            settings: const RouteSettings(name: 'SilentBlocked'),
          );
        }
        return SlideLeftRoute<bool>(
          builder: (BuildContext context) =>
              FeedPostDetail(postId: postId.isEmpty ? null : postId),
          settings: const RouteSettings(name: 'FeedPostDetail'),
        );
      case "ProfilePage":
        final profileId = segmentAt(1);
        return CustomRoute<bool>(
          builder: (BuildContext context) => ProfilePage(profileId: profileId),
        );
      case "CreateFeedPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) =>
              ChangeNotifierProvider<ComposeToldyaState>(
            create: (_) => ComposeToldyaState(),
            child: ComposeToldyaPage(isRetoldya: false, isToldya: true),
          ),
        );
      case "WelcomePage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => WelcomePage());
      case "FeedPage":
        return CustomRoute<bool>(builder: (BuildContext context) => FeedPage());
      case "SignIn":
        return CustomRoute<bool>(builder: (BuildContext context) => SignIn());
      case "SignUp":
        return CustomRoute<bool>(builder: (BuildContext context) => Signup());
      case "ForgetPasswordPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ForgetPasswordPage());
      case "SearchPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => SearchPage());
      case "ImageViewPge":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ImageViewPge());
      case "EditProfile":
        return CustomRoute<bool>(
            builder: (BuildContext context) => EditProfilePage());
      case "ProfileImageView":
        return SlideLeftRoute<bool>(
            builder: (BuildContext context) => ProfileImageView());
      case "ChatScreenPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ChatScreenPage());
      case "NewMessagePage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => NewMessagePage());
      case "SettingsAndPrivacyPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => SettingsAndPrivacyPage());
      case "AccountSettingsPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => AccountSettingsPage());
      case "PrivacyAndSaftyPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => PrivacyAndSaftyPage());
      case "BlockedAccountsPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => const BlockedAccountsPage());
      case "MutedWordsPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => const MutedWordsPage());
      case "LegalUrlPage":
        final type = segmentAt(1);
        return CustomRoute<bool>(
            builder: (BuildContext context) => LegalUrlPage(type: type));
      case "NotificationPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => NotificationPage());
      case "NotificationFeedPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                notification_feed.NotificationPage());
      case "ContentPrefrencePage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ContentPrefrencePage());
      case "DisplayAndSoundPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => DisplayAndSoundPage());
      case "DirectMessagesPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => DirectMessagesPage());
      case "TrendsPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => TrendsPage());
      case "DataUsagePage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => DataUsagePage());
      case "AccessibilityPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => AccessibilityPage());
      case "ProxyPage":
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return FutureBuilder<bool>(
              future:
                  Provider.of<AuthState>(context, listen: false).isAdminUser(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting ||
                    !snap.hasData) {
                  return const Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.data == true) return const ProxyPage();
                return const _SilentBlockedRoutePopPage();
              },
            );
          },
        );
      case "AboutPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => AboutPage());
      case "LanguagePage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => const LanguagePage());
      case "ConversationInformation":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ConversationInformation());
      case "LeaderboardPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => LeaderboardPage());
      case "TokenEarnPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => TokenEarnPage());
      case "VerifyEmailPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => VerifyEmailPage());
      case "AdminModerationPage":
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return FutureBuilder<bool>(
              future:
                  Provider.of<AuthState>(context, listen: false).isAdminUser(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting ||
                    !snap.hasData) {
                  return const Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.data == true) return const AdminModerationPage();
                return const _SilentBlockedRoutePopPage();
              },
            );
          },
          settings: const RouteSettings(name: 'AdminModerationPage'),
        );
      default:
        return onUnknownRoute(RouteSettings(name: '/Feature'));
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    final List<String> parts = (settings.name ?? '').split('/');
    final String featureName = parts.length > 1 ? parts[1] : 'Feature';
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: customTitleText(featureName),
          centerTitle: true,
        ),
        body: Center(
          child: Text(
              AppLocalizations.of(context)!.featureComingSoon(featureName)),
        ),
      ),
    );
  }
}

/// Invisible route that immediately pops (silent block).
class _SilentBlockedRoutePopPage extends StatefulWidget {
  const _SilentBlockedRoutePopPage();

  @override
  State<_SilentBlockedRoutePopPage> createState() =>
      _SilentBlockedRoutePopPageState();
}

class _SilentBlockedRoutePopPageState
    extends State<_SilentBlockedRoutePopPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
