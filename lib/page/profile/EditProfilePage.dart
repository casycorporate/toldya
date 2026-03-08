import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key? key}) : super(key: key);
  _EditProfilePageState createState() => _EditProfilePageState();
}

/// Kullanıcı adı: sadece harf, rakam, alt çizgi; 3–20 karakter; @ opsiyonel (kayıtta eklenir).
const int _usernameMinLength = 3;
const int _usernameMaxLength = 20;
final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

class _EditProfilePageState extends State<EditProfilePage> {
  late String _image;
  late String _banner;
  late TextEditingController _name;
  late TextEditingController _userName;
  late TextEditingController _bio;
  late TextEditingController _location;
  late TextEditingController _dob;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String dob;
  bool _isSaving = false;
  @override
  void initState() {
    super.initState();
    _image = '';
    _banner = '';
    _name = TextEditingController();
    _userName = TextEditingController();
    _bio = TextEditingController();
    _location = TextEditingController();
    _dob = TextEditingController();
    dob = '';
    var state = Provider.of<AuthState>(context, listen: false);
    _image = state.userModel?.profilePic ?? '';
    _name.text = state.userModel?.displayName ?? '';
    final raw = state.userModel?.userName ?? '';
    _userName.text = raw.startsWith('@') ? raw.substring(1) : raw;
    _bio.text = state.userModel?.bio ?? '';
    _location.text = state.userModel?.location ?? '';
    _dob.text = getdob(state.userModel?.dob ?? '');
    _banner = state.userModel?.bannerImage ?? '';
  }

  void dispose() {
    _name.dispose();
    _userName.dispose();
    _bio.dispose();
    _location.dispose();
    _dob.dispose();
    super.dispose();
  }

