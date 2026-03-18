import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';

enum _AdminSegment { moderation, resolve, distribute }

class AdminModerationPage extends StatefulWidget {
  const AdminModerationPage({super.key});

  @override
  State<AdminModerationPage> createState() => _AdminModerationPageState();
}

class _AdminModerationPageState extends State<AdminModerationPage> {
  bool _busy = false;
  _AdminSegment _segment = _AdminSegment.moderation;

  bool _busyPreviewOracle = false;
  bool _busyPreviewQuickFix = false;
  bool _busyPreviewDistribute = false;

  // Resolve (Sonuçlandır) lazy pagination
  bool _resolveInitialLoaded = false;
  String? _resolveLastKey;
  bool _resolveHasMore = true;
  int _resolveVisibleCount = 15;
  static const int _resolveFetchChunkSize = 250;

  // Distribute (Dağıtım) lazy pagination
  bool _distributeInitialLoaded = false;
  String? _distributeLastKey;
  bool _distributeHasMore = true;
  int _distributeVisibleCount = 15;
  static const int _distributeFetchChunkSize = 250;

  String? _jobInlineError;
  String? _jobInlineSuccess;

  List<_JobCandidate> _oracleCandidates = const [];
  List<_QuickFixCandidate> _quickFixCandidates = const [];
  int _quickFixShowCount = 50;
  String _quickFixSearch = '';
  bool _quickFixOnlyEndPassed = false;
  List<_JobCandidate> _distributeCandidates = const [];
  int? _distributeTotalPoolEstimate;

  final Map<String, int> _manualResolveSelection = <String, int>{};
  final Set<String> _busyResolveIds = <String>{};
  final Set<String> _busyDistributeIds = <String>{};
  final Set<String> _busyQuickFixIds = <String>{};

  static const Color _bg = Color(0xFF1A1F2E);
  static const Color _surface = Color(0xFF252530);
  static const Color _border = Color(0xFF2C2C38);
  static const Color _danger = Color(0xFFFF6B6B);
  static const Color _success = Color(0xFF2ED573);
  // static const Color _muted = Color(0xFFA0A0B0);

  @override
  void dispose() {
    super.dispose();
  }

  String _fmtShort(String iso) {
    final t = iso.trim();
    if (t.isEmpty) return '';
    try {
      final d = DateTime.parse(t).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
    } catch (_) {
      return t;
    }
  }

