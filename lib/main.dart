import 'package:toldya/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:toldya/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/state/searchState.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_picker/PickerLocalizationsDelegate.dart';
import 'helper/routes.dart';
import 'state/appState.dart';
import 'package:provider/provider.dart';
import 'state/authState.dart';
import 'state/chats/chatState.dart';
import 'state/feedState.dart';
import 'package:google_fonts/google_fonts.dart';
import 'state/notificationState.dart';

/// Navigator key for FCM deep linking (NotificationService uses this).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // App Check KAPALI: Bazı cihazlarda GMS "Unknown calling package name 'com.google.android.gms'"
  // SecurityException veriyor. Sunucuda placeBet/claimDailyBonus için enforceAppCheck: false.
  // Sorun giderildikten sonra aşağıdaki blok tekrar açılabilir.
  // if (kDebugMode) {
  //   await FirebaseAppCheck.instance.activate(
  //     androidProvider: AndroidProvider.debug,
  //     appleProvider: AppleProvider.debug,
  //   );
  // } else {
  //   await FirebaseAppCheck.instance.activate(
  //     androidProvider: AndroidProvider.playIntegrity,
  //     appleProvider: AppleProvider.appAttest,
  //   );
  // }

  // FCM: Bildirim servisini başlat (izin, token, foreground/background/terminated yönetimi).
  await NotificationService.init(navigatorKey);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<AuthState>(create: (_) => AuthState()),
        ChangeNotifierProvider<FeedState>(create: (_) => FeedState()),
        ChangeNotifierProvider<ChatState>(create: (_) => ChatState()),
        ChangeNotifierProvider<SearchState>(create: (_) => SearchState()),
        ChangeNotifierProvider<ComposeToldyaState>(create: (_) => ComposeToldyaState()),
        ChangeNotifierProvider<NotificationState>(
            create: (_) => NotificationState()),
      ],
      child: _LocaleLoader(
        child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Toldya',
            theme: AppTheme.apptheme.copyWith(
              textTheme: GoogleFonts.sawarabiMinchoTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            debugShowCheckedModeBanner: false,
            routes: Routes.route(),
            onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
            onUnknownRoute: (settings) => Routes.onUnknownRoute(settings),
            initialRoute: "SplashPage",
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              PickerLocalizationsDelegate.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: appState.locale,
            localeResolutionCallback: (locale, supported) {
              if (appState.locale != null) return appState.locale;
              for (final s in supported) {
                if (s.languageCode == locale?.languageCode) return s;
              }
              return const Locale('tr');
            },
          );
        },
        ),
      ),
    );
  }
}

/// Loads saved locale once from SharedPreferences. Must be a descendant of MultiProvider.
class _LocaleLoader extends StatefulWidget {
  final Widget child;

  const _LocaleLoader({required this.child});

  @override
  State<_LocaleLoader> createState() => _LocaleLoaderState();
}

class _LocaleLoaderState extends State<_LocaleLoader> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Provider.of<AppState>(context, listen: false).loadLocale();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