  Widget _body() {
    var authstate = Provider.of<AuthState>(context, listen: false);
    final theme = Theme.of(context);
    return Container(
      color: MockupDesign.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 200,
            child: Stack(
              children: <Widget>[
                _bannerImage(authstate),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: _userImage(authstate),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing16),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MockupDesign.screenPadding,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: MockupDesign.card,
                borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
                border: Border.all(color: MockupDesign.cardBorder),
                boxShadow: MockupDesign.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _entry(AppLocalizations.of(context)!.name, controller: _name),
                  _entry(AppLocalizations.of(context)!.usernameLabel, controller: _userName, hint: AppLocalizations.of(context)!.exampleUsername),
                  _entry(AppLocalizations.of(context)!.bio, controller: _bio, maxLine: 3),
                  _entry(AppLocalizations.of(context)!.location, controller: _location),
                  InkWell(
                    onTap: showCalender,
                    child: _entry(AppLocalizations.of(context)!.birthDate, isenable: false, controller: _dob),
                  ),
                  SizedBox(height: spacing8),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing16),
        ],
      ),
    );
  }

  Widget _userImage(AuthState authstate) {
    final effectiveProfilePic =
        _image.isNotEmpty ? _image : authstate.userModel?.profilePic;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      height: 90,
      width: 90,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.surface, width: 5),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: customProfileImage(
              context,
              effectiveProfilePic,
              userId: authstate.userModel?.userId,
              height: 80,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.scrim.withOpacity(0.5),
            ),
            child: Center(
              child: IconButton(
                onPressed: _showAvatarPicker,
                icon: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.selectProfilePhoto,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.appAvatars,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: DefaultProfilePics.assets.map((asset) {
                  final isSelected = _image == asset;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _image = asset);
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppNeon.cyan : Colors.transparent,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(asset),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bannerImage(AuthState authstate) {
    final displayBanner = _banner.isNotEmpty ? _banner : (authstate.userModel?.bannerImage ?? '');
    Widget imageWidget;
    final assetPath = DefaultBanners.assetForKey(displayBanner);
    if (assetPath != null) {
      imageWidget = Image.asset(assetPath, fit: BoxFit.cover, width: double.infinity);
    } else if (displayBanner.isNotEmpty) {
      imageWidget = customNetworkImage(displayBanner, fit: BoxFit.cover);
    } else {
      imageWidget = Container(color: Theme.of(context).colorScheme.surfaceContainerHighest);
    }
    return Container(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageWidget,
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.scrim.withOpacity(0.5),
            ),
          ),
          Center(
            child: IconButton(
              onPressed: _showBannerPicker,
              icon: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  void _showBannerPicker() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.selectCoverPhoto,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.appCovers,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: DefaultBanners.assets.asMap().entries.map((e) {
                  final key = DefaultBanners.keys[e.key];
                  final isSelected = _banner == key;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          setState(() => _banner = key);
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                e.value,
                                height: 72,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: AppNeon.cyan, size: 28),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entry(String title,
      {required TextEditingController controller,
      int maxLine = 1,
      bool isenable = true,
      String? hint}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          customText(title,
              context: context,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
          TextField(
            enabled: isenable,
            controller: controller,
            maxLines: maxLine,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              hintText: hint,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          )
        ],
      ),
    );
  }

  void showCalender() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2019, DateTime.now().month, DateTime.now().day),
      firstDate: DateTime(1950, DateTime.now().month, DateTime.now().day + 3),
      lastDate: DateTime.now().add(Duration(days: 7)),
    );
    setState(() {
      if (picked != null) {
        dob = picked.toString();
        _dob.text = getdob(dob);
      }
    });
  }

  /// Kullanıcı adını normalize eder: baştaki @ kaldırılır, sadece [a-zA-Z0-9_] kalır. Uygun değilse null. Dönen değer @ içermez.
  String? _normalizeUsername(String raw) {
    final s = raw.trim().replaceFirst(RegExp(r'^@+'), '').trim();
    if (s.length < _usernameMinLength || s.length > _usernameMaxLength) return null;
    if (!_usernameRegex.hasMatch(s)) return null;
    return s;
  }

  /// Firebase profile listesinde bu userName başka bir kullanıcıda var mı?
  /// Hem eski (@sinan) hem yeni (sinan) formatla uyumlu: her iki taraf @'sız normalize edilip karşılaştırılır.
  Future<bool> _isUsernameTaken(String normalizedUserName, String currentUserId) async {
    final snapshot = await kDatabase.child('profile').get();
    if (snapshot.value == null) return false;
    final map = Map<dynamic, dynamic>.from(snapshot.value as Map);
    final lower = normalizedUserName.toLowerCase();
    for (final entry in map.entries) {
      final uid = entry.key.toString();
      if (uid == currentUserId) continue;
      final data = entry.value;
      if (data is! Map) continue;
      final existing = data['userName'];
      final existingNorm = (existing?.toString().trim() ?? '').replaceFirst(RegExp(r'^@+'), '').trim().toLowerCase();
      if (existingNorm.isNotEmpty && existingNorm == lower) return true;
    }
    return false;
  }

  Future<void> _submitButton() async {
    final l10n = AppLocalizations.of(context)!;
    if (_name.text.length > 27) {
      customSnackBar(_scaffoldKey, l10n.nameTooLongProfile);
      return;
    }
    final rawUserName = _userName.text.trim();
    if (rawUserName.isEmpty) {
      customSnackBar(_scaffoldKey, l10n.usernameRequired);
      return;
    }
    final normalizedUserName = _normalizeUsername(rawUserName);
    if (normalizedUserName == null) {
      customSnackBar(
        _scaffoldKey,
        l10n.usernameRules(_usernameMinLength, _usernameMaxLength),
      );
      return;
    }
    var state = Provider.of<AuthState>(context, listen: false);
    final um = state.userModel;
    if (um == null) return;
    if (!mounted) return;
    setState(() => _isSaving = true);
    try {
      final taken = await _isUsernameTaken(normalizedUserName, um.userId ?? '');
      if (!mounted) return;
      if (taken) {
        setState(() => _isSaving = false);
        customSnackBar(_scaffoldKey, AppLocalizations.of(context)!.usernameTaken);
        return;
      }
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
      customSnackBar(_scaffoldKey, AppLocalizations.of(context)!.errorCheckFailed);
      return;
    }
    var model = um.copyWith(
      key: um.userId,
      displayName: um.displayName,
      userName: um.userName,
      bio: um.bio,
      contact: um.contact,
      dob: um.dob,
      email: um.email,
      location: um.location,
      profilePic: um.profilePic,
      userId: um.userId,
      bannerImage: um.bannerImage,
      pegCount: um.pegCount,
      role: um.role,
      rank: um.rank,
    );
    if (_name.text.trim().isNotEmpty) {
      model.displayName = _name.text.trim();
    }
    model.userName = normalizedUserName;
    if (_bio.text.trim().isNotEmpty) {
      model.bio = _bio.text;
    }
    if (_location.text.trim().isNotEmpty) {
      model.location = _location.text;
    }
    if (dob.isNotEmpty) {
      model.dob = dob;
    }
    final imageParam = _image.isNotEmpty ? _image : null;
    final bannerParam = _banner.isNotEmpty ? _banner : null;
    try {
      await state.updateUserProfile(model, _scaffoldKey, image: imageParam, bannerImage: bannerParam, successMessage: AppLocalizations.of(context)!.changesSaved);
      if (mounted && Navigator.canPop(context)) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
      customSnackBar(_scaffoldKey, l10n.errorSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        title: customTitleText(AppLocalizations.of(context)!.editProfile),
        actions: <Widget>[
          InkWell(
            onTap: _isSaving ? null : _submitButton,
            child: Center(
              child: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.save,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: _body(),
      ),
    );
  }
}
