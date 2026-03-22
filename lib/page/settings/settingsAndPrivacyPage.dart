import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/page/settings/widgets/customSettingsCard.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/widgets/customAppBar.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/rank/rankBadgeWidget.dart';

class SettingsAndPrivacyPage extends StatelessWidget {
  const SettingsAndPrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F2E),
      appBar: CustomAppBar(
        isBackButton: true,
        title: Text(
          l10n.settingsAndPrivacy,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'HelveticaNeue',
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(MockupDesign.screenPadding),
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          CustomSettingsCard(
            children: <Widget>[
              _MiniProfileCard(authState: authState),
            ],
          ),
          const SizedBox(height: 12),
          CustomSettingsCard(
            title: l10n.accountTitle,
            children: <Widget>[
              _SettingsTile(
                icon: Icons.person_outline,
                title: l10n.accountTitle,
                subtitle: null,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/AccountSettingsPage');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomSettingsCard(
            title: l10n.preferencesHeader,
            children: <Widget>[
              _SettingsTile(
                icon: Icons.language,
                title: l10n.language,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/LanguagePage');
                },
              ),
              _SettingsTile(
                icon: Icons.notifications_none,
                title: l10n.notificationsTitle,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/NotificationPage');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomSettingsCard(
            title: l10n.privacyAndSafetyTitle,
            children: <Widget>[
              _SettingsTile(
                icon: Icons.lock_outline,
                title: l10n.privacyAndPolicy,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/PrivacyAndSaftyPage');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomSettingsCard(
            children: <Widget>[
              _LogoutTile(
                title: l10n.logoutActionTitle,
                onLogout: () {
                  HapticFeedback.lightImpact();
                  authState.logoutCallback();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/WelcomePage',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniProfileCard extends StatelessWidget {
  final AuthState authState;
  const _MiniProfileCard({required this.authState});

  @override
  Widget build(BuildContext context) {
    final user = authState.userModel;
    final displayName = user?.displayName ?? '';
    final handle = user?.userName ?? '';
    final xp = user?.xp ?? 0;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Row(
        children: <Widget>[
          customProfileImage(
            context,
            user?.profilePic,
            userId: user?.userId,
            height: 48,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: MockupDesign.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  handle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: MockupDesign.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          RankBadgeWidget(xp: xp, compact: true),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22, color: MockupDesign.textPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: MockupDesign.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: MockupDesign.textSecondary.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: MockupDesign.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final String title;
  final VoidCallback onLogout;
  const _LogoutTile({required this.title, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    const danger = Color(0xFFFF6B6B);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onLogout,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: danger.withOpacity(0.35)),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.logout_outlined, size: 22, color: danger),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: danger,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: Color(0xFFFF6B6B)),
            ],
          ),
        ),
      ),
    );
  }
}
