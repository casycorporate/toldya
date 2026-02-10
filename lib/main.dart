import 'package:bendemistim/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/state/searchState.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // initializeDateFormatting('tr');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<AuthState>(create: (_) => AuthState()),
        ChangeNotifierProvider<FeedState>(create: (_) => FeedState()),
        ChangeNotifierProvider<ChatState>(create: (_) => ChatState()),
        ChangeNotifierProvider<SearchState>(create: (_) => SearchState()),
        ChangeNotifierProvider<ComposeTweetState>(create: (_) => ComposeTweetState()),
        ChangeNotifierProvider<NotificationState>(
            create: (_) => NotificationState()),
      ],
      child: MaterialApp(
        title: 'Ben demiştim',
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
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          PickerLocalizationsDelegate.delegate
        ],
        supportedLocales: [
          const Locale('tr','TR')
        ],
      ),
    );
  }
}
