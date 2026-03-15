import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/state/feedState.dart';
import 'package:provider/provider.dart';

/// Onaylar sayfası: Tab'lı yapı; "Bekleyenler" sekmesinde sonuç bekleyen tahminler listelenir, admin Evet/Hayır ile onaylar.
class AdminApprovalsPage extends StatelessWidget {
  const AdminApprovalsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.adminApprovalsTitle),
          centerTitle: true,
          backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.adminTabPending),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PendingListTab(),
          ],
        ),
      ),
    );
  }
}

class _PendingListTab extends StatefulWidget {
  const _PendingListTab();

  @override
  State<_PendingListTab> createState() => _PendingListTabState();
}

class _PendingListTabState extends State<_PendingListTab> {
  List<Map<String, dynamic>> _list = [];
  bool _loading = true;
  String? _error;
  String? _busyKey;

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final feedState = Provider.of<FeedState>(context, listen: false);
      final list = await feedState.getPendingResolutionToldyas();
      if (!mounted) return;
      setState(() {
        _list = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _setResult(String key, int result) async {
    if (_busyKey != null) return;
    setState(() => _busyKey = key);
    try {
      final feedState = Provider.of<FeedState>(context, listen: false);
      await feedState.setToldyaResult(key, result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result == FeedResult.feedResultlike
              ? AppLocalizations.of(context)!.adminResultYes
              : AppLocalizations.of(context)!.adminResultNo),
          backgroundColor: ToldyaDesign.statusBadge,
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _busyKey = null);
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
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _load,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }
    if (_list.isEmpty) {
      return Center(
        child: Text(
          l10n.adminPendingEmpty,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: _list.length,
        itemBuilder: (context, index) {
          final item = _list[index];
          final key = item['key'] as String? ?? '';
          final desc = item['description'] as String? ?? '';
          final endDate = item['endDate'] as String? ?? '';
          final isBusy = _busyKey == key;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    desc,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (endDate.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${l10n.closingTimeLabel}: $endDate',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: isBusy
                            ? null
                            : () => _setResult(key, FeedResult.feedResultlike),
                        icon: isBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.thumb_up_outlined, size: 18),
                        label: Text(l10n.adminResultYes),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: isBusy
                            ? null
                            : () => _setResult(key, FeedResult.feedResultunLike),
                        icon: const Icon(Icons.thumb_down_outlined, size: 18),
                        label: Text(l10n.adminResultNo),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
