import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/page/settings/widgets/customSettingsCard.dart';
import 'package:toldya/page/settings/widgets/settingsAppbar.dart';
import 'package:toldya/state/authState.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    final user = authState.userModel ?? UserModel();
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F2E),
      appBar: SettingsAppBar(
        title: AppLocalizations.of(context)!.accountTitle,
        subtitle: user.userName ?? '',
      ),
      body: ListView(
        padding: const EdgeInsets.all(MockupDesign.screenPadding),
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          CustomSettingsCard(
            children: <Widget>[
              _EditableRow(
                icon: Icons.person_outline,
                title: AppLocalizations.of(context)!.usernameLabel,
                subtitle: user.userName ?? '',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/EditProfile');
                },
              ),
              _EditableRow(
                icon: Icons.email_outlined,
                title: AppLocalizations.of(context)!.emailAddressTitle,
                subtitle: user.email ?? '',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/VerifyEmailPage');
                },
              ),
              _EditableRow(
                icon: Icons.lock_outline,
                title: AppLocalizations.of(context)!.changePasswordTitle,
                subtitle: null,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/ForgetPasswordPage');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _EditableRow({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: MockupDesign.textSecondary.withOpacity(0.75),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: MockupDesign.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
