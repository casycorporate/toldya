import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/enum.dart';
import 'package:toldya/helper/network_utils.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/services/notification_service.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as Path;
import 'appState.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:cloud_functions/cloud_functions.dart';

class AuthState extends AppState {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  bool isSignInWithGoogle = false;
  User? user;
  String userId = '';
  Future<User?>? _getCurrentUserInFlight;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  dabase.Query? _profileQuery;
  dabase.DatabaseReference? _mutedPostIdsRef;
  StreamSubscription<DatabaseEvent>? _profileOnValueSub;
  StreamSubscription<DatabaseEvent>? _mutedPostIdsOnValueSub;
  List<UserModel>? _profileUserModelList;
  UserModel? _userModel;
  bool? _isAdminCached;
  List<String> _mutedPostIds = [];

  /// Hangi profil sayfası için istek açıldı; sayfa kapanınca null yapılır, böylece geciken async cevap listeye eklenmez.
  String? _pendingProfileRequestId;
  String? _profileError;

  String? get profileError => _profileError;

  void clearProfileError() {
    _profileError = null;
    notifyListeners();
  }

  UserModel? get userModel => _userModel;

  /// Yönetici mi? Tek kaynak: RTDB `profile/{uid}/isAdmin` (true | 1 | "true").
  /// Normal kullanıcı / admin ayrımı rütbe (XP) ile karıştırılmaz; rütbe ayrı alan.
  Future<bool> isAdminUser({bool forceRefresh = false}) async {
    if (!forceRefresh && _isAdminCached != null) return _isAdminCached!;
    final current = FirebaseAuth.instance.currentUser;
    final uid = current?.uid;
    if (uid == null || uid.isEmpty) {
      _isAdminCached = false;
      return false;
    }
    try {
      final snap =
          await FirebaseDatabase.instance.ref('profile/$uid/isAdmin').get();
      final val = snap.value;
      final isAdmin = val == true || val == 1 || val == 'true';
      _isAdminCached = isAdmin;
      return isAdmin;
    } catch (_) {
      _isAdminCached = false;
      return false;
    }
  }

  UserModel? get profileUserModel {
    if (_profileUserModelList != null && _profileUserModelList!.length > 0) {
      return _profileUserModelList!.last;
    } else {
      return null;
    }
  }

  void removeLastUser() {
    _profileUserModelList?.removeLast();
  }

  /// Profil sayfası kapanırken çağrılır (AppBar geri veya sistem geri). Listede son kullanıcı bu sayfaya aitse kaldırılır (async race önlenir).
  /// profileId null/boş = "kendi profilim" sayfası kapanıyor; dolu = başka kullanıcı profil sayfası. Liste boş kalırsa ensureProfileIsCurrentUser() ile ana ekran siyah kalmaz.
  /// State-holding screens: back (AppBar or system) should run this cleanup once, then Navigator.pop.
  void profilePageClosing(String? profileId) {
    _pendingProfileRequestId = null;
    final bool isMyProfile = profileId == null || profileId.isEmpty;
    if (_profileUserModelList != null && _profileUserModelList!.isNotEmpty) {
      final String? lastUserId = _profileUserModelList!.last.userId;
      final bool removeLast = isMyProfile
          ? (lastUserId == _userModel?.userId)
          : (lastUserId == profileId);
      if (removeLast) {
        _profileUserModelList!.removeLast();
      }
    }
    if (_profileUserModelList == null || _profileUserModelList!.isEmpty) {
      debugPrint(
          '[Profile] list empty after close, calling ensureProfileIsCurrentUser _userModel=${_userModel != null}');
      if (_userModel != null && userId.isNotEmpty) {
        ensureProfileIsCurrentUser();
      } else {
        notifyListeners();
      }
    } else if (isMyProfile &&
        _userModel != null &&
        _profileUserModelList!.last.userId != _userModel!.userId) {
      // "Kendi profilim" kapatıldı; geri dönünce Profil sekmesi kendi kullanıcıyı göstermeli.
      ensureProfileIsCurrentUser();
    } else {
      notifyListeners();
    }
  }

  /// "Kendi profilim" sekmesi görünürken profileUserModel başkasıysa (örn. alt bardan dönüldü), listeyi giriş yapan kullanıcıya çevirir.
  void ensureProfileIsCurrentUser() {
    // Startup guard: don't mutate profile stack until we actually have a signed-in user.
    if (_userModel == null || userId.isEmpty) {
      return;
    }
    if (_profileUserModelList == null ||
        _profileUserModelList!.isEmpty ||
        _profileUserModelList!.last.userId != userId) {
      _profileUserModelList = [_userModel!];
      notifyListeners();
    }
  }

