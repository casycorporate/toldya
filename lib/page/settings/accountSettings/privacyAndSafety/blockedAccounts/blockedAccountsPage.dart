import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/page/settings/widgets/settingsAppbar.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/widgets/customWidgets.dart';

import '../../../../../model/user.dart';

class BlockedAccountsPage extends StatefulWidget {
  const BlockedAccountsPage({super.key});

  @override
  State<BlockedAccountsPage> createState() => _BlockedAccountsPageState();
}

class _BlockedAccountsPageState extends State<BlockedAccountsPage> {
  bool _loading = true;
  String? _error;
  List<UserModel> _blockedUsers = const <UserModel>[];

  Future<void> _load() async {
    final authState = Provider.of<AuthState>(context, listen: false);
    final blackList = authState.userModel?.blackList ?? const [];

    if (blackList.isEmpty) {
      setState(() {
        _loading = false;
        _blockedUsers = const <UserModel>[];
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ids = List<String>.from(blackList);
      final results = await Future.wait(ids.map((id) => authState.getuserDetail(id)));
      final users = results.whereType<UserModel>().toList(growable: false);

      for (final u in users) {
        if (u.userId == null || u.userId!.isEmpty) u.userId = u.key;
      }

      setState(() {
        _loading = false;
        _blockedUsers = users;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
        _blockedUsers = const <UserModel>[];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = Provider.of<AuthState>(context, listen: false);
    final user = authState.userModel;

    if (user == null || user.userId == null || user.userId!.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1F2E),
        appBar: SettingsAppBar(
          title: l10n.blockedAccountsTitle,
          subtitle: '',
        ),
        body: Center(
          child: Text(
            l10n.errorGeneric,
            style: const TextStyle(color: MockupDesign.textSecondary),
          ),
        ),
      );
    }

    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(
                child: Text(
                  l10n.errorGeneric,
                  style: const TextStyle(color: MockupDesign.textSecondary),
                ),
              )
            : _blockedUsers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(MockupDesign.cardPadding),
                    child: _EmptyState(
                      title: l10n.blockedAccountsEmptyTitle,
                      subtitle: l10n.blockedAccountsEmptySubtitle,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(top: 12),
                    itemCount: _blockedUsers.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (context, index) {
                      final blocked = _blockedUsers[index];
                      final blockedId = blocked.userId ?? blocked.key ?? '';
                      final display = blocked.displayName?.trim().isNotEmpty == true
                          ? blocked.displayName!
                          : (blocked.userName?.trim().isNotEmpty == true ? blocked.userName! : blockedId);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        child: Row(
                          children: <Widget>[
                            customProfileImage(
                              context,
                              blocked.profilePic,
                              userId: blockedId,
                              height: 44,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    display,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: MockupDesign.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    blocked.userName ?? blockedId,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: MockupDesign.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppNeon.green,
                                side: BorderSide(color: AppNeon.green),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {
                                authState.addBlackList(blockedId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: const Color(0xFF2B3A2D),
                                    content: Text(l10n.unblockSuccess),
                                  ),
                                );
                                _load();
                              },
                              child: Text(
                                l10n.unblockButton,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F2E),
      appBar: SettingsAppBar(
        title: l10n.blockedAccountsTitle,
        subtitle: '',
      ),
      body: Padding(
        padding: const EdgeInsets.all(MockupDesign.screenPadding),
        child: Container(
          decoration: BoxDecoration(
            color: MockupDesign.card,
            borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
            border: Border.all(color: MockupDesign.cardBorder),
            boxShadow: MockupDesign.cardShadow,
          ),
          padding: const EdgeInsets.all(MockupDesign.cardPadding),
          child: body,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: MockupDesign.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            color: MockupDesign.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

