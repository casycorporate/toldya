import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/page/settings/widgets/settingsAppbar.dart';
import 'package:toldya/state/authState.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyAndSaftyPage extends StatefulWidget {
  const PrivacyAndSaftyPage({super.key});

  @override
  State<PrivacyAndSaftyPage> createState() => _PrivacyAndSaftyPageState();
}

class _PrivacyAndSaftyPageState extends State<PrivacyAndSaftyPage> {
  bool _hideSensitive = false;

  Future<void> _openExternalLink(String url) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (launched) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF3B1C1C),
        content: Text(l10n.errorGeneric),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = Provider.of<AuthState>(context, listen: false);
    final userName = authState.userModel?.userName ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F2E),
      appBar: SettingsAppBar(
        title: l10n.privacyAndSafetyTitle,
        subtitle: userName,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(MockupDesign.screenPadding),
        children: <Widget>[
          _SettingsCard(
            title: l10n.contentModerationHeader,
            children: <Widget>[
              _TappableRow(
                title: l10n.blockedAccountsTitle,
                subtitle: null,
                onTap: () {
                  Navigator.of(context).pushNamed('/BlockedAccountsPage');
                },
              ),
              const SizedBox(height: 12),
              _SwitchRow(
                title: l10n.hideSensitiveContentTitle,
                value: _hideSensitive,
                onChanged: (value) => setState(() => _hideSensitive = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            title: l10n.legalHeader,
            children: <Widget>[
              _TappableRow(
                title: l10n.privacyPolicyRowTitle,
                subtitle: null,
                onTap: () => _openExternalLink('https://gist.github.com/casycorporate/9d02dc12f089be7c0323b31f4895c275'),
              ),
              const SizedBox(height: 12),
              _TappableRow(
                title: l10n.userAgreementRowTitle,
                subtitle: null,
                onTap: () => _openExternalLink('https://gist.github.com/casycorporate/9d02dc12f089be7c0323b31f4895c275'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DangerCard(
            children: <Widget>[
              _DangerDeleteRow(
                title: l10n.deleteAccountTitle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MockupDesign.cardPadding),
      decoration: BoxDecoration(
        color: MockupDesign.card,
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        border: Border.all(color: MockupDesign.cardBorder),
        boxShadow: MockupDesign.cardShadow,
      ),
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
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DangerCard extends StatelessWidget {
  final List<Widget> children;
  const _DangerCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MockupDesign.cardPadding),
      decoration: BoxDecoration(
        color: MockupDesign.card,
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        border: Border.all(color: const Color(0x33FF6B6B)),
        boxShadow: MockupDesign.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _TappableRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _TappableRow({
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: <Widget>[
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
                          color: MockupDesign.textSecondary,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: MockupDesign.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisabledTappableRow extends StatelessWidget {
  final String title;
  final String subtitle;
  const _DisabledTappableRow({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
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
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: MockupDesign.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.lock_outline, size: 18, color: MockupDesign.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String subtitle;
  const _InfoRow({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: MockupDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: MockupDesign.textPrimary,
              ),
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

class _DisabledSwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  const _DisabledSwitchRow({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
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
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: MockupDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: false,
            onChanged: null,
            activeThumbColor: AppNeon.green,
              activeTrackColor: AppNeon.green.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }
}

class _DisabledDropdownRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String valueText;
  final List<String> items;

  const _DisabledDropdownRow({
    required this.title,
    required this.subtitle,
    required this.valueText,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    DropdownMenuItem<String> buildItem(String text) => DropdownMenuItem<String>(
          value: text,
          child: Text(text),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
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
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: MockupDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: MockupDesign.cardBorder),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: valueText,
                  onChanged: null,
                  items: items.map(buildItem).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerDeleteRow extends StatefulWidget {
  final String title;
  const _DangerDeleteRow({required this.title});

  @override
  State<_DangerDeleteRow> createState() => _DangerDeleteRowState();
}

class _DangerDeleteRowState extends State<_DangerDeleteRow> {
  bool _deleting = false;

  Future<void> _handleDelete(BuildContext context) async {
    if (_deleting) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _deleting = true);
    try {
      // NOTE: Callable contract name must match functions/index.js export: `deleteAccount`.
      final callable = FirebaseFunctions.instance.httpsCallable('deleteAccount');
      await callable.call(<String, dynamic>{});

      if (!context.mounted) return;
      final authState = Provider.of<AuthState>(context, listen: false);
      authState.logoutCallback();

      // SnackBar: success is non-blocking; route transition is handled after dialog closes.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2B3A2D),
          content: Text(l10n.deleteAccountSuccess),
        ),
      );
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      // If the user is still on this settings screen, push them to sign-in.
      Navigator.of(context).pushNamedAndRemoveUntil('/SignIn', (_) => false);
    } on FirebaseFunctionsException catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF3B1C1C),
          content: Text(
            l10n.deleteAccountErrorGeneric,
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF3B1C1C),
          content: Text(l10n.deleteAccountErrorGeneric),
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (_deleting) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: MockupDesign.card,
              title: Text(
                l10n.deleteAccountTitle,
                style: TextStyle(
                  color: MockupDesign.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.deleteAccountWarning,
                    style: TextStyle(
                      color: MockupDesign.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.deleteAccountCannotBeUndone,
                    style: TextStyle(
                      color: MockupDesign.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_deleting) ...[
                    const SizedBox(height: 14),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: _deleting
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(color: MockupDesign.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: _deleting
                      ? null
                      : () async {
                          setStateDialog(() => _deleting = true);
                          await _handleDelete(context);
                        },
                  child: Text(
                    _deleting ? l10n.deleteAccountBusy : l10n.deleteAccountDeleteButton,
                    style: TextStyle(
                      color: const Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _confirmDelete(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: <Widget>[
              Icon(Icons.delete_outline, color: const Color(0xFFFF6B6B)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF6B6B),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFFFF6B6B)),
            ],
          ),
        ),
      ),
    );
  }
}