  /// Logout from device
  void logoutCallback() {
    unawaited(_cancelProfileDatabaseListeners());
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    _userModel = null;
    user = null;
    _profileUserModelList = null;
    if (isSignInWithGoogle) {
      _googleSignIn.signOut();
      logEvent('google_logout');
    }
    _firebaseAuth.signOut();
    notifyListeners();
  }

  /// Alter select auth method, login and sign up page
  void openSignUpPage() {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    notifyListeners();
  }

  /// RTDB profil + mutedPostIds dinleyicileri. Abonelikler saklanır; hot restart / çıkışta iptal edilir.
  void databaseInit() {
    unawaited(_databaseInitAsync());
  }

  Future<void> _cancelProfileDatabaseListeners() async {
    Future<void> safeCancel(StreamSubscription<DatabaseEvent>? sub) async {
      if (sub == null) return;
      try {
        await sub.cancel();
      } on MissingPluginException catch (_) {
        // Hot restart veya plugin yeniden bağlanırken platform kanalı yok olabilir.
      } catch (_) {}
    }

    await safeCancel(_profileOnValueSub);
    await safeCancel(_mutedPostIdsOnValueSub);
    _profileOnValueSub = null;
    _mutedPostIdsOnValueSub = null;
    _profileQuery = null;
    _mutedPostIdsRef = null;
  }

