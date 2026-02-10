import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bendemistim/helper/constant.dart';
import 'package:bendemistim/helper/enum.dart';
import 'package:bendemistim/helper/utility.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/widgets/customWidgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as Path;
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'appState.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:cloud_functions/cloud_functions.dart';

class AuthState extends AppState {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  bool isSignInWithGoogle = false;
  User? user;
  String userId = '';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  dabase.Query? _profileQuery;
  List<UserModel>? _profileUserModelList;
  UserModel? _userModel;

  UserModel? get userModel => _userModel;

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

  /// Logout from device
  void logoutCallback() {
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

  databaseInit() {
    try {
      if (_profileQuery == null && user != null) {
        _profileQuery = kDatabase.child("profile").child(user!.uid);
        _profileQuery!.onValue.listen(_onProfileChanged);
      }
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
    }
  }

  /// Verify user's credentials for login
  Future<String?> signIn(String email, String password,
      {GlobalKey<ScaffoldState>? scaffoldKey}) async {
    try {
      loading = true;
      var result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      // if(userModel.role==null){
      //   userModel.role=AppIcon.defaultRole;
      //   createUser(userModel);
      // }
      userId = user?.uid ?? '';
      return user?.uid;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'signIn');
      kAnalytics.logLogin(loginMethod: 'email_login');
      if (scaffoldKey != null) customSnackBar(scaffoldKey!, (error as dynamic).message);
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
      if (user != null) createUserFromGoogleSignIn(user!);
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

  /// Create user profile from google login
  createUserFromGoogleSignIn(User user) {
    var diff = DateTime.now().difference(user.metadata.creationTime ?? DateTime.now());
    // Check if user is new or old
    // If user is new then add new user to firebase realtime kDatabase
    if (diff < Duration(seconds: 15)) {
      UserModel model = UserModel(
          bio: 'Edit profile to update bio',
          dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
              .toString(),
          location: 'Somewhere in universe',
          profilePic: user.photoURL,
          displayName: user.displayName,
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
          role: Role.defaultRole);
      createUser(model, newUser: true);
    } else {
      cprint('Last login at: ${user.metadata.lastSignInTime}');
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
      if (scaffoldKey != null) customSnackBar(scaffoldKey, (error as dynamic).message);
      return null;
    }
  }

  /// Bahis sonrası sadece bakiye alanlarını günceller (backend zaten DB'yi güncelledi).
  void updateBalanceFromBet(int newPegCount, int newStashBalance) {
    if (_userModel != null) {
      _userModel!.pegCount = newPegCount;
      _userModel!.stashCount = newStashBalance;
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
    return now.year != last.year || now.month != last.month || now.day != last.day;
  }

  /// Günlük bonusu alır (Callable). Başarıda bakiye ve lastDailyClaimAt güncellenir.
  Future<String?> claimDailyBonus() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable("claimDailyBonus")
          .call<Map<dynamic, dynamic>>({});
      final data = result.data;
      if (data == null || data["ok"] != true) return null;
      if (_userModel != null) {
        _userModel!.pegCount = data["newBalance"] as int? ?? _userModel!.pegCount;
        _userModel!.lastDailyClaimAt = DateTime.now().toUtc().toIso8601String();
        notifyListeners();
      }
      return data["message"] as String? ?? "Günlük bonus alındı.";
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
    if (newUser) {
      user.userName = getUserName(id: user.userId ?? '', name: user.displayName ?? '');
      kAnalytics.logEvent(name: 'create_newUser');
      user.createdAt = DateTime.now().toUtc().toString();
    }
    kDatabase.child('profile').child(user.userId ?? '').set(user.toJson());
    _userModel = user;
    if (_profileUserModelList != null) {
      _profileUserModelList!.last = _userModel!;
    }
    loading = false;
  }

  /// Fetch current user profile
  Future<User?> getCurrentUser() async {
    try {
      loading = true;
      logEvent('get_currentUSer');
      user = _firebaseAuth.currentUser;
      if (user != null) {
        authStatus = AuthStatus.LOGGED_IN;
        userId = user!.uid;
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
    }
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

  /// Send email verification link to email2
  Future<void> sendEmailVerification(
      GlobalKey<ScaffoldState> scaffoldKey) async {
    User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;
    currentUser.sendEmailVerification().then((_) {
      logEvent('email_verifcation_sent',
          parameter: {_userModel?.displayName ?? '': currentUser!.email ?? ''});
      customSnackBar(
        scaffoldKey,
        'An email verification link is send to your email.',
      );
    }).catchError((error) {
      cprint((error as dynamic).message, errorIn: 'sendEmailVerification');
      logEvent('email_verifcation_block',
          parameter: {_userModel?.displayName ?? '': currentUser?.email ?? ''});
      customSnackBar(
        scaffoldKey,
        (error as dynamic).message,
      );
    });
  }

  /// Check if user's email is verified
  Future<bool> emailVerified() async {
    User? currentUser = _firebaseAuth.currentUser;
    return currentUser?.emailVerified ?? false;
  }

  /// Send password reset link to email
  Future<void> forgetPassword(String email,
      {GlobalKey<ScaffoldState>? scaffoldKey}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email).then((value) {
        if (scaffoldKey != null) customSnackBar(scaffoldKey,
            'A reset password link is sent yo your mail.You can reset your password from there');
        logEvent('forgot+password');
      }).catchError((error) {
        cprint((error as dynamic).message);
        return false;
      });
    } catch (error) {
      if (scaffoldKey != null) customSnackBar(scaffoldKey, (error as dynamic).message);
      return Future.value(false);
    }
  }

  /// `Update user` profile
  Future<void> updateUserProfileOld(UserModel userModel,GlobalKey<ScaffoldState> scaffoldKey,
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
          _firebaseAuth.currentUser
              ?.updateProfile(displayName: name, photoURL: userModel.profilePic);
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
      customSnackBar(scaffoldKey, 'Değişiklikler Kaydedildi');
    } catch (error) {
      cprint(error, errorIn: 'updateUserProfile');
    }
  }

  /// `Update user` profile
  Future<void> updateUserProfile(UserModel userModel,GlobalKey<ScaffoldState> scaffoldKey,
      {String? image, String? bannerImage}) async {
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
          _firebaseAuth.currentUser
              ?.updateProfile(displayName: name, photoURL: userModel.profilePic);
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
      customSnackBar(scaffoldKey, 'Değişiklikler Kaydedildi');
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
      var profileUser = UserModel.fromJson(Map<String, dynamic>.from(map as Map));
      profileUser.key = snapshot.snapshot.key;
      return profileUser;
    } else {
      return null;
    }
  }

