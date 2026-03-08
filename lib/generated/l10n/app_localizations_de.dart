// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Toldya';

  @override
  String get login => 'Anmelden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get tagline => 'Teile deine Vorhersagen, sieh wer recht hatte.';

  @override
  String get signInToContinue => 'Anmelden, um fortzufahren';

  @override
  String get followers => 'Follower';

  @override
  String get follower => 'Follower';

  @override
  String get following => 'Folgt';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Einstellungen';

  @override
  String get settingsAndPrivacy => 'Einstellungen und Datenschutz';

  @override
  String get logout => 'Abmelden';

  @override
  String get account => 'Konto';

  @override
  String get privacyAndPolicy => 'Datenschutz und Sicherheit';

  @override
  String get language => 'Sprache';

  @override
  String get followSuccess => 'Gefolgt';

  @override
  String get unfollowSuccess => 'Entfolgt';

  @override
  String get errorGeneric =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get pleaseEnterName => 'Bitte gib deinen Namen ein';

  @override
  String get nameTooLong => 'Der Name darf maximal 27 Zeichen haben';

  @override
  String get pleaseFillForm => 'Bitte fülle das Formular sorgfältig aus';

  @override
  String get passwordMismatch =>
      'Passwort und Bestätigung stimmen nicht überein';

  @override
  String get back => 'Zurück';

  @override
  String get pressBackAgainToExit => 'Zum Beenden erneut zurück tippen';

  @override
  String get signUpNow => 'Jetzt registrieren';

  @override
  String get alreadyHaveAccount => 'Hast du schon ein Konto?';

  @override
  String get signIn => 'Anmelden';

  @override
  String get name => 'Name';

  @override
  String get enterEmail => 'E-Mail eingeben';

  @override
  String get enterPassword => 'Passwort eingeben';

  @override
  String get enterPasswordAgain => 'Passwort wiederholen';

  @override
  String get pleaseEnterEmail => 'Bitte E-Mail-Adresse eingeben';

  @override
  String get pleaseEnterPassword => 'Bitte Passwort eingeben';

  @override
  String get passwordMinLength =>
      'Das Passwort muss mindestens 8 Zeichen haben';

  @override
  String get validEmailRequired => 'Bitte eine gültige E-Mail-Adresse eingeben';

  @override
  String get emailEmpty => 'E-Mail darf nicht leer sein';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get shared => 'Geteilt.';

  @override
  String get postUnderReview =>
      'Dein Beitrag wird geprüft. Er erscheint im Feed nach Freigabe.';

  @override
  String get commentAdded => 'Dein Kommentar wurde hinzugefügt.';

  @override
  String get errorTryAgain =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get loading => 'Laden...';

  @override
  String get endOfResults => 'Ende der Ergebnisse';

  @override
  String get post => 'Beitrag';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get continueAction => 'Weiter';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get disputeRecorded => 'Dein Einspruch wurde gespeichert';

  @override
  String get predictionDeleted => 'Vorhersage gelöscht.';

  @override
  String get errorDeleteFailed =>
      'Beim Löschen ist ein Fehler aufgetreten. Bitte versuche es erneut.';

  @override
  String get userBlocked => 'Nutzer blockiert.';

  @override
  String get userUnblocked => 'Nutzer entblockiert.';

  @override
  String get pleaseSelectBetAmount => 'Bitte wähle einen Wetteinsatz!';

  @override
  String maxBetTokens(String maxVal) {
    return 'Maximaler Einsatz: $maxVal Token';
  }

  @override
  String get betOnOneSideOnly =>
      'Du hast bei dieser Vorhersage bereits auf die andere Seite gewettet. Pro Vorhersage kannst du nur auf eine Seite (Ja oder Nein) wetten.';

  @override
  String get betPlaced => 'Wette platziert.';

  @override
  String get confirmBet => 'Wette bestätigen';

  @override
  String confirmBetMessage(String amount) {
    return 'Möchtest du wirklich $amount Token auf diese Vorhersage setzen?';
  }

  @override
  String get messageSent => 'Gesendet';

  @override
  String get messageSendFailed =>
      'Senden fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get usernameRequired => 'Benutzername darf nicht leer sein';

  @override
  String usernameRules(int min, int max) {
    return 'Benutzername muss $min–$max Zeichen haben; nur Buchstaben, Zahlen und Unterstriche erlaubt.';
  }

  @override
  String get usernameTaken => 'Dieser Benutzername ist vergeben';

  @override
  String get errorCheckFailed => 'Beim Prüfen ist ein Fehler aufgetreten';

  @override
  String get errorSaveFailed => 'Beim Speichern ist ein Fehler aufgetreten';

  @override
  String get nameTooLongProfile => 'Der Name darf maximal 27 Zeichen haben';

  @override
  String get adsComingSoon => 'Werbefunktion demnächst.';

  @override
  String tokensAdded(String amount) {
    return '+$amount Token hinzugefügt!';
  }

  @override
  String get purchaseComingSoon => 'Kauf demnächst verfügbar.';

  @override
  String get searchHint => 'Suchen...';

  @override
  String get trendPredictions => 'Trend-Vorhersagen';

  @override
  String get noPredictionsInCategory => 'Keine Vorhersagen in dieser Kategorie';

  @override
  String get recentSearches => 'Letzte Suchen';

  @override
  String get liveSuggestions => 'Live-Vorschläge';

  @override
  String get noResults => 'Keine Ergebnisse';

  @override
  String get predictions => 'Vorhersagen';

  @override
  String get people => 'Personen';

  @override
  String get user => 'Nutzer';

  @override
  String get usernameLabel => 'Benutzername';

  @override
  String get prediction => 'Vorhersage';

  @override
  String get noPredictionResult => 'Kein Vorhersageergebnis';

  @override
  String get noPersonResult => 'Kein Personen Ergebnis';

  @override
  String get noPredictionOutcome => 'Kein Vorhersageergebnis';

  @override
  String get followingLabel => 'Folgt';

  @override
  String get follow => 'Folgen';

  @override
  String get categoryFlow => 'Feed';

  @override
  String get categoryFavorite => 'Favoriten';

  @override
  String get categoryFollow => 'Folgende';

  @override
  String get categorySports => 'Sport';

  @override
  String get categoryEconomy => 'Wirtschaft';

  @override
  String get categoryEntertainment => 'Unterhaltung';

  @override
  String get categoryPolitics => 'Politik';

  @override
  String get aboutToldya => 'Über Toldya';

  @override
  String get help => 'Hilfe';

  @override
  String get legal => 'Rechtliches';

  @override
  String get developer => 'Entwickler';

  @override
  String get newMessage => 'Neue Nachricht';

  @override
  String get messages => 'Nachrichten';

  @override
  String get predictors => 'Vorhersager';

  @override
  String get bettors => 'Wetter';

  @override
  String get dataPreference => 'Dateneinstellung';

  @override
  String get darkModeAppearance => 'Darstellung dunkel';

  @override
  String get wifiOnly => 'Nur WLAN';

  @override
  String get tokenInsufficient => 'Nicht genug Token';

  @override
  String get closedNoSelection => 'Auswahl nicht möglich (geschlossen)';

  @override
  String get thisTweetUnavailable => 'Dieser Beitrag ist nicht verfügbar';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get challengeLabel => 'Herausforderung: ';

  @override
  String get selectUser => 'Nutzer auswählen';

  @override
  String get challengePickTitle => 'Herausforderung: Nutzer auswählen';

  @override
  String get followingListEmpty =>
      'Du folgst niemandem. Füge zuerst jemanden zu deiner Liste hinzu.';

  @override
  String get followingListLoadingOrEmpty =>
      'Liste wird geladen oder keine Nutzer gefunden.';

  @override
  String get agree => 'Zustimmen';

  @override
  String get disagree => 'Ablehnen';

  @override
  String get voteFailed => 'Abstimmung konnte nicht gesendet werden.';

  @override
  String get comments => 'Kommentare';

  @override
  String get noCommentsYet => 'Noch keine Kommentare. Sei der Erste.';

  @override
  String get predictionDetail => 'Vorhersage-Detail';

  @override
  String get leaderboardTitle => 'Bestenliste';

  @override
  String get weeklyLeague => 'Wochenliga';

  @override
  String get leagueNotCreatedYet =>
      'Die Ligagruppe dieser Woche wurde noch nicht erstellt.';

  @override
  String get leagueWillAppearWhenAssigned =>
      'Du erscheinst hier, sobald die Liga-Zuordnung durchgeführt wurde.';

  @override
  String get leaguePreSeasonTitle => 'Die neue Saison steht vor der Tür! 🏆';

  @override
  String get leaguePreSeasonSubtitle =>
      'Die Gegner werden ermittelt... Sobald die Liga-Zuordnung erfolgt ist, trittst du hier in einer 30er-Gruppe an.';

  @override
  String leagueCountdown(int days, int hours) {
    return '${days}d ${hours}h';
  }

  @override
  String get tokenInsufficientForVote =>
      'Abstimmung nicht möglich wegen unzureichender Token';

  @override
  String get betErrorGeneric => 'Wette konnte nicht platziert werden.';

  @override
  String gmsError(String message) {
    return 'Google Play Services Fehler: $message';
  }

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String errorWithMessage(String message) {
    return 'Fehler: $message';
  }

  @override
  String get changesSaved => 'Änderungen gespeichert';

  @override
  String get resetPasswordSent =>
      'Ein Link zum Zurücksetzen des Passworts wurde an deine E-Mail gesendet.';

  @override
  String get selectProfilePhoto => 'Profilfoto auswählen';

  @override
  String get selectCoverPhoto => 'Titelfoto auswählen';

  @override
  String get appAvatars => 'App-Avatare';

  @override
  String get appCovers => 'App-Cover';

  @override
  String get exampleUsername => 'z.B. nutzer_123';

  @override
  String get bio => 'Biografie';

  @override
  String get location => 'Ort';

  @override
  String get birthDate => 'Geburtsdatum';

  @override
  String get save => 'Speichern';

  @override
  String get sortUserList => 'Benutzerliste sortieren';

  @override
  String get updateNow => 'Jetzt aktualisieren';

  @override
  String get alert => 'Hinweis';

  @override
  String get forIos => 'Für iOS';

  @override
  String get forAndroid => 'Für Android';

  @override
  String get iSayYes => 'dafür';

  @override
  String get iSayNo => 'dagegen';

  @override
  String get votersList => 'Abstimmende';

  @override
  String get noVotesYet => 'Zu diesem Beitrag wurde noch nicht abgestimmt';

  @override
  String get voteListEmptySubtitle =>
      'Wenn jemand abstimmt, wird die Liste hier angezeigt.';

  @override
  String get commentFailed =>
      'Kommentar konnte nicht hinzugefügt werden. Bitte erneut versuchen.';

  @override
  String get loginRequired => 'Bitte melde dich an.';

  @override
  String get betTimeout => 'Zeitüberschreitung. Bitte erneut versuchen.';

  @override
  String get gmsUpdateMessage =>
      'Google Play Services Fehler. Bitte Gerät neu starten oder Google Play Services aktualisieren.';

  @override
  String featureComingSoon(String feature) {
    return '$feature demnächst verfügbar.';
  }

  @override
  String get tokenEarnTitle => 'Token verdienen';

  @override
  String get watchAdTitle => 'Werbung ansehen';

  @override
  String tokenEarnFreeSubtitle(String amount) {
    return '$amount Token gratis';
  }

  @override
  String get watch => 'Ansehen';

  @override
  String get dailyBonusTitle => 'Tagesbonus';

  @override
  String get claim => 'Holen';

  @override
  String get tryAgainTomorrow => 'Morgen erneut versuchen';

  @override
  String get tokenPacksTitle => 'Token-Pakete';

  @override
  String get mostPopular => 'Am beliebtesten';

  @override
  String get bestValue => 'Bestes Preis‑Leistungs‑Verhältnis';

  @override
  String get dataUsageTitle => 'Datennutzung';

  @override
  String get dataSaverHeader => 'Datensparmodus';

  @override
  String get dataSaverTitle => 'Datensparmodus';

  @override
  String get dataSaverSubtitle =>
      'Wenn aktiviert, werden Videos nicht automatisch abgespielt und Bilder in niedrigerer Qualität geladen. Das reduziert den Datenverbrauch auf diesem Gerät.';

  @override
  String get imagesHeader => 'Bilder';

  @override
  String get highQualityImagesTitle => 'Bilder in hoher Qualität';

  @override
  String highQualityImagesSubtitle(String network) {
    return '$network\\n\\nWähle aus, wann Bilder in hoher Qualität geladen werden sollen.';
  }

  @override
  String get videoHeader => 'Video';

  @override
  String get highQualityVideoTitle => 'Video in hoher Qualität';

  @override
  String highQualityVideoSubtitle(String network) {
    return '$network\\n\\nWähle aus, wann die höchste verfügbare Qualität abgespielt werden soll.';
  }

  @override
  String get videoAutoplayTitle => 'Video automatisch abspielen';

  @override
  String videoAutoplaySubtitle(String network) {
    return '$network\\n\\nWähle aus, wann Videos automatisch abgespielt werden sollen.';
  }

  @override
  String get dataSyncHeader => 'Datensynchronisierung';

  @override
  String get syncDataTitle => 'Daten synchronisieren';

  @override
  String get syncIntervalTitle => 'Synchronisierungsintervall';

  @override
  String get daily => 'Täglich';

  @override
  String get syncDataDescription =>
      'Erlaube Toldya, Daten im Hintergrund zu synchronisieren, um dein Erlebnis zu verbessern.';

  @override
  String get mobileDataWifi => 'Mobile Daten & WLAN';

  @override
  String get never => 'Nie';

  @override
  String get dim => 'Gedimmt';

  @override
  String get lightOut => 'Licht aus';

  @override
  String get darkModeTitle => 'Dunkelmodus';

  @override
  String get on => 'Ein';

  @override
  String get off => 'Aus';

  @override
  String get automaticAtSunset => 'Automatisch bei Sonnenuntergang';

  @override
  String get verifiedUserFirst => 'Verifizierte Nutzer zuerst';

  @override
  String get newestUserFirst => 'Neueste Nutzer zuerst';

  @override
  String get oldestUserFirst => 'Älteste Nutzer zuerst';

  @override
  String get maxFollowerFirst => 'Meiste Follower zuerst';

  @override
  String get alphabeticallySort => 'Alphabetisch';

  @override
  String get displayAndSoundTitle => 'Anzeige und Ton';

  @override
  String get mediaHeader => 'Medien';

  @override
  String get mediaPreviewsTitle => 'Medienvorschau';

  @override
  String get displayHeader => 'Anzeige';

  @override
  String get emojiTitle => 'Emoji';

  @override
  String get emojiSubtitle =>
      'Verwende das App-Set statt des Standard-Sets deines Geräts';

  @override
  String get soundHeader => 'Ton';

  @override
  String get soundEffectsTitle => 'Soundeffekte';

  @override
  String get webBrowserHeader => 'Webbrowser';

  @override
  String get useInAppBrowserTitle => 'In‑App‑Browser verwenden';

  @override
  String get useInAppBrowserSubtitle =>
      'Externe Links mit dem In‑App‑Browser öffnen';

  @override
  String get accessibilityTitle => 'Barrierefreiheit';

  @override
  String get screenReaderHeader => 'Screenreader';

  @override
  String get pronounceHashtagTitle => '# als „Hashtag“ aussprechen';

  @override
  String get visionHeader => 'Sehen';

  @override
  String get composeImageDescriptionsTitle => 'Bildbeschreibungen verfassen';

  @override
  String get composeImageDescriptionsSubtitle =>
      'Ermöglicht Beschreibungen für sehbehinderte Nutzer.';

  @override
  String get motionHeader => 'Bewegung';

  @override
  String get reduceMotionTitle => 'Bewegung reduzieren';

  @override
  String get reduceMotionSubtitle =>
      'Begrenze In‑App‑Animationen, einschließlich Live‑Zähler.';

  @override
  String get accountTitle => 'Konto';

  @override
  String get loginHeader => 'Anmeldung';

  @override
  String get emailAddressTitle => 'E‑Mail‑Adresse';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get filtersHeader => 'Filter';

  @override
  String get qualityFilterTitle => 'Qualitätsfilter';

  @override
  String get qualityFilterSubtitle =>
      'Filtere Benachrichtigungen geringerer Qualität. Benachrichtigungen von Personen, denen du folgst, oder Konten, mit denen du kürzlich interagiert hast, werden nicht gefiltert.';

  @override
  String get advancedFilterTitle => 'Erweiterter Filter';

  @override
  String get mutedWordTitle => 'Stummgeschaltete Wörter';

  @override
  String get preferencesHeader => 'Einstellungen';

  @override
  String get unreadBadgeTitle => 'Badge für ungelesene Benachrichtigungen';

  @override
  String get unreadBadgeSubtitle =>
      'Zeige ein Badge mit der Anzahl der wartenden Benachrichtigungen in der App an.';

  @override
  String get pushNotificationsTitle => 'Push‑Benachrichtigungen';

  @override
  String get smsNotificationsTitle => 'SMS‑Benachrichtigungen';

  @override
  String get emailNotificationsTitle => 'E‑Mail‑Benachrichtigungen';

  @override
  String get emailNotificationsSubtitle =>
      'Steuere, wann und wie oft die App dir E‑Mails sendet.';

  @override
  String get contentPreferencesTitle => 'Inhalts­einstellungen';

  @override
  String get exploreHeader => 'Entdecken';

  @override
  String get trendsTitle => 'Trends';

  @override
  String get searchSettingsTitle => 'Sucheinstellungen';

  @override
  String get languagesHeader => 'Sprachen';

  @override
  String get recommendationsTitle => 'Empfehlungen';

  @override
  String get recommendationsSubtitle =>
      'Wähle aus, welche Sprachen empfohlene Beiträge, Personen und Trends enthalten sollen';

  @override
  String get safetyHeader => 'Sicherheit';

  @override
  String get blockedAccountsTitle => 'Blockierte Konten';

  @override
  String get mutedAccountsTitle => 'Stummgeschaltete Konten';

  @override
  String get helpHeader => 'Hilfe';

  @override
  String get helpCenterTitle => 'Hilfezentrum';

  @override
  String get termsOfServiceTitle => 'Nutzungsbedingungen';

  @override
  String get privacyPolicyTitle => 'Datenschutzrichtlinie';

  @override
  String get cookieUseTitle => 'Cookie‑Nutzung';

  @override
  String get legalNoticesTitle => 'Rechtliche Hinweise';

  @override
  String get searchFilterTitle => 'Suchfilter';

  @override
  String get trendsLocationTitle => 'Trend‑Standort';

  @override
  String get emailVerificationSent =>
      'Ein Bestätigungslink wurde an deine E‑Mail gesendet.';

  @override
  String get privacyAndSafetyTitle => 'Datenschutz und Sicherheit';

  @override
  String get privacySharesHeader => 'Beiträge';

  @override
  String get protectPostsTitle => 'Beiträge schützen';

  @override
  String get protectPostsSubtitle =>
      'Nur deine aktuellen Follower und Personen, die du künftig bestätigst, können deine Beiträge sehen.';

  @override
  String get photoTaggingTitle => 'Foto‑Markierungen';

  @override
  String get photoTaggingSubtitle => 'Jeder kann dich markieren';

  @override
  String get liveVideoHeader => 'Live‑Video';

  @override
  String get connectToLiveVideoTitle => 'Mit Live‑Video verbinden';

  @override
  String get connectToLiveVideoSubtitle =>
      'Wenn aktiv, kannst du live gehen und kommentieren; wenn inaktiv, können andere nicht live gehen oder kommentieren.';

  @override
  String get discoverabilityHeader => 'Auffindbarkeit und Kontakte';

  @override
  String get discoverabilityTitle => 'Auffindbarkeit und Kontakte';

  @override
  String get discoverabilitySubtitle =>
      'Erfahre mehr darüber, wie diese Daten genutzt werden, um dich mit anderen zu verbinden.';

  @override
  String get securityHeader => 'Sicherheit';

  @override
  String get showSensitiveMediaTitle =>
      'Medien anzeigen, die sensible Inhalte enthalten könnten';

  @override
  String get markSensitiveMediaTitle =>
      'Von dir geteilte Medien als sensibel markieren';

  @override
  String get mutedWordsTitle => 'Stummgeschaltete Wörter';

  @override
  String get locationHeader => 'Standort';

  @override
  String get preciseLocationTitle => 'Genauer Standort';

  @override
  String get preciseLocationSubtitle =>
      'Aus\\n\\n\\nWenn aktiv, sammelt, speichert und nutzt Toldya den genauen Standort deines Geräts (z. B. GPS). Das verbessert dein Erlebnis, z. B. durch lokalere Inhalte, Werbung und Empfehlungen.';

  @override
  String get personalizationHeader => 'Personalisierung und Daten';

  @override
  String get personalizationTitle => 'Personalisierung und Daten';

  @override
  String get allowAllSubtitle => 'Alles erlauben';

  @override
  String get viewYourDataTitle => 'Deine Toldya‑Daten ansehen';

  @override
  String get viewYourDataSubtitle =>
      'Profilinformationen und mit deinem Konto verknüpfte Daten ansehen und bearbeiten.';

  @override
  String get proxyTitle => 'Proxy';

  @override
  String get enableHttpProxyTitle => 'HTTP‑Proxy aktivieren';

  @override
  String get enableHttpProxySubtitle =>
      'HTTP‑Proxy für Netzwerkanfragen konfigurieren (Hinweis: gilt nicht für den Browser).';

  @override
  String get proxyHostTitle => 'Proxy‑Host';

  @override
  String get proxyHostSubtitle => 'Hostname des Proxys konfigurieren.';

  @override
  String get proxyPortTitle => 'Proxy‑Port';

  @override
  String get proxyPortSubtitle => 'Portnummer des Proxys konfigurieren.';

  @override
  String get notificationsEmptyTitle => 'Noch keine Benachrichtigungen';

  @override
  String get notificationsEmptySubtitle =>
      'Neue Benachrichtigungen erscheinen hier.';

  @override
  String votedOnYourPost(int count) {
    return '$count Personen haben für deinen Beitrag abgestimmt';
  }

  @override
  String get notificationCommentedOnPost => 'hat deine Vorhersage kommentiert';

  @override
  String get notificationStartedFollowingYou => 'folgt dir jetzt';

  @override
  String get emailVerificationTitle => 'E‑Mail‑Bestätigung';

  @override
  String get emailVerifiedTitle => 'Deine E‑Mail ist bestätigt';

  @override
  String get emailVerifiedSubtitle =>
      'Du hast deinen blauen Haken. Glückwunsch!';

  @override
  String get verifyEmailTitle => 'Bestätige deine E‑Mail';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Sende einen Bestätigungslink an $email, um die Adresse zu bestätigen.';
  }

  @override
  String get sendLink => 'Link senden';

  @override
  String get noPredictorScoreYet => 'Noch kein Vorhersage‑Score';

  @override
  String get noBettorScoreYet => 'Noch kein Wett‑Score';

  @override
  String get followersTitle => 'Follower';

  @override
  String noFollowersYet(String username) {
    return '$username hat keine Follower';
  }

  @override
  String get followersWillAppearHere =>
      'Wenn dir jemand folgt, erscheint er hier.';

  @override
  String get newMessageTitle => 'Neue Nachricht';

  @override
  String get searchPeopleOrGroupsHint => 'Personen oder Gruppen suchen';

  @override
  String get googleSignInFailed => 'Google‑Anmeldung fehlgeschlagen.';

  @override
  String get googleSignInNotConfigured =>
      'Google‑Anmeldung ist nicht konfiguriert. Bitte füge den SHA‑Fingerabdruck deiner App in der Firebase‑Konsole hinzu.';

  @override
  String get googleSignInButton => 'Mit Google fortfahren';

  @override
  String get adminFilterLive => 'Laufend';

  @override
  String get adminFilterPending => 'Ausstehend';

  @override
  String get adminFilterApproved => 'Genehmigt';

  @override
  String get adminFilterRejected => 'Abgelehnt';

  @override
  String get adminFilterCompleted => 'Abgeschlossen';

  @override
  String get adminFilterPendingAiReview => 'In KI-Prüfung';

  @override
  String get adminFilterRejectedByAi => 'Von KI abgelehnt';

  @override
  String xpProgressLabel(int xp, int max) {
    return '$xp / $max';
  }

  @override
  String xpProgressMaxLabel(int xp) {
    return '$xp (Meister)';
  }

  @override
  String get rankRookie => 'Einsteiger';

  @override
  String get rankPredictor => 'Tippgeber';

  @override
  String get rankMaster => 'Meister';

  @override
  String xpHintToBecomePredictor(int threshold) {
    return 'Du wirst Tippgeber bei $threshold XP';
  }

  @override
  String xpHintToBecomeMaster(int threshold) {
    return 'Du wirst Meister bei $threshold XP';
  }

  @override
  String get xpHintMaxRank => 'Du hast den höchsten Rang erreicht';

  @override
  String get rankProgressTitle => 'Rangfortschritt';

  @override
  String levelLabel(String level) {
    return 'Stufe $level';
  }

  @override
  String get noBetsYet => 'Noch keine Wetten.';

  @override
  String get noBetsYetHint =>
      'Platziere eine Wette über die Schaltflächen \"Mit Ja wetten\" oder \"Mit Nein wetten\" oben.';

  @override
  String get dailyBonusClaimed => 'Täglicher Bonus eingelöst.';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String get postTitle => 'Beitrag';

  @override
  String sharedPostDescription(String displayName) {
    return '$displayName hat einen Beitrag geteilt';
  }

  @override
  String sharedPredictionDescription(String displayName) {
    return '$displayName hat eine Vorhersage auf Toldya geteilt.';
  }

  @override
  String get editBioHint =>
      'Bearbeite dein Profil, um deine Biografie zu aktualisieren';

  @override
  String get noBio => 'Noch keine Biografie';

  @override
  String get delete => 'Löschen';

  @override
  String get editPrediction => 'Vorhersage bearbeiten';

  @override
  String get predictionUpdated => 'Vorhersage aktualisiert';

  @override
  String muteUser(String name) {
    return '$name stummschalten';
  }

  @override
  String get muteConversation => 'Diese Unterhaltung stummschalten';

  @override
  String get viewHiddenReplies => 'Ausgeblendete Antworten anzeigen';

  @override
  String blockUser(String name) {
    return '$name blockieren';
  }

  @override
  String unblockUser(String name) {
    return '$name entblockieren';
  }

  @override
  String get report => 'Melden';

  @override
  String get withdrawReport => 'Meldung zurückziehen';

  @override
  String get sendForApproval => 'Zur Genehmigung senden';

  @override
  String get approve => 'Genehmigen';

  @override
  String get reject => 'Ablehnen';

  @override
  String get dispute => 'Einspruch';

  @override
  String get disputed => 'Du hast Einspruch eingelegt';

  @override
  String get writeMessageHint => 'Nachricht schreiben...';

  @override
  String get commentHint => 'Kommentar schreiben...';

  @override
  String get searchHintShort => 'Suchen..';

  @override
  String get directMessagesTitle => 'Direktnachrichten';

  @override
  String get share => 'Teilen';

  @override
  String get shareImageLink => 'Bildlink teilen';

  @override
  String get openInBrowser => 'Im Browser öffnen';

  @override
  String get newUpdateAvailable => 'Neues Update verfügbar';

  @override
  String get unsupportedVersionMessage =>
      'Diese Version der App wird nicht mehr unterstützt. Wir entschuldigen uns für die Unannehmlichkeiten.';

  @override
  String get seeLeaderboard => 'Bestenliste anzeigen';

  @override
  String profileShareTitle(String name) {
    return '$name ist auf Toldya';
  }

  @override
  String profileShareDescription(String name) {
    return 'Sieh dir ${name}s Profil an';
  }

  @override
  String get trendsLocationSubtitle => 'New York';

  @override
  String get trendsLocationHint =>
      'Wähle, welcher Ort in deinem Trend-Tab angezeigt wird, um zu sehen, was an einem Ort trendet.';

  @override
  String get myBetsTab => 'Meine Wetten';

  @override
  String get myVotesTab => 'Meine Abstimmungen';

  @override
  String get defaultUserHandle => '@Benutzer';

  @override
  String get youAreBlocked => 'Du bist blockiert';

  @override
  String balanceToken(int count) {
    return 'Kontostand: $count Token';
  }

  @override
  String dailyBonusClaim(int amount) {
    return 'Täglichen Bonus holen (+$amount Token)';
  }

  @override
  String get tokenManagement => 'Token-Verwaltung';

  @override
  String get emptyActivePredictions => 'Du hast keine aktiven Vorhersagen';

  @override
  String get emptyPendingPredictions =>
      'Du hast keine ausstehenden Vorhersagen';

  @override
  String get emptyCompletedPredictions =>
      'Du hast keine abgeschlossenen Vorhersagen';

  @override
  String get emptyRejectedPredictions =>
      'Du hast keine abgelehnten Vorhersagen';

  @override
  String get emptyLockedPredictions => 'Du hast keine gesperrten Vorhersagen';

  @override
  String get emptyMyNoVotes => 'Du hast noch nicht abgestimmt';

  @override
  String get emptyMyNoPosts => 'Noch keine Beiträge';

  @override
  String get emptyMyNoMedia => 'Noch keine Beiträge oder Medien';

  @override
  String emptyOtherNoVotes(String name) {
    return '$name hat noch nicht abgestimmt';
  }

  @override
  String emptyOtherNoPosts(String name) {
    return '$name hat noch keine Beiträge';
  }

  @override
  String emptyOtherNoMedia(String name) {
    return '$name hat noch keine Beiträge oder Medien';
  }

  @override
  String get filterActive => 'Aktiv';

  @override
  String get filterPending => 'Ausstehend';

  @override
  String get filterCompleted => 'Abgeschlossen';

  @override
  String get filterRejected => 'Abgelehnt';

  @override
  String get filterLocked => 'Gesperrt';

  @override
  String get addNow => 'Jetzt hinzufügen';

  @override
  String get willShowHere => 'Werden hier angezeigt';

  @override
  String get topicGeneral => 'Allgemein';

  @override
  String get userHandlePlaceholder => '@Benutzer';

  @override
  String closingAt(String time) {
    return 'Schließt: $time';
  }

  @override
  String yesPercent(int percent) {
    return 'Ja $percent';
  }

  @override
  String noPercent(int percent) {
    return 'Nein $percent';
  }

  @override
  String get followingCountLabel => 'Folgende';

  @override
  String get tokenLabel => 'Token';

  @override
  String get bottomNavHome => 'Start';

  @override
  String get bottomNavSearch => 'Suche';

  @override
  String get bottomNavNotifications => 'Benachrichtigungen';

  @override
  String get bottomNavProfile => 'Profil';

  @override
  String get bottomNavLeaderboard => 'Liga';

  @override
  String get goToProfile => 'Zum Profil';

  @override
  String get muteNotificationsForPost =>
      'Benachrichtigungen für diese Vorhersage stummschalten';

  @override
  String get unmuteNotificationsForPost =>
      'Benachrichtigungen für diese Vorhersage aktivieren';

  @override
  String get notificationsMuted => 'Benachrichtigungen stummgeschaltet';

  @override
  String get notificationsUnmuted => 'Benachrichtigungen aktiviert';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Belästigung oder Hass';

  @override
  String get reportReasonMisleading => 'Irreführende Informationen';

  @override
  String get reportReasonOther => 'Sonstiges';

  @override
  String get reportReceived => 'Deine Meldung wurde erhalten';

  @override
  String get unfollow => 'Entfolgen';

  @override
  String get betAmountLabel => 'Wetteinsatz';

  @override
  String get approvalPendingStatus => 'Auswahl ausstehend';

  @override
  String approvalSelectedForPost(String choice) {
    return 'Für Beitrag $choice ausgewählt';
  }

  @override
  String get betYesLabel => 'Mit Ja wetten';

  @override
  String get betNoLabel => 'Mit Nein wetten';

  @override
  String get recentBetsTitle => 'Letzte Wetten';

  @override
  String get conversationInformationTitle => 'Unterhaltungsinformationen';

  @override
  String reportUser(String name) {
    return '$name melden';
  }

  @override
  String get deleteConversationTitle => 'Unterhaltung löschen';

  @override
  String get receiveMessageRequestsTitle => 'Nachrichtenanfragen erhalten';

  @override
  String get showReadReceiptsTitle => 'Gelesen-Bestätigungen anzeigen';

  @override
  String get receiveMessageRequestsSubtitle =>
      'Du kannst Direktnachrichten-Anfragen von allen erhalten, auch wenn du ihnen nicht folgst.';

  @override
  String get showReadReceiptsSubtitle =>
      'Wenn dir jemand eine Nachricht sendet, sehen andere in der Unterhaltung, dass du sie gelesen hast. Wenn du diese Einstellung deaktivierst, siehst du auch keine Gelesen-Bestätigungen von anderen.';

  @override
  String get pollEnded => 'Umfrage beendet';

  @override
  String get pollEndedIn => 'Umfrage endet in';

  @override
  String get pollDay => 'Tag';

  @override
  String get pollDays => 'Tage';

  @override
  String get pollHour => 'Stunde';

  @override
  String get pollHours => 'Stunden';

  @override
  String get pollMin => 'Min';

  @override
  String get selectImage => 'Ein Bild auswählen';

  @override
  String get useCameraLabel => 'Kamera verwenden';

  @override
  String get useGalleryLabel => 'Galerie verwenden';

  @override
  String get emptyPredictionsDefaultTitle => 'Noch keine Vorhersagen';

  @override
  String get emptyPredictionsDefaultSubtitle =>
      'Neue Vorhersagen erscheinen hier.\nTippe auf den Button unten, um eine Vorhersage zu erstellen.';
}
