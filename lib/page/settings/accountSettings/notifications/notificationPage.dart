import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/model/user.dart';
import 'package:toldya/page/settings/widgets/customSettingsCard.dart';
import 'package:toldya/page/settings/widgets/settingsAppbar.dart';
import 'package:toldya/state/authState.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _pushEnabled = false;
  bool _badgeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SettingsAppBar(
        title: l10n.notificationsTitle,
        subtitle: user.userName ?? '',
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(MockupDesign.screenPadding),
        children: <Widget>[
          CustomSettingsCard(
            title: l10n.preferencesHeader,
            children: [
              _SwitchRow(
                title: l10n.pushNotificationsTitle,
                value: _pushEnabled,
                onChanged: (value) => setState(() => _pushEnabled = value),
              ),
              _SwitchRow(
                title: l10n.unreadBadgeTitle,
                subtitle: l10n.unreadBadgeSubtitle,
                value: _badgeEnabled,
                onChanged: (value) => setState(() => _badgeEnabled = value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: MockupDesign.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: MockupDesign.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppNeon.green,
            activeTrackColor: AppNeon.green.withOpacity(0.25),
          ),
        ],
      ),
    );
  }
}