  /// Fetch user profile
  /// If `userProfileId` is null then logged in user's profile will fetched
  getProfileUser({String? userProfileId}) {
    try {
      loading = true;
      if (_profileUserModelList == null) {
        _profileUserModelList = [];
      }

      userProfileId = userProfileId ?? user?.uid ?? '';
      kDatabase
          .child("profile")
          .child(userProfileId!)
          .once()
          .then((snapshot) {
        if (snapshot.snapshot.value != null) {
          var map = snapshot.snapshot.value;
          if (map != null) {
            _profileUserModelList!.add(UserModel.fromJson(Map<String, dynamic>.from(map as Map)));
            if (user?.uid != null && userProfileId == user!.uid) {
              _userModel = _profileUserModelList!.last;
              _userModel!.isVerified = user!.emailVerified;
              if (!user!.emailVerified) {
                // Check if logged in user verified his email address or not
                reloadUser();
              }
              updateFCMToken();
              // if (_userModel.fcmToken != null) {
              //   updateFCMToken();
              // }
            }

            logEvent('get_profile');
          }
        }
        loading = false;
      });
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getProfileUser');
    }
  }

  /// if firebase token not available in profile
  /// Then get token from firebase and save it to profile
  /// When someone sends you a message FCM token is used
  void updateFCMToken() {
    if (_userModel == null) {
      return;
    }
    final model = _userModel!;
    _firebaseMessaging.getToken().then((String? token) {
      if (token != null) {
        model.fcmToken = token;
        createUser(model);
      }
    });
  }