  Future<void> _databaseInitAsync() async {
    try {
      final uid = user?.uid;
      if (uid == null || uid.isEmpty) return;

      await _cancelProfileDatabaseListeners();
      if (user == null || user!.uid != uid) return;

      _profileQuery = kDatabase.child("profile").child(uid);
      _profileOnValueSub = _profileQuery!.onValue.listen(_onProfileChanged);
      _mutedPostIdsRef =
          kDatabase.child("profile").child(uid).child("mutedPostIds");
      _mutedPostIdsOnValueSub = _mutedPostIdsRef!.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final list = event.snapshot.value;
          if (list is List) {
            _mutedPostIds = list.map((e) => e.toString()).toList();
          } else {
            _mutedPostIds = [];
          }
        } else {
          _mutedPostIds = [];
        }
        notifyListeners();
      });
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
    }
  }

  @override
  void dispose() {
    unawaited(_cancelProfileDatabaseListeners());
    super.dispose();
  }

  bool isPostMuted(String postId) {
    if (postId.isEmpty) return false;
    return _mutedPostIds.contains(postId);
  }

  Future<void> addMutedPostId(String postId) async {
    if (postId.isEmpty || _mutedPostIds.contains(postId)) return;
    _mutedPostIds = List.from(_mutedPostIds)..add(postId);
    await _mutedPostIdsRef?.set(_mutedPostIds);
    notifyListeners();
  }

  Future<void> removeMutedPostId(String postId) async {
    if (postId.isEmpty) return;
    _mutedPostIds = List.from(_mutedPostIds)..remove(postId);
    await _mutedPostIdsRef?.set(_mutedPostIds);
    notifyListeners();
  }

  /// Verify user's credentials for login
  Future<String?> signIn(String email, String password,
      {GlobalKey<ScaffoldState>? scaffoldKey}) async {
    try {
      loading = true;
      var result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      authStatus = AuthStatus.LOGGED_IN;
      // if(userModel.role==null){
      //   userModel.role=AppIcon.defaultRole;
      //   createUser(userModel);
      // }
      userId = user?.uid ?? '';
      if (user != null) {
        await ensureFirebaseAuthProfileInRtdb(user!);
      }
      loading = false;
      return user?.uid;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'signIn');
      kAnalytics.logLogin(loginMethod: 'email_login');
      showLocalizedFirebaseAuthSnackBar(scaffoldKey, error);
      // logoutCallback();
      return null;
    }
  }

  /// Create user from `google login`
  /// If user is new then it create a new user
  /// If user is old then it just `authenticate` user and return firebase user data
  Future<User> handleGoogleSignIn() async {
    try {
      /// Record log in firebase kAnalytics about Google login
      kAnalytics.logLogin(loginMethod: 'google_login');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google login cancelled by user');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      user = (await _firebaseAuth.signInWithCredential(credential)).user;
      authStatus = AuthStatus.LOGGED_IN;
      userId = user?.uid ?? '';
      isSignInWithGoogle = true;
      if (user != null) {
        await ensureGoogleProfileInRtdb(user!);
      }
      notifyListeners();
      return user!;
    } on PlatformException catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      throw error;
    } on Exception catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      rethrow;
    } catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      rethrow;
    }
  }

  /// RTDB'de kayıtlı profil var mı? (Lig/hayalet düğümlerinden ayırt etmek için —
  /// `functions/leagues.js` ile uyumlu: createdAt / email / displayName.)
  bool _rtdbProfileDataLooksRegistered(dynamic raw) {
    if (raw == null) return false;
    if (raw is! Map) return false;
    final m = Map<String, dynamic>.from(raw as Map);
    bool ne(String key) {
      final v = m[key];
      if (v == null) return false;
      return v.toString().trim().isNotEmpty;
    }

    return ne('createdAt') || ne('email') || ne('displayName');
  }

  String? _readExistingFcmToken(dynamic raw) {
    if (raw is Map && raw['fcmToken'] != null) {
      final s = raw['fcmToken'].toString();
      return s.trim().isEmpty ? null : s;
    }
    return null;
  }

  /// Google girişinden sonra RTDB profili yoksa veya sadece `fcmToken` vb. hayalet ise tam profil yazar.
  /// Auth kullanıcısı eski olsa bile veritabanı silindiyse yeniden bootstrap olur.
  Future<void> ensureGoogleProfileInRtdb(User user) async {
    final creationDiff =
        DateTime.now().difference(user.metadata.creationTime ?? DateTime.now());
    final isBrandNewAuth = creationDiff < const Duration(seconds: 15);

    final snap = await kDatabase.child('profile').child(user.uid).once();
    final raw = snap.snapshot.value;
    final needsBootstrap = !_rtdbProfileDataLooksRegistered(raw);

    if (!needsBootstrap) {
      if (!isBrandNewAuth) {
        cprint('Last login at: ${user.metadata.lastSignInTime}');
      }
      return;
    }

    final model = UserModel(
      bio: 'Edit profile to update bio',
      dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
          .toString(),
      location: 'Somewhere in universe',
      profilePic: user.photoURL,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      key: user.uid,
      userId: user.uid,
      contact: user.phoneNumber,
      isVerified: false,
      pegCount: AppIcon.pegCount,
      stashCount: 0,
      xp: 0,
      rank: AppIcon.defaultRank,
      predictorScore: 0,
      role: Role.defaultRole,
      fcmToken: _readExistingFcmToken(raw),
    );

    if (isBrandNewAuth) {
      createUser(model, newUser: true);
    } else {
      model.userName = getUserName(id: user.uid, name: model.displayName ?? '');
      model.createdAt = DateTime.now().toUtc().toString();
      createUser(model, newUser: false);
    }
  }

  /// Firebase Auth'ta var olan ama RTDB `profile/{uid}` kaydı silinmiş
  /// kullanıcıları tekrar kullanılabilir hale getirir. Özellikle eski
  /// email/password hesapları aynı e-posta ile tekrar giriş yaptığında Home
  /// ekranının boş profil yüzünden kırılmasını önler.
  Future<void> ensureFirebaseAuthProfileInRtdb(User user) async {
    final snap = await kDatabase.child('profile').child(user.uid).once();
    final raw = snap.snapshot.value;
    if (_rtdbProfileDataLooksRegistered(raw)) return;

    final email = user.email ?? '';
    final fallbackName = email.contains('@')
        ? email.split('@').first
        : (user.displayName ?? 'Toldya User');
    final displayName = (user.displayName ?? '').trim().isNotEmpty
        ? user.displayName!.trim()
        : fallbackName;

    final model = UserModel(
      bio: 'Edit profile to update bio',
      dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
          .toString(),
      location: 'Somewhere in universe',
      profilePic: user.photoURL ?? DefaultProfilePics.assetForUser(user.uid),
      displayName: displayName,
      email: email,
      key: user.uid,
      userId: user.uid,
      contact: user.phoneNumber,
      isVerified: user.emailVerified,
      pegCount: AppIcon.pegCount,
      stashCount: 0,
      xp: 0,
      rank: AppIcon.defaultRank,
      predictorScore: 0,
      role: Role.defaultRole,
      fcmToken: _readExistingFcmToken(raw),
    );
    model.userName = getUserName(id: user.uid, name: model.displayName ?? '');
    model.createdAt = DateTime.now().toUtc().toString();
    createUser(model, newUser: false);
  }

  /// Create user profile from Apple sign-in.
  Future<void> createUserFromAppleSignIn(
    User user,
    AuthorizationCredentialAppleID appleCredential,
  ) async {
    final displayName = <String?>[
      appleCredential.givenName,
      appleCredential.familyName,
    ].whereType<String>().where((e) => e.trim().isNotEmpty).join(' ').trim();

    final userEmail = appleCredential.email ?? user.email ?? '';

    var diff =
        DateTime.now().difference(user.metadata.creationTime ?? DateTime.now());
    if (diff < const Duration(seconds: 15)) {
      // Ensure firebase profile fields are populated for later use.
      if (displayName.isNotEmpty) {
        await user.updateProfile(displayName: displayName);
      }

      final model = UserModel(
        bio: 'Edit profile to update bio',
        dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
            .toString(),
        location: 'Somewhere in universe',
        profilePic: null,
        displayName:
            displayName.isNotEmpty ? displayName : (user.displayName ?? ''),
        email: userEmail,
        key: user.uid,
        userId: user.uid,
        contact: null,
        isVerified: false,
        pegCount: AppIcon.pegCount,
        stashCount: 0,
        xp: 0,
        rank: AppIcon.defaultRank,
        predictorScore: 0,
        role: Role.defaultRole,
      );
      createUser(model, newUser: true);
      kAnalytics.logSignUp(signUpMethod: 'apple_sign_up');
    } else {
      final snap = await kDatabase.child('profile').child(user.uid).once();
      final raw = snap.snapshot.value;
      if (_rtdbProfileDataLooksRegistered(raw)) {
        cprint('Last login at: ${user.metadata.lastSignInTime}',
            event: 'apple_login');
        return;
      }

      final restored = UserModel(
        bio: 'Edit profile to update bio',
        dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
            .toString(),
        location: 'Somewhere in universe',
        profilePic: null,
        displayName:
            displayName.isNotEmpty ? displayName : (user.displayName ?? ''),
        email: userEmail,
        key: user.uid,
        userId: user.uid,
        contact: null,
        isVerified: false,
        pegCount: AppIcon.pegCount,
        stashCount: 0,
        xp: 0,
        rank: AppIcon.defaultRank,
        predictorScore: 0,
        role: Role.defaultRole,
        fcmToken: _readExistingFcmToken(raw),
      );
      restored.userName =
          getUserName(id: user.uid, name: restored.displayName ?? '');
      restored.createdAt = DateTime.now().toUtc().toString();
      createUser(restored, newUser: false);
      cprint('Restored Apple user RTDB profile after empty/partial snapshot',
          event: 'apple_login');
    }
  }

  /// Create user from `Apple sign-in`.
  Future<User> handleAppleSignIn() async {
    try {
      kAnalytics.logLogin(loginMethod: 'apple_login');

      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (appleCredential.identityToken == null) {
        throw Exception('Apple identityToken is null');
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      user = (await _firebaseAuth.signInWithCredential(oauthCredential)).user;
      authStatus = AuthStatus.LOGGED_IN;
      userId = user?.uid ?? '';

      if (user != null) {
        await createUserFromAppleSignIn(user!, appleCredential);
      }

      notifyListeners();
      return user!;
    } on PlatformException catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleAppleSignIn');
      rethrow;
    } catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleAppleSignIn');
      rethrow;
    }
  }

  /// Create new user's profile in db
  Future<String?> signUp(UserModel userModel,
      {GlobalKey<ScaffoldState>? scaffoldKey, String? password}) async {
    try {
      loading = true;
      var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email ?? '',
        password: password ?? '',
      );
      user = result.user!;
      authStatus = AuthStatus.LOGGED_IN;
      kAnalytics.logSignUp(signUpMethod: 'register');
      result.user!.updateProfile(
          displayName: userModel.displayName, photoURL: userModel.profilePic);

      _userModel = userModel;
      _userModel!.key = user!.uid;
      _userModel!.userId = user!.uid;
      createUser(_userModel!, newUser: true);
      return user!.uid;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'signUp');
      showLocalizedFirebaseAuthSnackBar(scaffoldKey, error);
      return null;
    }
  }

  /// Tahmin katılımı sonrası sadece bakiye alanlarını günceller (backend zaten DB'yi güncelledi).
  void updateBalanceFromStake(int newPegCount, int newStashBalance) {
    if (_userModel != null) {
      _userModel!.pegCount = newPegCount;
      _userModel!.stashCount = newStashBalance;
      notifyListeners();
    }
  }

  /// Optimistic UI & rollback: bakiye alanlarını doğrudan günceller (submitStake anında veya geri alımda kullanılır).
  void setBalanceOptimistic(int pegCount, int stashCount) {
    if (_userModel != null) {
      _userModel!.pegCount = pegCount;
      _userModel!.stashCount = stashCount;
      notifyListeners();
    }
  }

  /// Bugün günlük bonus alındı mı?
  bool get canClaimDailyBonus {
    final at = _userModel?.lastDailyClaimAt;
    if (at == null || at.isEmpty) return true;
    final last = DateTime.tryParse(at);
    if (last == null) return true;
    final now = DateTime.now();
    return now.year != last.year ||
        now.month != last.month ||
        now.day != last.day;
  }

  /// Günlük bonusu alır (Callable). Başarıda bakiye ve lastDailyClaimAt güncellenir.
  /// [context] is used for localized fallback message when server does not return one.
  Future<String?> claimDailyBonus(BuildContext context) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable("claimDailyBonus")
          .call<Map<dynamic, dynamic>>({});
      final data = result.data;
      if (data == null || data["ok"] != true) return null;
      if (_userModel != null) {
        _userModel!.pegCount =
            data["newBalance"] as int? ?? _userModel!.pegCount;
        _userModel!.lastDailyClaimAt = DateTime.now().toUtc().toIso8601String();
        notifyListeners();
      }
      return data["message"] as String? ??
          AppLocalizations.of(context)!.dailyBonusClaimed;
    } on FirebaseFunctionsException catch (e) {
      return e.message;
    } catch (_) {
      return null;
    }
  }

  /// `Create` and `Update` user
  /// IF `newUser` is true new user is created
  /// Else existing user will update with new values
  createUser(UserModel user, {bool newUser = false}) {
    final normalizedUserId = (user.userId ?? '').trim();
    if (normalizedUserId.isEmpty) {
      cprint('createUser blocked: empty userId', errorIn: 'createUser');
      return;
    }
    user.userId = normalizedUserId;
    if (newUser) {
      user.userName =
          getUserName(id: user.userId ?? '', name: user.displayName ?? '');
      kAnalytics.logEvent(name: 'create_newUser');
      user.createdAt = DateTime.now().toUtc().toString();
    }
    // Important:
    // `profile/{uid}` altında `isAdmin` gibi alanlar `UserModel` içinde olmayabilir.
    // RTDB'de `set(...)` tüm child'ları overwrite ettiği için bu alanlar silinip
    // admin flag yanlışlıkla `false`'a düşebiliyor. Bu yüzden merge/update yapıyoruz.
    kDatabase.child('profile').child(normalizedUserId).update(user.toJson());
    _userModel = user;
    if (_profileUserModelList != null) {
      _profileUserModelList!.last = _userModel!;
    }
    loading = false;
  }

  /// Fetch current user profile
  Future<User?> getCurrentUser() async {
    // Avoid duplicate calls during startup/rebuilds.
    final existing = _getCurrentUserInFlight;
    if (existing != null) return existing;

    final fut = () async {
      try {
        loading = true;
        logEvent('get_currentUSer');
        user = _firebaseAuth.currentUser;
        if (user != null) {
          authStatus = AuthStatus.LOGGED_IN;
          userId = user!.uid;
          await ensureFirebaseAuthProfileInRtdb(user!);
          getProfileUser();
        } else {
          authStatus = AuthStatus.NOT_LOGGED_IN;
        }
        loading = false;
        return user;
      } catch (error) {
        loading = false;
        cprint(error, errorIn: 'getCurrentUser');
        authStatus = AuthStatus.NOT_LOGGED_IN;
        return null;
      } finally {
        _getCurrentUserInFlight = null;
      }
    }();

    _getCurrentUserInFlight = fut;
    return fut;
  }

  /// Reload user to get refresh user data
  reloadUser() async {
    if (user == null) return;
    await user!.reload();
    user = _firebaseAuth.currentUser;
    if (user != null && user!.emailVerified) {
      _userModel?.isVerified = true;
      // If user verifed his email
      // Update user in firebase realtime kDatabase
      if (_userModel != null) createUser(_userModel!);
      cprint('UserModel email verification complete');
      logEvent('email_verification_complete',
          parameter: {_userModel?.userName ?? '': user!.email ?? ''});
    }
  }

  /// Sessiz yenileme: VerifyEmailPage'in 3 saniyelik polling Timer'ı bunu çağırır.
  /// Doğrulanmadıysa dinleyici tetiklenmez (gereksiz rebuild engellenir);
  /// doğrulanırsa `true` döner ama state hâlâ değiştirilmez. Kullanıcı arayüzü
  /// önce başarı animasyonunu oynatır, ardından `promoteToVerifiedAndContinue`
  /// ile splash → HomePage geçişi tetiklenir.
  Future<bool> reloadAndCheckEmailVerified() async {
    try {
      final current = _firebaseAuth.currentUser;
      if (current == null) return false;
      await current.reload();
      final refreshed = _firebaseAuth.currentUser;
      if (refreshed == null) return false;
      // Pollin sırasında her zaman en taze auth referansını saklarız.
      user = refreshed;
      return refreshed.emailVerified;
    } catch (e) {
      cprint(e, errorIn: 'reloadAndCheckEmailVerified');
      return false;
    }
  }

  /// Doğrulama animasyonu tamamlandıktan sonra çağrılır:
  /// - Auth user referansı tazelenir
  /// - RTDB profili `isVerified=true` ile güncellenir
  /// - notifyListeners → SplashPage rebuild → HomePage
  Future<void> promoteToVerifiedAndContinue() async {
    try {
      final current = _firebaseAuth.currentUser;
      if (current == null) return;
      await current.reload();
      user = _firebaseAuth.currentUser;
      if (user == null || !user!.emailVerified) {
        notifyListeners();
        return;
      }
      _userModel?.isVerified = true;
      logEvent('email_verification_complete',
          parameter: {_userModel?.userName ?? '': user!.email ?? ''});
      if (_userModel != null) {
        createUser(_userModel!);
      }
      notifyListeners();
    } catch (e) {
      cprint(e, errorIn: 'promoteToVerifiedAndContinue');
      notifyListeners();
    }
  }

  ActionCodeSettings get _emailVerificationActionCodeSettings {
    return ActionCodeSettings(
      url: kEmailVerificationContinueUrl,
      // Android package fields intentionally omitted:
      // Firebase turns those links into *.page.link Dynamic Links, which can
      // show an OAuth-domain error before the user ever returns to Toldya.
      handleCodeInApp: false,
    );
  }

  ActionCodeSettings get _passwordResetActionCodeSettings {
    return ActionCodeSettings(
      url: kPasswordResetContinueUrl,
      handleCodeInApp: false,
    );
  }

  Future<void> _sendEmailVerificationWithToldyaContinueUrl(
      User currentUser) async {
    try {
      await currentUser
          .sendEmailVerification(_emailVerificationActionCodeSettings);
    } on FirebaseAuthException catch (e) {
      // Firebase Console'da continue URL domain'i henüz whitelist edilmediyse
      // kullanıcıyı bloklamamak için varsayılan doğrulama linkine düş.
      if (e.code == 'unauthorized-continue-uri' ||
          e.code == 'invalid-continue-uri') {
        await currentUser.sendEmailVerification();
      } else {
        rethrow;
      }
    }
  }

  /// Send email verification link to email2
  Future<void> sendEmailVerification(
      GlobalKey<ScaffoldState> scaffoldKey) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;
    _sendEmailVerificationWithToldyaContinueUrl(currentUser).then((_) {
      logEvent('email_verifcation_sent',
          parameter: {_userModel?.displayName ?? '': currentUser.email ?? ''});
      final ctx = scaffoldKey.currentContext;
      if (ctx != null) {
        customSnackBar(
            scaffoldKey, AppLocalizations.of(ctx)!.emailVerificationSent);
      }
    }).catchError((error) {
      cprint((error as dynamic).message, errorIn: 'sendEmailVerification');
      logEvent('email_verifcation_block',
          parameter: {_userModel?.displayName ?? '': currentUser.email ?? ''});
      showLocalizedFirebaseAuthSnackBar(scaffoldKey, error);
    });
  }

  /// SnackBar göstermeden doğrulama bağlantısını yeniden gönderir
  /// (VerifyEmailPage açılışında otomatik tetiklemek için kullanılır).
  /// Hata fırlatır; çağıran taraf 60s spam koruma sayacını ona göre yönetir.
  Future<void> sendEmailVerificationSilent() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw FirebaseAuthException(code: 'no-current-user');
    }
    if (currentUser.emailVerified) return;
    await _sendEmailVerificationWithToldyaContinueUrl(currentUser);
    logEvent('email_verifcation_sent',
        parameter: {_userModel?.displayName ?? '': currentUser.email ?? ''});
  }

  /// Check if user's email is verified
  Future<bool> emailVerified() async {
    User? currentUser = _firebaseAuth.currentUser;
    return currentUser?.emailVerified ?? false;
  }

  /// Send password reset link to email
  Future<bool> forgetPassword(String email,
      {GlobalKey<ScaffoldState>? scaffoldKey}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
        actionCodeSettings: _passwordResetActionCodeSettings,
      );
      final ctx = scaffoldKey?.currentContext;
      if (scaffoldKey != null && ctx != null) {
        customSnackBar(
            scaffoldKey, AppLocalizations.of(ctx)!.resetPasswordSent);
      }
      logEvent('forgot+password');
      return true;
    } catch (error) {
      cprint(error, errorIn: 'forgetPassword');
      showLocalizedFirebaseAuthSnackBar(scaffoldKey, error);
      return false;
    }
  }

  /// `Update user` profile
  Future<void> updateUserProfileOld(
      UserModel userModel, GlobalKey<ScaffoldState> scaffoldKey,
      {File? image, File? bannerImage}) async {
    try {
      if (image == null && bannerImage == null) {
        createUser(userModel);
      } else {
        /// upload profile image if not null
        if (image != null) {
          /// get image storage path from server
          userModel.profilePic = await _uploadFileToStorage(image,
              'user/profile/${userModel.userName}/${Path.basename(image.path)}');
          // print(fileURL);
          var name = userModel?.displayName ?? user?.displayName ?? '';
          _firebaseAuth.currentUser?.updateProfile(
              displayName: name, photoURL: userModel.profilePic);
        }

        /// upload banner image if not null
        if (bannerImage != null) {
          /// get banner storage path from server
          userModel.bannerImage = await _uploadFileToStorage(bannerImage,
              'user/profile/${userModel.userName}/${Path.basename(bannerImage.path)}');
        }

        if (userModel != null) {
          createUser(userModel);
        } else if (_userModel != null) {
          createUser(_userModel!);
        }
      }

      logEvent('update_user');
      final ctx = scaffoldKey.currentContext;
      if (ctx != null) {
        customSnackBar(scaffoldKey, AppLocalizations.of(ctx)!.changesSaved);
      }
    } catch (error) {
      cprint(error, errorIn: 'updateUserProfile');
    }
  }

  /// `Update user` profile
  Future<void> updateUserProfile(
      UserModel userModel, GlobalKey<ScaffoldState> scaffoldKey,
      {String? image, String? bannerImage, String? successMessage}) async {
    try {
      if (image == null && bannerImage == null) {
        createUser(userModel);
      } else {
        /// upload profile image if not null
        if (image != null) {
          /// get image storage path from server
          userModel.profilePic = image;
          // print(fileURL);
          var name = userModel?.displayName ?? user?.displayName ?? '';
          _firebaseAuth.currentUser?.updateProfile(
              displayName: name, photoURL: userModel.profilePic);
        }

        /// upload banner image if not null
        if (bannerImage != null) {
          /// get banner storage path from server
          userModel.bannerImage = bannerImage;
        }

        if (userModel != null) {
          createUser(userModel);
        } else if (_userModel != null) {
          createUser(_userModel!);
        }
      }

      logEvent('update_user');
      final ctx = scaffoldKey.currentContext;
      if (ctx != null) {
        customSnackBar(scaffoldKey,
            successMessage ?? AppLocalizations.of(ctx)!.changesSaved);
      }
    } catch (error) {
      cprint(error, errorIn: 'updateUserProfile');
    }
  }

  Future<String> _uploadFileToStorage(File file, path) async {
    var task = _firebaseStorage.ref().child(path);
    var status = await task.putFile(file);
    print(status.state);

    /// get file storage path from server
    return await task.getDownloadURL();
  }

  /// `Fetch` user `detail` whoose userId is passed
  Future<UserModel?> getuserDetail(String userId) async {
    var snapshot = await kDatabase.child('profile').child(userId).once();
    if (snapshot.snapshot.value != null) {
      var map = snapshot.snapshot.value;
      var profileUser =
          UserModel.fromJson(Map<String, dynamic>.from(map as Map));
      profileUser.key = snapshot.snapshot.key;
      return profileUser;
    } else {
      return null;
    }
  }

  /// RTDB'de yalnızca lig alanları veya eksik şema ile kalmış profilleri Auth + varsayılanlarla tamamlar.
  void _ensureProfileCompleteness() {
    final u = user;
    final m = _userModel;
    if (u == null || m == null) return;

    final patch = <String, dynamic>{};

    final authEmail = u.email;
    if ((m.email == null || m.email!.trim().isEmpty) &&
        authEmail != null &&
        authEmail.trim().isNotEmpty) {
      patch['email'] = authEmail.trim();
      m.email = authEmail.trim();
    }

    final authName = u.displayName;
    if ((m.displayName == null || m.displayName!.trim().isEmpty) &&
        authName != null &&
        authName.trim().isNotEmpty) {
      patch['displayName'] = authName.trim();
      m.displayName = authName.trim();
    }

    if (m.bio == null || m.bio!.trim().isEmpty) {
      const defaultBio = 'Edit profile to update bio';
      patch['bio'] = defaultBio;
      m.bio = defaultBio;
    }

    if (m.userId == null || m.userId!.trim().isEmpty) {
      m.userId = u.uid;
      patch['userId'] = u.uid;
    }

    if (m.userName == null || m.userName!.trim().isEmpty) {
      final un = getUserName(id: m.userId ?? u.uid, name: m.displayName ?? '');
      patch['userName'] = un;
      m.userName = un;
    }

    if (m.createdAt == null || m.createdAt!.trim().isEmpty) {
      final ca = DateTime.now().toUtc().toString();
      patch['createdAt'] = ca;
      m.createdAt = ca;
    }

    if (m.pegCount == null) {
      patch['pegCount'] = AppIcon.pegCount;
      m.pegCount = AppIcon.pegCount;
    }
    if (m.stashCount == null) {
      patch['stashCount'] = 0;
      m.stashCount = 0;
    }
    if (m.xp == null) {
      patch['xp'] = 0;
      m.xp = 0;
    }
    if (m.rank == null) {
      patch['rank'] = AppIcon.defaultRank;
      m.rank = AppIcon.defaultRank;
    }
    if (m.predictorScore == null) {
      patch['predictorScore'] = 0;
      m.predictorScore = 0;
    }
    if (m.role == null) {
      patch['role'] = Role.defaultRole;
      m.role = Role.defaultRole;
    }

    if (patch.isEmpty) return;

    kDatabase.child('profile').child(u.uid).update(patch);
  }

  /// Fetch user profile
  /// If `userProfileId` is null then logged in user's profile will fetched.
  /// Does not clear _profileUserModelList; keeps previous data until new data or error.
  getProfileUser({String? userProfileId}) {
    _profileError = null;
    loading = true;
    if (_profileUserModelList == null) {
      _profileUserModelList = [];
    }

    userProfileId = userProfileId ?? user?.uid ?? '';
    _pendingProfileRequestId = userProfileId;
    final requestedId = userProfileId;

    runWithTimeoutAndRetry(
            () => kDatabase.child("profile").child(userProfileId!).once())
        .then((snapshot) {
      if (requestedId != _pendingProfileRequestId) return;
      if (snapshot.snapshot.value != null) {
        var map = snapshot.snapshot.value;
        if (map != null) {
          _profileUserModelList!
              .add(UserModel.fromJson(Map<String, dynamic>.from(map as Map)));
          if (user?.uid != null && userProfileId == user!.uid) {
            _userModel = _profileUserModelList!.last;
            _userModel!.isVerified = user!.emailVerified;
            if (!user!.emailVerified) {
              reloadUser();
            }
            updateFCMToken();
            _ensureProfileCompleteness();
          }
          logEvent('get_profile');
        }
      } else if (user != null && userProfileId == user!.uid) {
        ensureFirebaseAuthProfileInRtdb(user!).then((_) {
          if (requestedId != _pendingProfileRequestId) return;
          if (_userModel != null) {
            _profileUserModelList = [_userModel!];
            updateFCMToken();
          }
          loading = false;
          notifyListeners();
        });
        return;
      }
      loading = false;
      notifyListeners();
    }).catchError((error) {
      loading = false;
      _profileError = error?.toString() ?? 'Failed to load profile';
      cprint(error, errorIn: 'getProfileUser');
      notifyListeners();
    });
  }

  /// if firebase token not available in profile
  /// Then get token from firebase and save it to profile
  /// When someone sends you a message FCM token is used
  void updateFCMToken() {
    // Token persistence is owned by NotificationService (single responsibility).
    // Keep this method for backward compatibility with existing call sites.
    if (user?.uid == null || user!.uid!.isEmpty) return;
    // If profile already has a token, don't spam getToken() / logs at startup.
    if ((_userModel?.fcmToken ?? '').isNotEmpty) return;
    // Fire-and-forget: NotificationService will skip redundant writes.
    // ignore: unawaited_futures
    NotificationService.instance.getTokenAndPersist();
  }

  addBlackList(String userId) {
    final currentUser = userModel;
    if (currentUser == null) return;
    final currentUserId = (currentUser.userId ?? '').trim();
    if (currentUserId.isEmpty) {
      cprint('addBlackList blocked: current userId empty',
          errorIn: 'addBlackList');
      return;
    }
    try {
      if (currentUser.blackList != null &&
          currentUser.blackList!.length > 0 &&
          currentUser.blackList!.any((id) => id == userId)) {
        /// If logged-in user `alredy follow `profile user then
        /// 1.Remove logged-in user from profile user's `follower` list
        /// 2.Remove profile user from logged-in user's `following` list
        // profileUserModel.followersList.remove(userModel.userId);

        currentUser.blackList?.removeWhere((id) => id == userId);
        cprint('user removed from blackList ', event: 'remove_blackList');
      } else {
        currentUser.blackList ??= [];
        currentUser.blackList!.add(userId);
      }
      kDatabase
          .child('profile')
          .child(currentUserId)
          .child('blackList')
          .set(currentUser.blackList);
      cprint('user added to blackList list', event: 'add_blackList');
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'blackList');
    }
  }

  /// Trigger when logged-in user's profile change or updated
  /// Firebase event callback for profile update
  void _onProfileChanged(DatabaseEvent event) {
    if (event.snapshot.value != null && user != null) {
      final updatedUser = UserModel.fromJson(
          Map<String, dynamic>.from(event.snapshot.value as Map));
      if (updatedUser.userId == user!.uid) {
        _userModel = updatedUser;
        // Clear cached admin flag so future checks re-read profile/isAdmin.
        _isAdminCached = null;
      }
      cprint('UserModel Updated');
      notifyListeners();
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