  Future<({bool ok, String? code, String? message})> _moderate({
    required String toldyaId,
    required String decision,
    String? reason,
    String? topic,
    String? endDate,
    String? resolutionDate,
    String? oracleSource,
    String? oracleApiUrl,
    num? collateralAmount,
  }) async {
    if (_busy) return (ok: false, code: 'busy', message: null);
    setState(() => _busy = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('moderateToldya');
      final payload = <String, dynamic>{
        'toldyaId': toldyaId,
        'decision': decision,
        if (reason != null) 'reason': reason,
        if (topic != null) 'topic': topic,
        if (endDate != null) 'endDate': endDate,
        if (resolutionDate != null) 'resolutionDate': resolutionDate,
        if (oracleSource != null) 'oracleSource': oracleSource,
        if (oracleApiUrl != null) 'oracleApiUrl': oracleApiUrl,
        if (collateralAmount != null) 'collateralAmount': collateralAmount,
      };

      // Retry on "CONCURRENT_UPDATE_RETRY" with backoff (no snackbar/toast).
      const maxAttempts = 8;
      final rand = math.Random();
      FirebaseFunctionsException? lastFnError;

      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          await callable.call(payload);
          return (ok: true, code: null, message: null);
        } on FirebaseFunctionsException catch (e) {
          // Treat "already-exists" as success: item will drop from stream.
          if (e.code == 'already-exists') return (ok: true, code: e.code, message: e.message);
          final msg = (e.message ?? '').trim();
          final isRetryable = e.code == 'aborted' && msg == 'CONCURRENT_UPDATE_RETRY';
          if (!isRetryable) {
            lastFnError = e;
            break;
          }
          lastFnError = e;
          if (attempt >= maxAttempts) break;

          // 200, 400, 800, 1200, 1600... (cap 2000) + jitter 0-100ms
          int backoffMs;
          if (attempt <= 3) {
            backoffMs = 200 * (1 << (attempt - 1));
          } else {
            backoffMs = 800 + 400 * (attempt - 3);
          }
          backoffMs = backoffMs.clamp(200, 2000);
          final jitter = rand.nextInt(101);
          await Future<void>.delayed(Duration(milliseconds: backoffMs + jitter));
        }
      }
      if (lastFnError != null) {
        return (ok: false, code: lastFnError.code, message: lastFnError.message);
      }
      return (ok: false, code: 'aborted', message: 'CONCURRENT_UPDATE_RETRY');
    } on FirebaseFunctionsException catch (e, st) {
      // Silent failure by requirement; log for observability.
      developer.log(
        'moderateToldya failed: code=${e.code} message=${e.message} details=${e.details}',
        name: 'AdminModeration',
        error: e,
        stackTrace: st,
      );
      return (ok: false, code: e.code, message: e.message);
    } catch (e, st) {
      developer.log(
        'moderateToldya failed: $e',
        name: 'AdminModeration',
        error: e,
        stackTrace: st,
      );
      return (ok: false, code: 'unknown', message: e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  DateTime? _parseIso(String? v) {
    if (v == null) return null;
    final s = v.trim();
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  Future<DateTime?> _pickDateTime({
    required DateTime? initial,
    DateTime? firstDate,
  }) async {
    final now = DateTime.now();
    final min = firstDate ?? now;
    var base = initial ?? now.add(const Duration(hours: 1));
    if (base.isBefore(min)) base = min;
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: min,
      lastDate: DateTime(now.year + 5),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              surface: _surface,
              primary: _success,
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: _bg,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (date == null) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              surface: _surface,
              primary: _success,
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: _bg,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _approveFlow({
    required String toldyaId,
    required Map m,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final existingTopic = (m['topic']?.toString() ?? '').trim();
    final existingEnd = _parseIso(m['endDate']?.toString());
    final existingRes = _parseIso(m['resolutionDate']?.toString());
    final existingOracleApiUrl = (m['oracleApiUrl']?.toString() ?? '').trim();
    final existingOracleSource = (m['oracleSource']?.toString() ?? '').trim();
    final existingCollateral = m['collateralAmount'] is num ? (m['collateralAmount'] as num) : null;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        // NOTE: Keep these outside StatefulBuilder so setState doesn't reset them.
        String topic = existingTopic;
        DateTime? endDate = existingEnd;
        DateTime? resolutionDate = existingRes;
        final oracleApiUrlCtrl = TextEditingController(text: existingOracleApiUrl);
        final oracleSourceCtrl = TextEditingController(text: existingOracleSource);
        final collateralCtrl = TextEditingController(text: existingCollateral?.toString() ?? '');
        String? inlineError;

        bool isValid() {
          if (topic.trim().isEmpty) return false;
          if (endDate == null || resolutionDate == null) return false;
          if (!resolutionDate!.isAfter(endDate!)) return false;
          final diff = resolutionDate!.difference(endDate!);
          if (diff < const Duration(hours: 1)) return false;
          return true;
        }

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final canSubmit = isValid();
            final inputTheme = Theme.of(ctx).copyWith(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: _bg,
              cardColor: _surface,
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: _surface,
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.75)),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _success, width: 1.5),
                ),
              ),
            );
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Theme(
                data: inputTheme,
                child: Container(
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                    boxShadow: MockupDesign.cardShadow,
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.adminModerationApproveTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close, color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: (topic.isEmpty) ? null : topic,
                        items: const [
                          DropdownMenuItem(value: 'spor', child: Text('spor')),
                          DropdownMenuItem(value: 'eco', child: Text('eco')),
                          DropdownMenuItem(value: 'fun', child: Text('fun')),
                          DropdownMenuItem(value: 'politic', child: Text('politic')),
                        ],
                        onChanged: (v) => setSheetState(() {
                          topic = v ?? '';
                          inlineError = null;
                        }),
                        decoration: InputDecoration(
                          labelText: l10n.adminModerationTopicLabel,
                        ),
                        dropdownColor: _surface,
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.white70,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: _border),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () async {
                                final picked = await _pickDateTime(initial: endDate, firstDate: DateTime.now());
                                if (picked == null) return;
                                setSheetState(() {
                                  endDate = picked;
                                  inlineError = null;
                                  if (resolutionDate != null && !resolutionDate!.isAfter(endDate!)) {
                                    resolutionDate = null;
                                  }
                                });
                              },
                              icon: const Icon(Icons.event, size: 18),
                              label: Text(
                                endDate == null ? l10n.adminModerationEndDateLabel : endDate!.toLocal().toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: _border),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: (endDate == null)
                                  ? null
                                  : () async {
                                      final picked = await _pickDateTime(initial: resolutionDate, firstDate: endDate);
                                      if (picked == null) return;
                                      setSheetState(() {
                                        resolutionDate = picked;
                                        inlineError = null;
                                      });
                                    },
                              icon: const Icon(Icons.flag_outlined, size: 18),
                              label: Text(
                                resolutionDate == null ? l10n.adminModerationResolutionDateLabel : resolutionDate!.toLocal().toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: oracleSourceCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(labelText: l10n.adminModerationOracleSourceOptional),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: oracleApiUrlCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(labelText: l10n.adminModerationOracleApiUrlOptional),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: collateralCtrl,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.adminModerationCollateralOptional),
                      ),
                      if (inlineError != null) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            inlineError!,
                            style: const TextStyle(color: _danger, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: canSubmit
                              ? () async {
                                  setSheetState(() => inlineError = null);
                                  if (!isValid()) {
                                    setSheetState(() => inlineError = l10n.adminModerationInvalidForm);
                                    return;
                                  }
                                  if (endDate != null && resolutionDate != null) {
                                    final diff = resolutionDate!.difference(endDate!);
                                    if (diff < const Duration(hours: 1)) {
                                      setSheetState(() => inlineError = l10n.adminModerationDateRule);
                                      return;
                                    }
                                  }
                                  final collateralText = collateralCtrl.text.trim();
                                  num? collateral;
                                  if (collateralText.isNotEmpty) collateral = num.tryParse(collateralText);
                                  final out = await _moderate(
                                    toldyaId: toldyaId,
                                    decision: 'approve',
                                    topic: topic.trim(),
                                    endDate: endDate!.toUtc().toIso8601String(),
                                    resolutionDate: resolutionDate!.toUtc().toIso8601String(),
                                    oracleSource: oracleSourceCtrl.text.trim().isEmpty ? null : oracleSourceCtrl.text.trim(),
                                    oracleApiUrl: oracleApiUrlCtrl.text.trim().isEmpty ? null : oracleApiUrlCtrl.text.trim(),
                                    collateralAmount: collateral,
                                  );
                                  if (!mounted) return;
                                  if (out.ok) {
                                    Navigator.of(ctx).pop();
                                  } else {
                                    if (out.code == 'aborted' && (out.message ?? '').trim() == 'CONCURRENT_UPDATE_RETRY') {
                                      setSheetState(() => inlineError = l10n.adminModerationConflictRetry);
                                    } else {
                                      setSheetState(() => inlineError = out.message ?? l10n.adminModerationActionFailed);
                                    }
                                  }
                                }
                              : null,
                          child: Text(l10n.adminModerationApprove),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _rejectFlow(String toldyaId) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminModerationReject),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10n.adminModerationRejectReasonHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(null),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(controller.text.trim()),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (!mounted) {
      controller.dispose();
      return;
    }
    controller.dispose();
    if (result == null || result.isEmpty) return;
    await _moderate(toldyaId: toldyaId, decision: 'reject', reason: result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = FirebaseDatabase.instance.ref('toldya');

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          _segment == _AdminSegment.moderation
              ? l10n.adminModeration
              : l10n.adminJobsTitle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SegmentedButton<_AdminSegment>(
              segments: <ButtonSegment<_AdminSegment>>[
                ButtonSegment<_AdminSegment>(
                  value: _AdminSegment.moderation,
                  label: Text(l10n.adminSegmentModeration),
                  icon: const Icon(Icons.gavel_rounded),
                ),
                ButtonSegment<_AdminSegment>(
                  value: _AdminSegment.resolve,
                  label: Text(l10n.adminSegmentResolve),
                  icon: const Icon(Icons.fact_check_rounded),
                ),
                ButtonSegment<_AdminSegment>(
                  value: _AdminSegment.distribute,
                  label: Text(l10n.adminSegmentDistribute),
                  icon: const Icon(Icons.payments_rounded),
                ),
              ],
              selected: <_AdminSegment>{_segment},
              showSelectedIcon: false,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return _surface;
                  return Colors.transparent;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return Colors.white;
                  return Colors.white70;
                }),
                side: WidgetStateProperty.all(BorderSide(color: _border)),
              ),
              onSelectionChanged: (s) {
                if (s.isEmpty) return;
                setState(() {
                  _segment = s.first;
                  _jobInlineError = null;
                  _jobInlineSuccess = null;
                });
              },
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _segment.index,
              children: [
                AbsorbPointer(
                  absorbing: _busy,
                  child: _moderationPanel(l10n: l10n, db: db),
                ),
                _resolvePanel(l10n: l10n),
                _distributePanel(l10n: l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moderationPanel({required AppLocalizations l10n, required DatabaseReference db}) {
    return StreamBuilder<DatabaseEvent>(
      stream: db.orderByChild('statu').equalTo(6).onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: _success));
        }
        final data = snapshot.data!.snapshot.value;
        if (data is! Map) {
          return Center(
            child: Text(
              l10n.adminModerationQueueEmpty,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          );
        }
        final items = <MapEntry<String, dynamic>>[];
        data.forEach((k, v) {
          if (k == null || v == null) return;
          if (v is Map && (v['parentkey'] == null) && (v['manualModerationAt'] == null)) {
            items.add(MapEntry(k.toString(), v));
          }
        });
        if (items.isEmpty) {
          return Center(
            child: Text(
              l10n.adminModerationQueueEmpty,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          );
        }

        items.sort((a, b) {
          final aAt = a.value is Map ? (a.value['createdAt']?.toString() ?? '') : '';
          final bAt = b.value is Map ? (b.value['createdAt']?.toString() ?? '') : '';
          return bAt.compareTo(aAt);
        });

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            final id = items[i].key;
            final m = items[i].value as Map;
            final desc = (m['description']?.toString() ?? '').trim();
            final userId = m['userId']?.toString() ?? '';
            final createdAt = m['createdAt']?.toString() ?? '';
            final topic = (m['topic']?.toString() ?? '').trim();
            final oracleApiUrl = (m['oracleApiUrl']?.toString() ?? '').trim();
            return Container(
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
                boxShadow: MockupDesign.cardShadow,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      desc.isEmpty ? l10n.post : desc,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (userId.isNotEmpty) _metaChip('${l10n.adminModerationMetaUser}: $userId'),
                        if (createdAt.isNotEmpty) _metaChip('${l10n.adminModerationMetaCreatedAt}: ${_fmtShort(createdAt)}'),
                        if (topic.isNotEmpty) _metaChip('${l10n.adminModerationMetaTopic}: $topic'),
                        if (oracleApiUrl.isNotEmpty) _metaChip('${l10n.adminModerationMetaOracleApiUrl}: $oracleApiUrl'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => _approveFlow(toldyaId: id, m: m),
                            icon: const Icon(Icons.check, size: 18),
                            label: Text(l10n.adminModerationApprove),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _danger,
                              side: const BorderSide(color: _danger),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => _rejectFlow(id),
                            icon: const Icon(Icons.close, size: 18),
                            label: Text(l10n.adminModerationReject),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _resolveManually({required AppLocalizations l10n, required String toldyaId, required int feedResult}) async {
    if (_busyResolveIds.contains(toldyaId)) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _busyResolveIds.add(toldyaId);
      _jobInlineError = null;
      _jobInlineSuccess = null;
    });
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('adminResolveToldya');
      await callable.call(<String, dynamic>{'toldyaId': toldyaId, 'feedResult': feedResult});
      setState(() {
        _oracleCandidates = _oracleCandidates.where((c) => c.id != toldyaId).toList(growable: false);
        _manualResolveSelection.remove(toldyaId);
        _jobInlineSuccess = l10n.adminResolveManualSuccess;
      });
    } on FirebaseFunctionsException catch (e) {
      setState(() => _jobInlineError = l10n.adminJobErrorWithMessage(e.message ?? e.code));
    } catch (e) {
      setState(() => _jobInlineError = l10n.adminJobErrorWithMessage(e.toString()));
    } finally {
      if (mounted) setState(() => _busyResolveIds.remove(toldyaId));
    }
  }

  Future<void> _distributeOne({required AppLocalizations l10n, required String toldyaId}) async {
    if (_busyDistributeIds.contains(toldyaId)) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _busyDistributeIds.add(toldyaId);
      _jobInlineError = null;
      _jobInlineSuccess = null;
    });
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('adminDistributeWinningsForToldya');
      final res = await callable.call(<String, dynamic>{'toldyaId': toldyaId});
      final data = (res.data is Map) ? Map<String, dynamic>.from(res.data as Map) : const <String, dynamic>{};
      final distributed = data['distributed'];
      final did = (distributed is num) ? distributed.toInt() : int.tryParse(distributed?.toString() ?? '') ?? 0;
      setState(() {
        _distributeCandidates = _distributeCandidates.where((c) => c.id != toldyaId).toList(growable: false);
        _jobInlineSuccess = did > 0 ? l10n.adminDistributeManualSuccess : l10n.adminDistributeManualNoop;
      });
    } on FirebaseFunctionsException catch (e) {
      setState(() => _jobInlineError = l10n.adminJobErrorWithMessage(e.message ?? e.code));
    } catch (e) {
      setState(() => _jobInlineError = l10n.adminJobErrorWithMessage(e.toString()));
    } finally {
      if (mounted) setState(() => _busyDistributeIds.remove(toldyaId));
    }
  }

  Future<void> _previewOracleCandidates(AppLocalizations l10n) async {
    if (_busyPreviewOracle) return;
    if (_resolveInitialLoaded) return;

    setState(() {
      _jobInlineError = null;
      _jobInlineSuccess = null;
      _oracleCandidates = const [];
      _resolveLastKey = null;
      _resolveHasMore = true;
      _resolveVisibleCount = 15;
      _resolveInitialLoaded = true;
    });

    await _loadMoreOracleCandidates(l10n);
  }

  Future<void> _loadMoreOracleCandidates(AppLocalizations l10n) async {
    if (_busyPreviewOracle) return;
    if (!_resolveHasMore) return;

    final prevLen = _oracleCandidates.length;
    setState(() {
      _busyPreviewOracle = true;
      _jobInlineError = null;
      // keep inline success for a short time
    });

    try {
      Query query = FirebaseDatabase.instance.ref('toldya').orderByKey();
      if (_resolveLastKey != null) {
        query = query.startAfter(_resolveLastKey);
      }
      query = query.limitToFirst(_resolveFetchChunkSize);

      final snap = await query.get();
      final now = DateTime.now().toUtc();
      final out = <_JobCandidate>[];
      String? lastKey;
      var fetchedCount = 0;
      for (final child in snap.children) {
        fetchedCount++;
        lastKey = child.key;
        final v = child.value;
        if (v == null || v is! Map) continue;
        if (v['parentkey'] != null) continue;

        final statu = v['statu'];
        if (!(statu == 5 || statu == 1 || statu == '5' || statu == '1')) continue;

        // feedResult should be null/missing to be eligible
        if (v['feedResult'] != null) continue;

        final resIso = (v['resolutionDate']?.toString() ?? '').trim();
        if (resIso.isEmpty) continue;

        DateTime resAt;
        try {
          resAt = DateTime.parse(resIso).toUtc();
        } catch (_) {
          continue;
        }
        if (!resAt.isBefore(now)) continue;

        final desc = (v['description']?.toString() ?? '').trim();
        final oracleApiUrl = (v['oracleApiUrl']?.toString() ?? '').trim();

        out.add(_JobCandidate(
          id: child.key ?? '',
          description: desc,
          resolutionDateIso: resIso,
          statu: statu.toString(),
          hasOracleApiUrl: oracleApiUrl.isNotEmpty,
        ));
      }

      if (!mounted) return;
      setState(() {
        _oracleCandidates = [..._oracleCandidates, ...out];
        _oracleCandidates.sort((a, b) => a.resolutionDateIso.compareTo(b.resolutionDateIso));
        _resolveLastKey = lastKey;
        if (fetchedCount < _resolveFetchChunkSize) {
          _resolveHasMore = false;
        }
        final shouldExpand = prevLen > 0 && _resolveVisibleCount >= prevLen;
        _resolveVisibleCount = shouldExpand
            ? math.min(_resolveVisibleCount + 15, _oracleCandidates.length)
            : _resolveVisibleCount.clamp(0, _oracleCandidates.length);
      });
    } catch (e) {
      setState(() => _jobInlineError = l10n.adminJobErrorWithMessage(e.toString()));
    } finally {
      if (mounted) setState(() => _busyPreviewOracle = false);
    }
  }

  bool _isValidIsoUtc(String? v) {
    if (v == null) return false;
    final s = v.trim();
    if (s.isEmpty) return false;
    try {
      DateTime.parse(s);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _isEndDatePassedUtc(String? endIso) {
    if (!_isValidIsoUtc(endIso)) return false;
    try {
      final d = DateTime.parse(endIso!).toUtc();
      return d.isBefore(DateTime.now().toUtc());
    } catch (_) {
      return false;
    }
  }

  Future<void> _previewQuickFixCandidates(AppLocalizations l10n) async {
    if (_busyPreviewQuickFix) return;
    setState(() {
      _busyPreviewQuickFix = true;
      _jobInlineError = null;
      _jobInlineSuccess = null;
    });
    try {
      final snap = await FirebaseDatabase.instance.ref('toldya').get();
      final val = snap.value;
      final out = <_QuickFixCandidate>[];
      if (val is Map) {
        val.forEach((k, v) {
          if (k == null || v == null || v is! Map) return;
          if (v['parentkey'] != null) return;
          final statu = v['statu'];
          if (!(statu == 1 || statu == '1')) return;

          final resIso = (v['resolutionDate']?.toString() ?? '').trim();
          final resOk = _isValidIsoUtc(resIso);
          if (resOk) return; // not broken

          final endIso = (v['endDate']?.toString() ?? '').trim();
          final endOk = _isValidIsoUtc(endIso);
          final endPassed = endOk ? _isEndDatePassedUtc(endIso) : false;

          final createdAt = (v['createdAt']?.toString() ?? '').trim();
          final desc = (v['description']?.toString() ?? '').trim();
          final topic = (v['topic']?.toString() ?? '').trim();

          out.add(_QuickFixCandidate(
            id: k.toString(),
            description: desc,
            createdAtIso: createdAt,
            endDateIso: endIso,
            resolutionDateIso: resIso,
            endDateOk: endOk,
            endDatePassed: endPassed,
            resolutionDateOk: resOk,
            topicMissing: topic.isEmpty,
          ));
        });
      }
      out.sort((a, b) {
        // prioritize endDate passed first, then by createdAt
        final ap = a.endDatePassed ? 0 : 1;
        final bp = b.endDatePassed ? 0 : 1;
        if (ap != bp) return ap.compareTo(bp);
        return a.createdAtIso.compareTo(b.createdAtIso);
      });
      setState(() {
        _quickFixCandidates = out;
        _quickFixShowCount = 50;
      });
    } catch (e) {
      setState(() => _jobInlineError = l10n.adminJobErrorWithMessage(e.toString()));
    } finally {
      if (mounted) setState(() => _busyPreviewQuickFix = false);
    }
  }

  List<_QuickFixCandidate> _filteredQuickFixList({required bool all}) {
    final q = _quickFixSearch.trim().toLowerCase();
    Iterable<_QuickFixCandidate> it = _quickFixCandidates;
    if (_quickFixOnlyEndPassed) {
      it = it.where((c) => c.endDatePassed);
    }
    if (q.isNotEmpty) {
      it = it.where((c) => c.id.toLowerCase().contains(q) || c.description.toLowerCase().contains(q));
    }
    final list = it.toList(growable: false);
    if (all) return list;
    final n = _quickFixShowCount.clamp(0, list.length);
    return list.take(n).toList(growable: false);
  }

  Future<void> _openQuickFixSheet({required AppLocalizations l10n, required _QuickFixCandidate c}) async {
    DateTime? endDate = _parseIso(c.endDateIso)?.toUtc();
    DateTime? resolutionDate = _parseIso(c.resolutionDateIso)?.toUtc();
    String? inlineError;
    bool busy = false;
    bool publishConfirm = false;

    void setErr(StateSetter setModal, String? v) => setModal(() => inlineError = v);

    String? validateDates({required bool requireEnd, required bool requireRes}) {
      if (requireEnd && endDate == null) return l10n.adminQuickFixValidationEndRequired;
      if (requireRes && resolutionDate == null) return l10n.adminQuickFixValidationResolutionRequired;
      if (endDate != null && resolutionDate != null) {
        if (!resolutionDate!.isAfter(endDate!)) return l10n.adminQuickFixValidationResolutionAfterEnd;
        if (resolutionDate!.difference(endDate!).inMinutes < 60) return l10n.adminQuickFixValidationMin1h;
      }
      return null;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setModal) {
          final safeBottom = MediaQuery.of(ctx2).viewInsets.bottom;
          final endTxt = endDate == null ? '—' : _fmtShort(endDate!.toIso8601String());
          final resTxt = resolutionDate == null ? '—' : _fmtShort(resolutionDate!.toIso8601String());

          Future<void> doWrite({required bool publish}) async {
            if (_busyQuickFixIds.contains(c.id) || busy) return;
            final err = validateDates(requireEnd: publish, requireRes: true);
            if (err != null) {
              setErr(setModal, err);
              return;
            }
            if (publish && !publishConfirm) {
              setErr(setModal, l10n.adminQuickFixWarningPublish);
              return;
            }

            HapticFeedback.mediumImpact();
            setModal(() {
              busy = true;
              inlineError = null;
            });
            setState(() => _busyQuickFixIds.add(c.id));
            try {
              final updates = <String, dynamic>{
                if (endDate != null) 'endDate': endDate!.toUtc().toIso8601String(),
                'resolutionDate': resolutionDate!.toUtc().toIso8601String(),
                if (publish) 'statu': 0,
              };
              await FirebaseDatabase.instance.ref('toldya/${c.id}').update(updates);
              setState(() {
                _quickFixCandidates = _quickFixCandidates.where((x) => x.id != c.id).toList(growable: false);
                _jobInlineSuccess = l10n.adminQuickFixSuccess;
              });
              if (mounted) Navigator.of(ctx2).pop();
            } catch (e) {
              setErr(setModal, l10n.adminJobErrorWithMessage(e.toString()));
            } finally {
              if (mounted) {
                setState(() => _busyQuickFixIds.remove(c.id));
                setModal(() => busy = false);
              }
            }
          }

          return Padding(
            padding: EdgeInsets.only(bottom: safeBottom),
            child: Container(
              decoration: const BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(c.id, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(
                        c.description.isEmpty ? '-' : c.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, height: 1.2),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                        ),
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Text(
                          l10n.adminQuickFixWarningPublish,
                          style: TextStyle(color: Colors.white.withOpacity(0.78), fontSize: 12, height: 1.25),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: _border),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: busy
                                  ? null
                                  : () async {
                                      final picked = await _pickDateTime(initial: endDate?.toLocal(), firstDate: DateTime.now());
                                      if (picked == null) return;
                                      setModal(() {
                                        endDate = picked.toUtc();
                                        inlineError = null;
                                        publishConfirm = false;
                                      });
                                    },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.adminQuickFixEndDateLabel, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Text(endTxt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: _border),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: busy
                                  ? null
                                  : () async {
                                      final min = endDate != null ? endDate!.toLocal() : DateTime.now();
                                      final picked = await _pickDateTime(initial: resolutionDate?.toLocal(), firstDate: min);
                                      if (picked == null) return;
                                      setModal(() {
                                        resolutionDate = picked.toUtc();
                                        inlineError = null;
                                        publishConfirm = false;
                                      });
                                    },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.adminQuickFixResolutionDateLabel,
                                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Text(resTxt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: busy
                                  ? null
                                  : () {
                                      final now = DateTime.now().toUtc().add(const Duration(minutes: 5));
                                      setModal(() {
                                        endDate ??= now;
                                        inlineError = null;
                                        publishConfirm = false;
                                      });
                                    },
                              child: Text(l10n.adminQuickFixAutofillEndNowPlus),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: busy
                                  ? null
                                  : () {
                                      final base = (endDate ?? DateTime.now().toUtc().add(const Duration(minutes: 5)));
                                      setModal(() {
                                        endDate ??= base;
                                        resolutionDate = base.add(const Duration(hours: 1));
                                        inlineError = null;
                                        publishConfirm = false;
                                      });
                                    },
                              child: Text(l10n.adminQuickFixAutofillResolutionPlus1h),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (inlineError != null) _inlineBanner(inlineError!, isError: true),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: publishConfirm,
                        onChanged: busy ? null : (v) => setModal(() => publishConfirm = v ?? false),
                        activeColor: _success,
                        title: Text(
                          l10n.adminQuickFixConfirmPublish,
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: _border),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: busy ? null : () => doWrite(publish: false),
                              child: Text(l10n.adminQuickFixSetOnly),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: busy ? null : () => doWrite(publish: true),
                              child: busy
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text(l10n.adminQuickFixSetAndPublish),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _previewDistributeCandidates(AppLocalizations l10n) async {
    if (_busyPreviewDistribute) return;
    if (_distributeInitialLoaded) return;

    setState(() {
      _jobInlineError = null;
      _jobInlineSuccess = null;
      _distributeCandidates = const [];
      _distributeTotalPoolEstimate = null;
      _distributeLastKey = null;
      _distributeHasMore = true;
      _distributeVisibleCount = 15;
      _distributeInitialLoaded = true;
    });

    await _loadMoreDistributeCandidates(l10n);
  }

  Future<void> _loadMoreDistributeCandidates(AppLocalizations l10n) async {
    if (_busyPreviewDistribute) return;
    if (!_distributeHasMore) return;

    final prevLen = _distributeCandidates.length;
    setState(() {
      _busyPreviewDistribute = true;
      _jobInlineError = null;
    });

    try {
      Query query = FirebaseDatabase.instance.ref('toldya').orderByKey();
      if (_distributeLastKey != null) {
        query = query.startAfter(_distributeLastKey);
      }
      query = query.limitToFirst(_distributeFetchChunkSize);

      final snap = await query.get();

      final out = <_JobCandidate>[];
      var totalPoolAdd = 0;
      String? lastKey;
      var fetchedCount = 0;

      for (final child in snap.children) {
        fetchedCount++;
        lastKey = child.key;
        final v = child.value;
        if (v == null || v is! Map) continue;
        if (v['parentkey'] != null) continue;

        final statu = v['statu'];
        if (!(statu == 2 || statu == '2')) continue;

        final feedResult = v['feedResult'];
        final okResult = (feedResult == 1 || feedResult == 2 || feedResult == '1' || feedResult == '2');
        if (!okResult) continue;

        if (v['distributionDone'] == true || v['distributionDone'] == 1 || v['distributionDone'] == 'true') continue;

        final desc = (v['description']?.toString() ?? '').trim();
        final resIso = (v['resolutionDate']?.toString() ?? '').trim();
        final oracleApiUrl = (v['oracleApiUrl']?.toString() ?? '').trim();
        out.add(_JobCandidate(
          id: child.key ?? '',
          description: desc,
          resolutionDateIso: resIso,
          statu: statu.toString(),
          hasOracleApiUrl: oracleApiUrl.isNotEmpty,
        ));

        totalPoolAdd += _sumPegList(v['likeList']);
        totalPoolAdd += _sumPegList(v['unlikeList']);
      }

      if (!mounted) return;
      setState(() {
        _distributeCandidates = [..._distributeCandidates, ...out];
        _distributeTotalPoolEstimate = (_distributeTotalPoolEstimate ?? 0) + totalPoolAdd;
        _distributeLastKey = lastKey;
        if (fetchedCount < _distributeFetchChunkSize) _distributeHasMore = false;
        final shouldExpand = prevLen > 0 && _distributeVisibleCount >= prevLen;
        _distributeVisibleCount = shouldExpand
            ? math.min(_distributeVisibleCount + 15, _distributeCandidates.length)
            : _distributeVisibleCount.clamp(0, _distributeCandidates.length);
      });
    } catch (e) {
      setState(() => _jobInlineError = l10n.adminJobErrorWithMessage(e.toString()));
    } finally {
      if (mounted) setState(() => _busyPreviewDistribute = false);
    }
  }

  int _sumPegList(dynamic list) {
    var sum = 0;
    if (list is List) {
      for (final it in list) {
        if (it is Map) {
          final v = it['pegCount'];
          if (v is num) sum += v.toInt();
          if (v is String) sum += int.tryParse(v) ?? 0;
        }
      }
    }
    return sum;
  }

  Widget _resolvePanel({required AppLocalizations l10n}) {
    if (!_resolveInitialLoaded && !_busyPreviewOracle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _previewOracleCandidates(l10n);
      });
    }

    final loadedCount = _oracleCandidates.length;
    final shown = _oracleCandidates.take(_resolveVisibleCount).toList(growable: false);

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        final metrics = scroll.metrics;
        final nearBottom = metrics.pixels >= metrics.maxScrollExtent - 250;
        if (!nearBottom) return false;
        if (_busyPreviewOracle) return false;

        if (!_resolveInitialLoaded && _oracleCandidates.isEmpty) {
          _previewOracleCandidates(l10n);
          return false;
        }

        if (_resolveVisibleCount < _oracleCandidates.length) {
          setState(() => _resolveVisibleCount = (_resolveVisibleCount + 15).clamp(0, _oracleCandidates.length));
          return false;
        }

        if (_resolveHasMore) {
          _loadMoreOracleCandidates(l10n);
        }
        return false;
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _panelHeader(title: l10n.adminResolveTitle, desc: l10n.adminResolveDesc),
          const SizedBox(height: 12),
          if (_jobInlineError != null) _inlineBanner(_jobInlineError!, isError: true),
          if (_jobInlineSuccess != null) _inlineBanner(_jobInlineSuccess!, isError: false),

          if (_busyPreviewOracle && loadedCount == 0) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator(color: _success)),
          ],

          if (loadedCount > 0) ...[
            const SizedBox(height: 12),
            _inlineBanner(l10n.adminPreviewCandidates('$loadedCount'), isError: false, subtle: true),
            const SizedBox(height: 10),
            ...shown.map((c) => _resolveCandidateTile(l10n: l10n, c: c)),
          ],

          if (_busyPreviewOracle && loadedCount > 0) ...[
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator(color: _success)),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _quickFixPanel({required AppLocalizations l10n}) {
    final total = _quickFixCandidates.length;
    final filteredAll = _filteredQuickFixList(all: true);
    final shown = _filteredQuickFixList(all: false);
    final canLoadMore = shown.length < filteredAll.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _panelHeader(title: l10n.adminQuickFixTitle, desc: l10n.adminQuickFixDesc),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: _border),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _busyPreviewQuickFix ? null : () => _previewQuickFixCandidates(l10n),
          icon: _busyPreviewQuickFix
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _success))
              : const Icon(Icons.preview_rounded, size: 18),
          label: Text(l10n.adminResolvePreviewButton),
        ),
        const SizedBox(height: 12),
        if (_jobInlineError != null) _inlineBanner(_jobInlineError!, isError: true),
        if (_jobInlineSuccess != null) _inlineBanner(_jobInlineSuccess!, isError: false),
        if (total > 0) ...[
          const SizedBox(height: 10),
          _inlineBanner(l10n.adminQuickFixCount('$total'), isError: false, subtle: true),
          const SizedBox(height: 10),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: l10n.adminQuickFixSearchHint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: _surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _success, width: 1.5),
              ),
            ),
            onChanged: (v) => setState(() {
              _quickFixSearch = v;
              _quickFixShowCount = 50;
            }),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _quickFixOnlyEndPassed,
            onChanged: (v) => setState(() {
              _quickFixOnlyEndPassed = v;
              _quickFixShowCount = 50;
            }),
            activeColor: _success,
            title: Text(
              l10n.adminQuickFixFilterEndDatePassed,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 10),
          ...shown.map((c) => _quickFixTile(l10n: l10n, c: c)),
          if (shown.length < (_quickFixOnlyEndPassed || _quickFixSearch.trim().isNotEmpty ? shown.length : total)) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _quickFixShowCount += 50),
                child: Text(l10n.adminJobShowMore),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _quickFixTile({required AppLocalizations l10n, required _QuickFixCandidate c}) {
    final endStatus = c.endDateIso.trim().isEmpty
        ? l10n.adminQuickFixChipEndMissing
        : (c.endDateOk ? (c.endDatePassed ? l10n.adminQuickFixChipEndPassed : l10n.adminQuickFixChipEndOk) : l10n.adminQuickFixChipEndInvalid);
    final resStatus = c.resolutionDateIso.trim().isEmpty ? l10n.adminQuickFixChipResMissing : l10n.adminQuickFixChipResInvalid;
    final chips = <Widget>[
      _metaChip(l10n.adminQuickFixChipStatu1),
      _metaChip(endStatus),
      _metaChip(resStatus),
      if (c.topicMissing) _metaChip(l10n.adminQuickFixChipTopicMissing),
    ];

    return InkWell(
      onTap: _busyQuickFixIds.contains(c.id) ? null : () => _openQuickFixSheet(l10n: l10n, c: c),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    c.id,
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
                if (_busyQuickFixIds.contains(c.id))
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _success)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              c.description.isEmpty ? '-' : c.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
            if (c.createdAtIso.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                l10n.adminQuickFixCreatedAt(_fmtShort(c.createdAtIso)),
                style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: chips),
          ],
        ),
      ),
    );
  }

  Widget _distributePanel({required AppLocalizations l10n}) {
    if (!_distributeInitialLoaded && !_busyPreviewDistribute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _previewDistributeCandidates(l10n);
      });
    }

    final loadedCount = _distributeCandidates.length;
    final shown = _distributeCandidates.take(_distributeVisibleCount).toList(growable: false);

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        final metrics = scroll.metrics;
        final nearBottom = metrics.pixels >= metrics.maxScrollExtent - 250;
        if (!nearBottom) return false;
        if (_busyPreviewDistribute) return false;

        if (!_distributeInitialLoaded && _distributeCandidates.isEmpty) {
          _previewDistributeCandidates(l10n);
          return false;
        }

        if (_distributeVisibleCount < _distributeCandidates.length) {
          setState(() => _distributeVisibleCount = (_distributeVisibleCount + 15).clamp(0, _distributeCandidates.length));
          return false;
        }

        if (_distributeHasMore) {
          _loadMoreDistributeCandidates(l10n);
        }
        return false;
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _panelHeader(title: l10n.adminDistributeTitle, desc: l10n.adminDistributeDesc),
          const SizedBox(height: 6),
          Text(
            l10n.adminDistributeIdempotentNote,
            style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12, height: 1.25),
          ),
          const SizedBox(height: 12),
          if (_jobInlineError != null) _inlineBanner(_jobInlineError!, isError: true),
          if (_jobInlineSuccess != null) _inlineBanner(_jobInlineSuccess!, isError: false),

          if (_busyPreviewDistribute && loadedCount == 0) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator(color: _success)),
          ],

          if (loadedCount > 0) ...[
            const SizedBox(height: 12),
            _inlineBanner(l10n.adminPreviewCandidates('$loadedCount'), isError: false, subtle: true),
            if (_distributeTotalPoolEstimate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.adminDistributeTotalPoolEstimate('${_distributeTotalPoolEstimate ?? 0}'),
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            const SizedBox(height: 10),
            ...shown.map((c) => _distributeCandidateTile(l10n: l10n, c: c)),
          ],

          if (_busyPreviewDistribute && loadedCount > 0) ...[
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator(color: _success)),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _panelHeader({required String title, required String desc}) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: MockupDesign.cardShadow,
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.25)),
        ],
      ),
    );
  }

  Widget _inlineBanner(String text, {required bool isError, bool subtle = false}) {
    final bg = isError ? _danger.withOpacity(0.12) : _success.withOpacity(subtle ? 0.10 : 0.14);
    final border = isError ? _danger.withOpacity(0.35) : _success.withOpacity(0.35);
    final fg = isError ? _danger : _success;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, height: 1.2),
      ),
    );
  }

  Widget _candidateTile(_JobCandidate c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.id,
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            c.description.isEmpty ? '-' : c.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (c.resolutionDateIso.isNotEmpty) _metaChip('resolution: ${_fmtShort(c.resolutionDateIso)}'),
              _metaChip('statu: ${c.statu}'),
              _metaChip('oracleApiUrl: ${c.hasOracleApiUrl ? '✓' : '—'}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resolveCandidateTile({required AppLocalizations l10n, required _JobCandidate c}) {
    final selected = _manualResolveSelection[c.id];
    final busy = _busyResolveIds.contains(c.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.id,
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            c.description.isEmpty ? '-' : c.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, height: 1.2),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (c.resolutionDateIso.isNotEmpty) _metaChip('resolution: ${_fmtShort(c.resolutionDateIso)}'),
              _metaChip('statu: ${c.statu}'),
              _metaChip('oracleApiUrl: ${c.hasOracleApiUrl ? '✓' : '—'}'),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            emptySelectionAllowed: true,
            segments: <ButtonSegment<int>>[
              ButtonSegment<int>(
                value: FeedResult.feedResultlike,
                label: Text(l10n.adminResolveManualYes),
                icon: const Icon(Icons.thumb_up_alt_rounded, size: 18),
              ),
              ButtonSegment<int>(
                value: FeedResult.feedResultunLike,
                label: Text(l10n.adminResolveManualNo),
                icon: const Icon(Icons.thumb_down_alt_rounded, size: 18),
              ),
            ],
            selected: selected == null ? <int>{} : <int>{selected},
            onSelectionChanged: busy
                ? null
                : (set) {
                    final v = set.isEmpty ? null : set.first;
                    setState(() {
                      if (v == null) {
                        _manualResolveSelection.remove(c.id);
                      } else {
                        _manualResolveSelection[c.id] = v;
                      }
                    });
                  },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white.withOpacity(0.10);
                return Colors.white.withOpacity(0.04);
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return Colors.white.withOpacity(0.85);
              }),
              side: WidgetStatePropertyAll(BorderSide(color: Colors.white.withOpacity(0.10))),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: selected == FeedResult.feedResultlike
                    ? const Color(0xFF2ED573)
                    : (selected == FeedResult.feedResultunLike ? const Color(0xFFFF4757) : _border),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: (selected == null || busy)
                  ? null
                  : () => _resolveManually(l10n: l10n, toldyaId: c.id, feedResult: selected),
              icon: busy
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(l10n.adminResolveManualApply),
            ),
          ),
        ],
      ),
    );
  }

  Widget _distributeCandidateTile({required AppLocalizations l10n, required _JobCandidate c}) {
    final busy = _busyDistributeIds.contains(c.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.id,
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            c.description.isEmpty ? '-' : c.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, height: 1.2),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (c.resolutionDateIso.isNotEmpty) _metaChip('resolution: ${_fmtShort(c.resolutionDateIso)}'),
              _metaChip('statu: ${c.statu}'),
              _metaChip('oracleApiUrl: ${c.hasOracleApiUrl ? '✓' : '—'}'),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: busy ? null : () => _distributeOne(l10n: l10n, toldyaId: c.id),
              icon: busy
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.payments_rounded, size: 18),
              label: Text(l10n.adminDistributeManualApply),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.75),
        ),
      ),
    );
  }
}

class _JobCandidate {
  final String id;
  final String description;
  final String resolutionDateIso;
  final String statu;
  final bool hasOracleApiUrl;

  const _JobCandidate({
    required this.id,
    required this.description,
    required this.resolutionDateIso,
    required this.statu,
    required this.hasOracleApiUrl,
  });
}

class _QuickFixCandidate {
  final String id;
  final String description;
  final String createdAtIso;
  final String endDateIso;
  final String resolutionDateIso;
  final bool endDateOk;
  final bool endDatePassed;
  final bool resolutionDateOk;
  final bool topicMissing;

  const _QuickFixCandidate({
    required this.id,
    required this.description,
    required this.createdAtIso,
    required this.endDateIso,
    required this.resolutionDateIso,
    required this.endDateOk,
    required this.endDatePassed,
    required this.resolutionDateOk,
    required this.topicMissing,
  });
}

