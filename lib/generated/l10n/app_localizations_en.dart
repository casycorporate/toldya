// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Toldya';

  @override
  String get login => 'Log in';

  @override
  String get signUp => 'Sign up';

  @override
  String get tagline => 'Share your predictions, see who was right.';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get followers => 'Followers';

  @override
  String get follower => 'Follower';

  @override
  String get following => 'Following';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get settingsAndPrivacy => 'Settings and privacy';

  @override
  String get logout => 'Log out';

  @override
  String get account => 'Account';

  @override
  String get privacyAndPolicy => 'Privacy and safety';

  @override
  String get language => 'Language';

  @override
  String get followSuccess => 'Following';

  @override
  String get unfollowSuccess => 'Unfollowed';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get nameTooLong => 'Name must not exceed 27 characters';

  @override
  String get pleaseFillForm => 'Please fill out the form carefully';

  @override
  String get passwordMismatch => 'Password and confirmation do not match';

  @override
  String get back => 'Back';

  @override
  String get pressBackAgainToExit => 'Press back again to exit';

  @override
  String get signUpNow => 'Sign up now';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signIn => 'Log in';

  @override
  String get name => 'Name';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get enterPasswordAgain => 'Enter password again';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get validEmailRequired => 'Please enter a valid email address';

  @override
  String get emailEmpty => 'Email cannot be empty';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get shared => 'Shared.';

  @override
  String get postUnderReview =>
      'Your post is under review. It will appear in the feed when approved.';

  @override
  String get commentAdded => 'Your comment was added.';

  @override
  String get errorTryAgain => 'Something went wrong. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get endOfResults => 'End of results';

  @override
  String get post => 'Post';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get continueAction => 'Continue';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get disputeRecorded => 'Your dispute has been recorded';

  @override
  String get predictionDeleted => 'Prediction deleted.';

  @override
  String get errorDeleteFailed =>
      'An error occurred while deleting. Please try again.';

  @override
  String get userBlocked => 'User blocked.';

  @override
  String get userUnblocked => 'User unblocked.';

  @override
  String get pleaseSelectBetAmount => 'Please select a bet amount!';

  @override
  String maxBetTokens(String maxVal) {
    return 'Maximum bet: $maxVal tokens';
  }

  @override
  String get betOnOneSideOnly =>
      'You have already bet on the other side of this prediction. You can only bet on one side (Yes or No) per prediction.';

  @override
  String get betPlaced => 'Bet placed.';

  @override
  String get confirmBet => 'Confirm bet';

  @override
  String confirmBetMessage(String amount) {
    return 'Are you sure you want to bet $amount tokens on this prediction?';
  }

  @override
  String get messageSent => 'Sent';

  @override
  String get messageSendFailed => 'Failed to send. Please try again.';

  @override
  String get usernameRequired => 'Username cannot be empty';

  @override
  String usernameRules(int min, int max) {
    return 'Username must be $min–$max characters; only letters, numbers and underscores allowed.';
  }

  @override
  String get usernameTaken => 'This username is taken';

  @override
  String get errorCheckFailed => 'An error occurred while checking';

  @override
  String get errorSaveFailed => 'An error occurred while saving';

  @override
  String get nameTooLongProfile => 'Name must not exceed 27 characters';

  @override
  String get adsComingSoon => 'Ads feature coming soon.';

  @override
  String tokensAdded(String amount) {
    return '+$amount tokens added!';
  }

  @override
  String get purchaseComingSoon => 'Purchase coming soon.';

  @override
  String get searchHint => 'Search...';

  @override
  String get trendPredictions => 'Trending predictions';

  @override
  String get noPredictionsInCategory => 'No predictions in this category';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get liveSuggestions => 'Live suggestions';

  @override
  String get noResults => 'No results';

  @override
  String get predictions => 'Predictions';

  @override
  String get people => 'People';

  @override
  String get user => 'User';

  @override
  String get usernameLabel => 'Username';

  @override
  String get prediction => 'Prediction';

  @override
  String get noPredictionResult => 'No prediction result';

  @override
  String get noPersonResult => 'No person result';

  @override
  String get noPredictionOutcome => 'No prediction outcome';

  @override
  String get followingLabel => 'Following';

  @override
  String get follow => 'Follow';

  @override
  String get categoryFlow => 'Feed';

  @override
  String get categoryFavorite => 'Favorite';

  @override
  String get categoryFollow => 'Following';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryEconomy => 'Economy';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryPolitics => 'Politics';

  @override
  String get aboutToldya => 'About Toldya';

  @override
  String get help => 'Help';

  @override
  String get legal => 'Legal';

  @override
  String get developer => 'Developer';

  @override
  String get newMessage => 'New message';

  @override
  String get messages => 'Messages';

  @override
  String get predictors => 'Predictors';

  @override
  String get bettors => 'Bettors';

  @override
  String get dataPreference => 'Data preference';

  @override
  String get darkModeAppearance => 'Dark mode appearance';

  @override
  String get wifiOnly => 'Wi-Fi only';

  @override
  String get tokenInsufficient => 'Insufficient tokens';

  @override
  String get closedNoSelection => 'Cannot select because it is closed';

  @override
  String get thisTweetUnavailable => 'This post is unavailable';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get challengeLabel => 'Challenge: ';

  @override
  String get selectUser => 'Select user';

  @override
  String get challengePickTitle => 'Challenge: Select user';

  @override
  String get followingListEmpty =>
      'You are not following anyone. Add someone to your following list first.';

  @override
  String get followingListLoadingOrEmpty =>
      'Loading your list or no users found.';

  @override
  String get agree => 'Agree';

  @override
  String get disagree => 'Disagree';

  @override
  String get voteFailed => 'Vote could not be sent.';

  @override
  String get comments => 'Comments';

  @override
  String get noCommentsYet => 'No comments yet. Be the first to comment.';

  @override
  String get predictionDetail => 'Prediction detail';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get weeklyLeague => 'Weekly league';

  @override
  String get leagueNotCreatedYet =>
      'This week\'s league group has not been created yet.';

  @override
  String get leagueWillAppearWhenAssigned =>
      'You will appear here when league assignment is run.';

  @override
  String get leaguePreSeasonTitle => 'New season is around the corner! 🏆';

  @override
  String get leaguePreSeasonSubtitle =>
      'Opponents are being determined... When league assignments are ready, you\'ll compete here in a group of 30.';

  @override
  String leagueCountdown(int days, int hours) {
    return '${days}d ${hours}h';
  }

  @override
  String get tokenInsufficientForVote =>
      'Cannot vote due to insufficient tokens';

  @override
  String get betErrorGeneric => 'Bet could not be placed.';

  @override
  String gmsError(String message) {
    return 'Google Play Services error: $message';
  }

  @override
  String get unknownError => 'Unknown error';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get resetPasswordSent =>
      'A password reset link has been sent to your email.';

  @override
  String get selectProfilePhoto => 'Select profile photo';

  @override
  String get selectCoverPhoto => 'Select cover photo';

  @override
  String get appAvatars => 'App avatars';

  @override
  String get appCovers => 'App covers';

  @override
  String get exampleUsername => 'E.g. user_123';

  @override
  String get bio => 'Bio';

  @override
  String get location => 'Location';

  @override
  String get birthDate => 'Birth date';

  @override
  String get save => 'Save';

  @override
  String get sortUserList => 'Sort user list';

  @override
  String get updateNow => 'Update now';

  @override
  String get alert => 'Alert';

  @override
  String get forIos => 'For iOS';

  @override
  String get forAndroid => 'For Android';

  @override
  String get iSayYes => 'I said';

  @override
  String get iSayNo => 'I didn\'t';

  @override
  String get votersList => 'Voters';

  @override
  String get noVotesYet => 'No votes on this post yet';

  @override
  String get voteListEmptySubtitle =>
      'When someone votes on this post, they will appear here.';

  @override
  String get commentFailed => 'Comment could not be added. Please try again.';

  @override
  String get loginRequired => 'You need to sign in.';

  @override
  String get betTimeout => 'Request timed out. Please try again.';

  @override
  String get gmsUpdateMessage =>
      'Google Play Services error. Please restart your device or update Google Play Services.';

  @override
  String featureComingSoon(String feature) {
    return '$feature coming soon.';
  }

  @override
  String get tokenEarnTitle => 'Earn tokens';

  @override
  String get watchAdTitle => 'Watch ad';

  @override
  String tokenEarnFreeSubtitle(String amount) {
    return '$amount free tokens';
  }

  @override
  String get watch => 'Watch';

  @override
  String get dailyBonusTitle => 'Daily bonus';

  @override
  String get claim => 'Claim';

  @override
  String get tryAgainTomorrow => 'Try again tomorrow';

  @override
  String get tokenPacksTitle => 'Token packs';

  @override
  String get mostPopular => 'Most popular';

  @override
  String get bestValue => 'Best value';

  @override
  String get dataUsageTitle => 'Data usage';

  @override
  String get dataSaverHeader => 'Data saver';

  @override
  String get dataSaverTitle => 'Data saver';

  @override
  String get dataSaverSubtitle =>
      'When enabled, video won’t autoplay and lower-quality images load. This reduces your data usage for all accounts on this device.';

  @override
  String get imagesHeader => 'Images';

  @override
  String get highQualityImagesTitle => 'High quality images';

  @override
  String highQualityImagesSubtitle(String network) {
    return '$network\\n\\nSelect when high quality images should load.';
  }

  @override
  String get videoHeader => 'Video';

  @override
  String get highQualityVideoTitle => 'High quality video';

  @override
  String highQualityVideoSubtitle(String network) {
    return '$network\\n\\nSelect when the highest quality available should play.';
  }

  @override
  String get videoAutoplayTitle => 'Video autoplay';

  @override
  String videoAutoplaySubtitle(String network) {
    return '$network\\n\\nSelect when video should play automatically.';
  }

  @override
  String get dataSyncHeader => 'Data sync';

  @override
  String get syncDataTitle => 'Sync data';

  @override
  String get syncIntervalTitle => 'Sync interval';

  @override
  String get daily => 'Daily';

  @override
  String get syncDataDescription =>
      'Allow Toldya to sync data in the background to enhance your experience.';

  @override
  String get mobileDataWifi => 'Mobile data & Wi‑Fi';

  @override
  String get never => 'Never';

  @override
  String get dim => 'Dim';

  @override
  String get lightOut => 'Lights out';

  @override
  String get darkModeTitle => 'Dark mode';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get automaticAtSunset => 'Automatic at sunset';

  @override
  String get verifiedUserFirst => 'Verified users first';

  @override
  String get newestUserFirst => 'Newest users first';

  @override
  String get oldestUserFirst => 'Oldest users first';

  @override
  String get maxFollowerFirst => 'Most followers first';

  @override
  String get alphabeticallySort => 'Alphabetically';

  @override
  String get displayAndSoundTitle => 'Display and sound';

  @override
  String get mediaHeader => 'Media';

  @override
  String get mediaPreviewsTitle => 'Media previews';

  @override
  String get displayHeader => 'Display';

  @override
  String get emojiTitle => 'Emoji';

  @override
  String get emojiSubtitle =>
      'Use the app set instead of your device\'s default set';

  @override
  String get soundHeader => 'Sound';

  @override
  String get soundEffectsTitle => 'Sound effects';

  @override
  String get webBrowserHeader => 'Web browser';

  @override
  String get useInAppBrowserTitle => 'Use in-app browser';

  @override
  String get useInAppBrowserSubtitle =>
      'Open external links with the in-app browser';

  @override
  String get accessibilityTitle => 'Accessibility';

  @override
  String get screenReaderHeader => 'Screen reader';

  @override
  String get pronounceHashtagTitle => 'Pronounce # as \"hashtag\"';

  @override
  String get visionHeader => 'Vision';

  @override
  String get composeImageDescriptionsTitle => 'Compose image descriptions';

  @override
  String get composeImageDescriptionsSubtitle =>
      'Adds the ability to describe images for visually impaired users.';

  @override
  String get motionHeader => 'Motion';

  @override
  String get reduceMotionTitle => 'Reduce motion';

  @override
  String get reduceMotionSubtitle =>
      'Limit in-app animations, including live engagement counts.';

  @override
  String get accountTitle => 'Account';

  @override
  String get loginHeader => 'Login';

  @override
  String get emailAddressTitle => 'Email address';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get filtersHeader => 'Filters';

  @override
  String get qualityFilterTitle => 'Quality filter';

  @override
  String get qualityFilterSubtitle =>
      'Filter lower-quality notifications. This won\'t filter notifications from people you follow or accounts you\'ve interacted with recently.';

  @override
  String get advancedFilterTitle => 'Advanced filter';

  @override
  String get mutedWordTitle => 'Muted words';

  @override
  String get preferencesHeader => 'Preferences';

  @override
  String get unreadBadgeTitle => 'Unread notification count badge';

  @override
  String get unreadBadgeSubtitle =>
      'Display a badge with the number of notifications waiting for you inside the app.';

  @override
  String get pushNotificationsTitle => 'Push notifications';

  @override
  String get smsNotificationsTitle => 'SMS notifications';

  @override
  String get emailNotificationsTitle => 'Email notifications';

  @override
  String get emailNotificationsSubtitle =>
      'Control when and how often the app sends emails to you.';

  @override
  String get contentPreferencesTitle => 'Content preferences';

  @override
  String get exploreHeader => 'Explore';

  @override
  String get trendsTitle => 'Trends';

  @override
  String get searchSettingsTitle => 'Search settings';

  @override
  String get languagesHeader => 'Languages';

  @override
  String get recommendationsTitle => 'Recommendations';

  @override
  String get recommendationsSubtitle =>
      'Select which language you want recommended posts, people, and trends to include';

  @override
  String get safetyHeader => 'Safety';

  @override
  String get blockedAccountsTitle => 'Blocked accounts';

  @override
  String get mutedAccountsTitle => 'Muted accounts';

  @override
  String get helpHeader => 'Help';

  @override
  String get helpCenterTitle => 'Help center';

  @override
  String get termsOfServiceTitle => 'Terms of service';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get cookieUseTitle => 'Cookie use';

  @override
  String get legalNoticesTitle => 'Legal notices';

  @override
  String get searchFilterTitle => 'Search filter';

  @override
  String get trendsLocationTitle => 'Trends location';

  @override
  String get emailVerificationSent =>
      'A verification link has been sent to your email.';

  @override
  String get privacyAndSafetyTitle => 'Privacy and safety';

  @override
  String get privacySharesHeader => 'Posts';

  @override
  String get protectPostsTitle => 'Protect your posts';

  @override
  String get protectPostsSubtitle =>
      'Only your current followers and people you approve in the future can see your posts.';

  @override
  String get photoTaggingTitle => 'Photo tagging';

  @override
  String get photoTaggingSubtitle => 'Anyone can tag you';

  @override
  String get liveVideoHeader => 'Live video';

  @override
  String get connectToLiveVideoTitle => 'Connect to live video';

  @override
  String get connectToLiveVideoSubtitle =>
      'When on, you can go live and comment; when off, others can’t go live or comment.';

  @override
  String get discoverabilityHeader => 'Discoverability and contacts';

  @override
  String get discoverabilityTitle => 'Discoverability and contacts';

  @override
  String get discoverabilitySubtitle =>
      'Learn more about how this data is used to match you with other people.';

  @override
  String get securityHeader => 'Security';

  @override
  String get showSensitiveMediaTitle =>
      'Display media that may contain sensitive content';

  @override
  String get markSensitiveMediaTitle =>
      'Mark media you post as containing sensitive material';

  @override
  String get mutedWordsTitle => 'Muted words';

  @override
  String get locationHeader => 'Location';

  @override
  String get preciseLocationTitle => 'Precise location';

  @override
  String get preciseLocationSubtitle =>
      'Off\\n\\n\\nWhen on, Toldya collects, stores, and uses your device’s precise location (such as GPS information). This helps improve your experience by offering more local content, ads, and recommendations.';

  @override
  String get personalizationHeader => 'Personalization and data';

  @override
  String get personalizationTitle => 'Personalization and data';

  @override
  String get allowAllSubtitle => 'Allow all';

  @override
  String get viewYourDataTitle => 'View your Toldya data';

  @override
  String get viewYourDataSubtitle =>
      'Review and edit your profile information and data associated with your account.';

  @override
  String get proxyTitle => 'Proxy';

  @override
  String get enableHttpProxyTitle => 'Enable HTTP proxy';

  @override
  String get enableHttpProxySubtitle =>
      'Configure an HTTP proxy for network requests (note: this does not apply to the browser).';

  @override
  String get proxyHostTitle => 'Proxy host';

  @override
  String get proxyHostSubtitle => 'Configure your proxy’s hostname.';

  @override
  String get proxyPortTitle => 'Proxy port';

  @override
  String get proxyPortSubtitle => 'Configure your proxy’s port number.';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptySubtitle =>
      'New notifications will appear here.';

  @override
  String votedOnYourPost(int count) {
    return '$count people voted on your post';
  }

  @override
  String get notificationCommentedOnPost => 'commented on your prediction';

  @override
  String get notificationStartedFollowingYou => 'started following you';

  @override
  String get emailVerificationTitle => 'Email verification';

  @override
  String get emailVerifiedTitle => 'Your email address is verified';

  @override
  String get emailVerifiedSubtitle => 'You have your blue tick. Cheers!';

  @override
  String get verifyEmailTitle => 'Verify your email address';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Send a verification link to $email to verify your address.';
  }

  @override
  String get sendLink => 'Send link';

  @override
  String get noPredictorScoreYet => 'No predictor score yet';

  @override
  String get noBettorScoreYet => 'No bettor score yet';

  @override
  String get followersTitle => 'Followers';

  @override
  String noFollowersYet(String username) {
    return '$username has no followers';
  }

  @override
  String get followersWillAppearHere =>
      'When someone follows you, they will appear here.';

  @override
  String get newMessageTitle => 'New message';

  @override
  String get searchPeopleOrGroupsHint => 'Search people or groups';

  @override
  String get googleSignInFailed => 'Google sign-in failed.';

  @override
  String get googleSignInNotConfigured =>
      'Google sign-in is not configured. Please add your app\'s SHA fingerprint in Firebase Console.';

  @override
  String get googleSignInButton => 'Continue with Google';

  @override
  String get adminFilterLive => 'Live';

  @override
  String get adminFilterPending => 'Pending';

  @override
  String get adminFilterApproved => 'Approved';

  @override
  String get adminFilterRejected => 'Rejected';

  @override
  String get adminFilterCompleted => 'Completed';

  @override
  String get adminFilterPendingAiReview => 'In AI review';

  @override
  String get adminFilterRejectedByAi => 'Rejected by AI';

  @override
  String xpProgressLabel(int xp, int max) {
    return '$xp / $max';
  }

  @override
  String xpProgressMaxLabel(int xp) {
    return '$xp (Master)';
  }

  @override
  String get rankRookie => 'Rookie';

  @override
  String get rankPredictor => 'Predictor';

  @override
  String get rankMaster => 'Master';

  @override
  String xpHintToBecomePredictor(int threshold) {
    return 'You become a Predictor at $threshold XP';
  }

  @override
  String xpHintToBecomeMaster(int threshold) {
    return 'You become a Master at $threshold XP';
  }

  @override
  String get xpHintMaxRank => 'You have reached the maximum rank';

  @override
  String get rankProgressTitle => 'Rank progress';

  @override
  String levelLabel(String level) {
    return 'Level $level';
  }

  @override
  String get noBetsYet => 'No bets yet.';

  @override
  String get noBetsYetHint =>
      'Place a bet using the \'Bet Yes\' or \'Bet No\' buttons above.';

  @override
  String get dailyBonusClaimed => 'Daily bonus claimed.';

  @override
  String get copyLink => 'Copy link';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get postTitle => 'Post';

  @override
  String sharedPostDescription(String displayName) {
    return '$displayName shared a post';
  }

  @override
  String sharedPredictionDescription(String displayName) {
    return '$displayName shared a prediction on Toldya.';
  }

  @override
  String get editBioHint => 'Edit your profile to update your bio';

  @override
  String get noBio => 'No bio yet';

  @override
  String get delete => 'Delete';

  @override
  String get editPrediction => 'Edit prediction';

  @override
  String get predictionUpdated => 'Prediction updated';

  @override
  String muteUser(String name) {
    return 'Mute $name';
  }

  @override
  String get muteConversation => 'Mute this conversation';

  @override
  String get viewHiddenReplies => 'View hidden replies';

  @override
  String blockUser(String name) {
    return 'Block $name';
  }

  @override
  String unblockUser(String name) {
    return 'Unblock $name';
  }

  @override
  String get report => 'Report';

  @override
  String get withdrawReport => 'Withdraw report';

  @override
  String get sendForApproval => 'Send for approval';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get dispute => 'Dispute';

  @override
  String get disputed => 'You disputed';

  @override
  String get writeMessageHint => 'Write a message...';

  @override
  String get commentHint => 'Write a comment...';

  @override
  String get searchHintShort => 'Search..';

  @override
  String get directMessagesTitle => 'Direct messages';

  @override
  String get share => 'Share';

  @override
  String get shareImageLink => 'Share image link';

  @override
  String get openInBrowser => 'Open in browser';

  @override
  String get newUpdateAvailable => 'New update available';

  @override
  String get unsupportedVersionMessage =>
      'This version of the app is no longer supported. We apologize for any inconvenience.';

  @override
  String get seeLeaderboard => 'See leaderboard';

  @override
  String profileShareTitle(String name) {
    return '$name is on Toldya';
  }

  @override
  String profileShareDescription(String name) {
    return 'Check out $name\'s profile';
  }

  @override
  String get trendsLocationSubtitle => 'New York';

  @override
  String get trendsLocationHint =>
      'Choose which location appears in your Trending tab to see what\'s trending in a specific place.';

  @override
  String get myBetsTab => 'My bets';

  @override
  String get myVotesTab => 'My votes';

  @override
  String get defaultUserHandle => '@user';

  @override
  String get youAreBlocked => 'You are blocked';

  @override
  String balanceToken(int count) {
    return 'Balance: $count tokens';
  }

  @override
  String dailyBonusClaim(int amount) {
    return 'Claim daily bonus (+$amount tokens)';
  }

  @override
  String get tokenManagement => 'Token management';

  @override
  String get emptyActivePredictions => 'You have no active predictions';

  @override
  String get emptyPendingPredictions => 'You have no pending predictions';

  @override
  String get emptyCompletedPredictions => 'You have no completed predictions';

  @override
  String get emptyRejectedPredictions => 'You have no rejected predictions';

  @override
  String get emptyLockedPredictions => 'You have no locked predictions';

  @override
  String get emptyMyNoVotes => 'You haven\'t voted yet';

  @override
  String get emptyMyNoPosts => 'No posts yet';

  @override
  String get emptyMyNoMedia => 'No posts or media yet';

  @override
  String emptyOtherNoVotes(String name) {
    return '$name hasn\'t voted yet';
  }

  @override
  String emptyOtherNoPosts(String name) {
    return '$name has no posts yet';
  }

  @override
  String emptyOtherNoMedia(String name) {
    return '$name has no posts or media yet';
  }

  @override
  String get filterActive => 'Active';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterRejected => 'Rejected';

  @override
  String get filterLocked => 'Locked';

  @override
  String get addNow => 'Add now';

  @override
  String get willShowHere => 'Will show here';

  @override
  String get topicGeneral => 'General';

  @override
  String get userHandlePlaceholder => '@user';

  @override
  String closingAt(String time) {
    return 'Closes: $time';
  }

  @override
  String yesPercent(int percent) {
    return 'Yes $percent';
  }

  @override
  String noPercent(int percent) {
    return 'No $percent';
  }

  @override
  String get followingCountLabel => 'Following';

  @override
  String get tokenLabel => 'Token';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavSearch => 'Search';

  @override
  String get bottomNavNotifications => 'Notifications';

  @override
  String get bottomNavProfile => 'Profile';

  @override
  String get bottomNavLeaderboard => 'League';

  @override
  String get goToProfile => 'Go to profile';

  @override
  String get muteNotificationsForPost =>
      'Mute notifications for this prediction';

  @override
  String get unmuteNotificationsForPost =>
      'Unmute notifications for this prediction';

  @override
  String get notificationsMuted => 'Notifications muted';

  @override
  String get notificationsUnmuted => 'Notifications unmuted';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Harassment or hate';

  @override
  String get reportReasonMisleading => 'Misleading information';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportReceived => 'Your report has been received';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get betAmountLabel => 'Bet amount';

  @override
  String get approvalPendingStatus => 'Selection pending status';

  @override
  String approvalSelectedForPost(String choice) {
    return 'Selected $choice for post';
  }

  @override
  String get betYesLabel => 'Bet Yes';

  @override
  String get betNoLabel => 'Bet No';

  @override
  String get recentBetsTitle => 'Recent bets';

  @override
  String get conversationInformationTitle => 'Conversation information';

  @override
  String reportUser(String name) {
    return 'Report $name';
  }

  @override
  String get deleteConversationTitle => 'Delete conversation';

  @override
  String get receiveMessageRequestsTitle => 'Receive message requests';

  @override
  String get showReadReceiptsTitle => 'Show read receipts';

  @override
  String get receiveMessageRequestsSubtitle =>
      'You will be able to receive Direct Message requests from anyone, even if you don\'t follow them.';

  @override
  String get showReadReceiptsSubtitle =>
      'When someone sends you a message, people in the conversation will know you\'ve seen it. If you turn off this setting, you won\'t be able to see read receipts from others.';

  @override
  String get pollEnded => 'Poll ended';

  @override
  String get pollEndedIn => 'Poll ended in';

  @override
  String get pollDay => 'Day';

  @override
  String get pollDays => 'Days';

  @override
  String get pollHour => 'hour';

  @override
  String get pollHours => 'Hours';

  @override
  String get pollMin => 'min';

  @override
  String get selectImage => 'Select an image';

  @override
  String get useCameraLabel => 'Use camera';

  @override
  String get useGalleryLabel => 'Use gallery';

  @override
  String get emptyPredictionsDefaultTitle => 'No predictions yet';

  @override
  String get emptyPredictionsDefaultSubtitle =>
      'New predictions will appear here.\nTap the button below to create a prediction.';
}
