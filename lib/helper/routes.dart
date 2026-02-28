import 'package:flutter/material.dart';
import 'package:bendemistim/page/Auth/selectAuthMethod.dart';
import 'package:bendemistim/page/Auth/verifyEmail.dart';
import 'package:bendemistim/page/common/splash.dart';
import 'package:bendemistim/page/feed/composeTweet/composeTweet.dart';
import 'package:bendemistim/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:bendemistim/page/feed/feedPage.dart';
import 'package:bendemistim/page/message/conversationInformation/conversationInformation.dart';
import 'package:bendemistim/page/message/newMessagePage.dart';
import 'package:bendemistim/page/profile/follow/followerListPage.dart';
import 'package:bendemistim/page/profile/follow/followingListPage.dart';
import 'package:bendemistim/page/profile/profileImageView.dart';
import 'package:bendemistim/page/search/SearchPage.dart';
import 'package:bendemistim/page/settings/accountSettings/about/aboutTwitter.dart';
import 'package:bendemistim/page/settings/accountSettings/accessibility/accessibility.dart';
import 'package:bendemistim/page/settings/accountSettings/accountSettingsPage.dart';
import 'package:bendemistim/page/settings/accountSettings/contentPrefrences/contentPreference.dart';
import 'package:bendemistim/page/settings/accountSettings/contentPrefrences/trends/trendsPage.dart';
import 'package:bendemistim/page/settings/accountSettings/dataUsage/dataUsagePage.dart';
import 'package:bendemistim/page/settings/accountSettings/displaySettings/displayAndSoundPage.dart';
import 'package:bendemistim/page/settings/accountSettings/notifications/notificationPage.dart';
import 'package:bendemistim/page/settings/accountSettings/privacyAndSafety/directMessage/directMessage.dart';
import 'package:bendemistim/page/settings/accountSettings/privacyAndSafety/privacyAndSafetyPage.dart';
import 'package:bendemistim/page/settings/accountSettings/proxy/proxyPage.dart';
import 'package:bendemistim/page/settings/settingsAndPrivacyPage.dart';
import 'package:provider/provider.dart';
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

class Routes{
  static dynamic route(){
      return {
          'SplashPage': (BuildContext context) =>   SplashPage(),
      };
  }