  /// Follow / Unfollow user
  ///
  /// If `removeFollower` is true then remove user from follower list
  ///
  /// If `removeFollower` is false then add user to follower list
  followUser({bool removeFollower = false}) {
    /// `userModel` is user who is looged-in app.
    /// `profileUserModel` is user whoose profile is open in app.
    final profileUser = profileUserModel;
    final currentUser = userModel;
    if (profileUser == null || currentUser == null) return;
    try {
      if (removeFollower) {
        /// If logged-in user `alredy follow `profile user then
        /// 1.Remove logged-in user from profile user's `follower` list
        /// 2.Remove profile user from logged-in user's `following` list
        profileUser.followersList?.remove(currentUser.userId);

        /// Remove profile user from logged-in user's following list
        currentUser.followingList?.remove(profileUser.userId);
        cprint('user removed from following list', event: 'remove_follow');
      } else {
        /// if logged in user is `not following` profile user then
        /// 1.Add logged in user to profile user's `follower` list
        /// 2. Add profile user to logged in user's `following` list
        profileUser.followersList ??= [];
        profileUser.followersList!.add(currentUser.userId ?? '');
        currentUser.followingList ??= [];
        currentUser.followingList!.add(profileUser.userId ?? '');
      }
      profileUser.followers = profileUser.followersList?.length ?? 0;
      currentUser.following = currentUser.followingList?.length ?? 0;
      kDatabase
          .child('profile')
          .child(profileUser.userId ?? '')
          .child('followerList')
          .set(profileUser.followersList);
      kDatabase
          .child('profile')
          .child(currentUser.userId ?? '')
          .child('followingList')
          .set(currentUser.followingList);
      cprint('user added to following list', event: 'add_follow');
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'followUser');
    }
  }


  /// Follow / Unfollow user
  ///
  /// If `removeFollower` is true then remove user from follower list
  ///
  /// If `removeFollower` is false then add user to follower list
  addBlackList(String userId) {
    final currentUser = userModel;
    if (currentUser == null) return;
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
          .child(currentUser.userId ?? '')
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
      final updatedUser = UserModel.fromJson(Map<String, dynamic>.from(event.snapshot.value as Map));
      if (updatedUser.userId == user!.uid) {
        _userModel = updatedUser;
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

  // Future<User> signInWithApple() async {
  //   // To prevent replay attacks with the credential returned from Apple, we
  //   // include a nonce in the credential request. When signing in in with
  //   // Firebase, the nonce in the id token returned by Apple, is expected to
  //   // match the sha256 hash of `rawNonce`.
  //   final rawNonce = generateNonce();
  //   final nonce = sha256ofString(rawNonce);
  //
  //   try {
  //     // Request credential for the currently signed in Apple account.
  //     final appleCredential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName,
  //       ],
  //       nonce: nonce,
  //     );
  //
  //     print(appleCredential.authorizationCode);
  //
  //     // Create an `OAuthCredential` from the credential returned by Apple.
  //     final oauthCredential = OAuthProvider("apple.com").credential(
  //       idToken: appleCredential.identityToken,
  //       rawNonce: rawNonce,
  //     );
  //
  //     // Sign in the user with Firebase. If the nonce we generated earlier does
  //     // not match the nonce in `appleCredential.identityToken`, sign in will fail.
  //     final authResult =
  //     await _firebaseAuth.signInWithCredential(oauthCredential);
  //
  //     final displayName =
  //         '${appleCredential.givenName} ${appleCredential.familyName}';
  //     final userEmail = '${appleCredential.email}';
  //
  //     final firebaseUser = authResult.user;
  //     print(displayName);
  //     await firebaseUser.updateProfile(displayName: displayName);
  //     await firebaseUser.updateEmail(userEmail);
  //
  //     return firebaseUser;
  //   } catch (exception) {
  //     print(exception);
  //   }
  // }
}