  static void sendNavigationEventToFirebase(String path) {
    if(path.isNotEmpty){
      // analytics.setCurrentScreen(screenName: path);
    }
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
     final String name = settings.name ?? '';
     final List<String> pathElements = name.split('/');
     if (pathElements.isEmpty || pathElements[0] != '' || pathElements.length == 1) {
       return null;
     }
     switch (pathElements[1]) {
      case "ComposeToldyaPage": 
        bool isRetoldya = false;
        bool isToldya = false;
        if(pathElements.length >= 3 && pathElements[2].contains('retoldya')){
          isRetoldya = true;
        }
        else if(pathElements.length == 3 && pathElements[2].contains('toldya')){
          isToldya = true;
        }
        else if(pathElements.length == 4 && pathElements[2] == 'toldya'){
          isToldya = false;
        }
        return CustomRoute<bool>(builder:(BuildContext context)=> ChangeNotifierProvider<ComposeToldyaState>(
          create: (_) => ComposeToldyaState(),
          child: ComposeToldyaPage(isRetoldya: isRetoldya, isToldya: isToldya),
        ));
      case "FeedPostDetail":
        var postId = pathElements.length > 2 ? pathElements[2] : '';
          return SlideLeftRoute<bool>(builder:(BuildContext context)=> FeedPostDetail(postId: postId.isEmpty ? null : postId,),settings: RouteSettings(name:'FeedPostDetail'));
        case "ProfilePage":
         String profileId = pathElements.length > 2 ? pathElements[2] : '';
        return CustomRoute<bool>(builder:(BuildContext context)=> ProfilePage(
          profileId: profileId,
        )); 
      case "CreateFeedPage": return CustomRoute<bool>(builder:(BuildContext context)=> ChangeNotifierProvider<ComposeToldyaState>(
          create: (_) => ComposeToldyaState(),
          child: ComposeToldyaPage(isRetoldya:false, isToldya: true),
        ));
      case "WelcomePage":return CustomRoute<bool>(builder:(BuildContext context)=> WelcomePage());
      case "FeedPage":return CustomRoute<bool>(builder:(BuildContext context)=> FeedPage());
       case "SignIn":return CustomRoute<bool>(builder:(BuildContext context)=> SignIn());
      case "SignUp":return CustomRoute<bool>(builder:(BuildContext context)=> Signup()); 
      case "ForgetPasswordPage":return CustomRoute<bool>(builder:(BuildContext context)=> ForgetPasswordPage()); 
      case "SearchPage":return CustomRoute<bool>(builder:(BuildContext context)=> SearchPage()); 
      case "ImageViewPge":return CustomRoute<bool>(builder:(BuildContext context)=> ImageViewPge());
      case "EditProfile":return CustomRoute<bool>(builder:(BuildContext context)=> EditProfilePage()); 
      case "ProfileImageView":return SlideLeftRoute<bool>(builder:(BuildContext context)=> ProfileImageView()); 
      case "ChatScreenPage":return CustomRoute<bool>(builder:(BuildContext context)=> ChatScreenPage()); 
      case "NewMessagePage":return CustomRoute<bool>(builder:(BuildContext context)=> NewMessagePage(),); 
      case "SettingsAndPrivacyPage":return CustomRoute<bool>(builder:(BuildContext context)=> SettingsAndPrivacyPage(),); 
      case "AccountSettingsPage":return CustomRoute<bool>(builder:(BuildContext context)=> AccountSettingsPage(),); 
      case "AccountSettingsPage":return CustomRoute<bool>(builder:(BuildContext context)=> AccountSettingsPage(),); 
      case "PrivacyAndSaftyPage":return CustomRoute<bool>(builder:(BuildContext context)=> PrivacyAndSaftyPage(),); 
      case "NotificationPage":return CustomRoute<bool>(builder:(BuildContext context)=> NotificationPage(),); 
      case "ContentPrefrencePage":return CustomRoute<bool>(builder:(BuildContext context)=> ContentPrefrencePage(),); 
      case "DisplayAndSoundPage":return CustomRoute<bool>(builder:(BuildContext context)=> DisplayAndSoundPage(),); 
      case "DirectMessagesPage":return CustomRoute<bool>(builder:(BuildContext context)=> DirectMessagesPage(),); 
      case "TrendsPage":return CustomRoute<bool>(builder:(BuildContext context)=> TrendsPage(),); 
      case "DataUsagePage":return CustomRoute<bool>(builder:(BuildContext context)=> DataUsagePage(),); 
      case "AccessibilityPage":return CustomRoute<bool>(builder:(BuildContext context)=> AccessibilityPage(),); 
      case "ProxyPage":return CustomRoute<bool>(builder:(BuildContext context)=> ProxyPage(),); 
      case "AboutPage":return CustomRoute<bool>(builder:(BuildContext context)=> AboutPage(),); 
      case "ConversationInformation":return CustomRoute<bool>(builder:(BuildContext context)=> ConversationInformation(),); 
      case "FollowingListPage":return CustomRoute<bool>(builder:(BuildContext context)=> FollowingListPage(),); 
      case "FollowerListPage":return CustomRoute<bool>(builder:(BuildContext context)=> FollowerListPage(),); 
      case "LeaderboardPage":return CustomRoute<bool>(builder:(BuildContext context)=> LeaderboardPage(),);
      case "TokenEarnPage":return CustomRoute<bool>(builder:(BuildContext context)=> TokenEarnPage(),); 
      case "VerifyEmailPage":return CustomRoute<bool>(builder:(BuildContext context)=> VerifyEmailPage(),); 
      default:return onUnknownRoute(RouteSettings(name: '/Feature'));
     }
  }

   static Route<dynamic> onUnknownRoute(RouteSettings settings){
     final List<String> parts = (settings.name ?? '').split('/');
     final String featureName = parts.length > 1 ? parts[1] : 'Feature';
     return MaterialPageRoute(
          builder: (_) => Scaffold(
                appBar: AppBar(title: customTitleText(featureName),centerTitle: true,),
                body: Center(
                  child: Text('$featureName Coming soon..'),
                ),
              ),
        );
   }
}