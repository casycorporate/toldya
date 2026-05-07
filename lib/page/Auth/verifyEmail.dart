import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/page/homePage.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/toldya_logo.dart';

/// Modern e-posta doğrulama ekranı:
///  - Açıldığında doğrulama bağlantısı sessizce gönderilir (60s spam koruması başlar).
///  - Her 3 saniyede bir `user.reload()` çağrılır, `emailVerified=true` olduğunda
///    kısa bir kutlama animasyonu sonrası `AuthState.promoteToVerifiedAndContinue()`
///    ile SplashPage rebuild edilir → `HomePage`’e şık bir geçişle yönlendirilir.
///  - "Tekrar Gönder" butonu 60 saniyelik bir geri sayım ile spam'a karşı korunur.
///  - Uygulama arka plana alındığında polling otomatik durdurulur, geri dönünce
///    anında bir kontrol yapılır ve polling yeniden başlar.
class VerifyEmailPage extends StatefulWidget {
  final VoidCallback? loginCallback;

  const VerifyEmailPage({super.key, this.loginCallback});

  @override
  State<StatefulWidget> createState() => _VerifyEmailPageState();
}

enum _VerifyStatus { checking, verified }

class _VerifyEmailPageState extends State<VerifyEmailPage>
    with WidgetsBindingObserver {
  static const Duration _pollInterval = Duration(seconds: 3);
  static const int _resendCooldownSeconds = 60;
  static const Duration _successDwell = Duration(milliseconds: 1300);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer? _pollTimer;
  Timer? _cooldownTimer;

  _VerifyStatus _status = _VerifyStatus.checking;
  int _cooldownRemaining = 0;
  bool _resendInFlight = false;
  bool _checkInFlight = false;
  bool _promotionScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _pollTimer = null;
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Arka plana alındığında polling boşa CPU/ağ harcamasın.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }
    if (state == AppLifecycleState.resumed && mounted) {
      // Kullanıcı genelde maile dokunup geri dönerken doğrulama yeni tamamlanmış olur.
      _runVerificationCheck();
      _ensurePollingStarted();
    }
  }

  Future<void> _bootstrap() async {
    final auth = Provider.of<AuthState>(context, listen: false);

    // Halihazırda doğrulanmışsa, anında geçişi tetikle (örn. kullanıcı arka plandan döndü).
    if (auth.user?.emailVerified ?? false) {
      _onVerified();
      return;
    }

    _ensurePollingStarted();
    // Açılışta otomatik bir bağlantı gönder; 60s spam koruması başlasın.
    await _sendVerificationEmail(silentSuccess: true);
  }

  void _ensurePollingStarted() {
    if (!mounted) return;
    if (_pollTimer != null && _pollTimer!.isActive) return;
    _pollTimer = Timer.periodic(_pollInterval, (_) => _runVerificationCheck());
  }

  Future<void> _runVerificationCheck() async {
    if (!mounted) return;
    if (_checkInFlight) return;
    if (_status == _VerifyStatus.verified) return;
    _checkInFlight = true;
    try {
      final auth = Provider.of<AuthState>(context, listen: false);
      final ok = await auth.reloadAndCheckEmailVerified();
      if (!mounted) return;
      if (ok) {
        _onVerified();
      }
    } finally {
      _checkInFlight = false;
    }
  }

  void _onVerified() {
    if (!mounted) return;
    if (_promotionScheduled) return;
    _promotionScheduled = true;

    _pollTimer?.cancel();
    _pollTimer = null;
    _cooldownTimer?.cancel();
    _cooldownTimer = null;

    setState(() {
      _status = _VerifyStatus.verified;
    });

    // Kısa bir kutlama animasyonu için bekle, sonra stack temizlenerek HomePage.
    Future.delayed(_successDwell, () {
      _finishVerifiedFlow();
    });
  }

  Future<void> _finishVerifiedFlow() async {
    if (!mounted) return;
    final auth = Provider.of<AuthState>(context, listen: false);
    await auth.promoteToVerifiedAndContinue();
    if (!mounted) return;
    widget.loginCallback?.call();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomePage()),
      (route) => false,
    );
  }

  Future<void> _sendVerificationEmail({bool silentSuccess = false}) async {
    if (_resendInFlight) return;
    if (_cooldownRemaining > 0) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _resendInFlight = true);
    try {
      final auth = Provider.of<AuthState>(context, listen: false);
      await auth.sendEmailVerificationSilent();
      if (!mounted) return;
      _startCooldown();
      if (!silentSuccess) {
        customSnackBar(_scaffoldKey, l10n.emailVerifyResendSuccess);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // too-many-requests: yine de cooldown başlat ki kullanıcı spamlamasın.
      if (e.code == 'too-many-requests') {
        _startCooldown();
      }
      customSnackBar(_scaffoldKey, l10n.emailVerifyResendError);
    } catch (_) {
      if (!mounted) return;
      customSnackBar(_scaffoldKey, l10n.emailVerifyResendError);
    } finally {
      if (mounted) {
        setState(() => _resendInFlight = false);
      }
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownRemaining = _resendCooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownRemaining <= 1) {
        timer.cancel();
        _cooldownTimer = null;
        setState(() => _cooldownRemaining = 0);
      } else {
        setState(() => _cooldownRemaining -= 1);
      }
    });
  }

  Future<void> _handleBack() async {
    if (_status == _VerifyStatus.verified) return;
    await _showLeaveVerificationSheet();
  }

  Future<void> _showLeaveVerificationSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColor.cardDarkBorder),
            boxShadow: MockupDesign.cardShadow,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.emailVerifyLeaveTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.emailVerifyLeaveMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                _SheetActionButton(
                  label: l10n.emailVerifyContinueWaiting,
                  icon: Icons.hourglass_bottom_rounded,
                  isPrimary: true,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
                const SizedBox(height: 10),
                _SheetActionButton(
                  label: l10n.emailVerifyChangeEmail,
                  icon: Icons.logout_rounded,
                  isPrimary: false,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _leaveVerificationFlow();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _leaveVerificationFlow() {
    final auth = Provider.of<AuthState>(context, listen: false);
    auth.logoutCallback();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/WelcomePage', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthState>(context);
    final l10n = AppLocalizations.of(context)!;
    final email = auth.user?.email ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: _handleBack,
          ),
          title: customText(
            l10n.emailVerificationTitle,
            context: context,
            style: const TextStyle(fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _status == _VerifyStatus.verified
                ? _SuccessView(key: const ValueKey('verified'))
                : _CheckingView(
                    key: const ValueKey('checking'),
                    email: email,
                    resendInFlight: _resendInFlight,
                    cooldownRemaining: _cooldownRemaining,
                    onResend: _sendVerificationEmail,
                  ),
          ),
        ),
      ),
    );
  }
}

class _CheckingView extends StatelessWidget {
  const _CheckingView({
    super.key,
    required this.email,
    required this.resendInFlight,
    required this.cooldownRemaining,
    required this.onResend,
  });

  final String email;
  final bool resendInFlight;
  final int cooldownRemaining;
  final Future<void> Function() onResend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = ToldyaColor.logoBlue;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.65);

    final hasEmail = email.trim().isNotEmpty;
    final canResend = !resendInFlight && cooldownRemaining == 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Center(
            child: ToldyaLogo(height: 56),
          ),
          const SizedBox(height: 32),
          _AnimatedRing(accent: accent),
          const SizedBox(height: 28),
          Text(
            l10n.emailVerifyAutoCheckMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 600.ms)
              .then(delay: 200.ms)
              .fade(begin: 1, end: 0.55, duration: 1200.ms),
          const SizedBox(height: 10),
          Text(
            l10n.emailVerifyAutoCheckHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          _EmailHintCard(email: hasEmail ? email : null),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(radiusMedium),
              border: Border.all(
                color: AppColor.cardDarkBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.emailVerifySpamHint,
                    style: TextStyle(color: muted, fontSize: 13, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _ResendButton(
            inFlight: resendInFlight,
            cooldownRemaining: cooldownRemaining,
            enabled: canResend,
            onPressed: canResend ? onResend : null,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  const _SheetActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background =
        isPrimary ? ToldyaColor.logoBlue : theme.colorScheme.surface;
    final foreground = isPrimary
        ? Colors.white
        : theme.colorScheme.onSurface.withValues(alpha: 0.82);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
            border: Border.all(
              color: isPrimary ? Colors.transparent : AppColor.cardDarkBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: foreground),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedRing extends StatelessWidget {
  const _AnimatedRing({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      width: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 132,
            width: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.08),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(
                  begin: 0.92,
                  end: 1.08,
                  duration: 1600.ms,
                  curve: Curves.easeInOut)
              .then()
              .scaleXY(
                  begin: 1.08,
                  end: 0.92,
                  duration: 1600.ms,
                  curve: Curves.easeInOut),
          Container(
            height: 96,
            width: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.18),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 110,
            width: 110,
            child: CircularProgressIndicator(
              strokeWidth: 3.2,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              backgroundColor: accent.withValues(alpha: 0.12),
            ),
          ),
          Icon(
            Icons.mark_email_read_outlined,
            size: 38,
            color: Colors.white,
          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
              begin: -2, end: 2, duration: 1400.ms, curve: Curves.easeInOut),
        ],
      ),
    );
  }
}

class _EmailHintCard extends StatelessWidget {
  const _EmailHintCard({required this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = ToldyaColor.logoBlue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        border: Border.all(color: AppColor.cardDarkBorder, width: 1),
        boxShadow: MockupDesign.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.alternate_email_rounded, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.emailVerifyOpenInbox,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                if (email != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.emailVerifySentTo(email!),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResendButton extends StatelessWidget {
  const _ResendButton({
    required this.inFlight,
    required this.cooldownRemaining,
    required this.enabled,
    required this.onPressed,
  });

  final bool inFlight;
  final int cooldownRemaining;
  final bool enabled;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = ToldyaColor.logoBlue;

    final String label = cooldownRemaining > 0
        ? l10n.emailVerifyResendCountdown(cooldownRemaining)
        : l10n.emailVerifyResendButton;

    final Color background = enabled ? accent : theme.colorScheme.surface;
    final Color foreground = enabled
        ? Colors.white
        : theme.colorScheme.onSurface.withValues(alpha: 0.55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => onPressed?.call() : null,
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
            border: Border.all(
              color: enabled ? Colors.transparent : AppColor.cardDarkBorder,
              width: 1,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.32),
                      offset: const Offset(0, 6),
                      blurRadius: 16,
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (inFlight) ...[
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
                  ),
                ),
                const SizedBox(width: 12),
              ] else ...[
                Icon(
                  cooldownRemaining > 0
                      ? Icons.timer_outlined
                      : Icons.refresh_rounded,
                  color: foreground,
                  size: 20,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = AppNeon.green;
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.12),
                ),
              )
                  .animate()
                  .scaleXY(
                      begin: 0.6,
                      end: 1,
                      duration: 450.ms,
                      curve: Curves.easeOutBack)
                  .fadeIn(duration: 350.ms),
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.22),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ).animate().scaleXY(
                  begin: 0.5,
                  end: 1,
                  duration: 400.ms,
                  curve: Curves.easeOutBack),
              Container(
                height: 76,
                width: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              )
                  .animate()
                  .scaleXY(
                      begin: 0.4,
                      end: 1,
                      duration: 380.ms,
                      curve: Curves.elasticOut)
                  .fadeIn(duration: 200.ms),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            l10n.emailVerifySuccessTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.2, end: 0, duration: 320.ms),
          const SizedBox(height: 10),
          Text(
            l10n.emailVerifySuccessMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.7),
              fontSize: 15,
              height: 1.4,
            ),
          ).animate(delay: 120.ms).fadeIn(duration: 320.ms),
          const SizedBox(height: 24),
          SizedBox(
            height: 26,
            width: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ).animate(delay: 220.ms).fadeIn(duration: 280.ms),
        ],
      ),
    );
  }
}

class EmailVerifiedLandingPage extends StatefulWidget {
  const EmailVerifiedLandingPage({super.key});

  @override
  State<EmailVerifiedLandingPage> createState() =>
      _EmailVerifiedLandingPageState();
}

class _EmailVerifiedLandingPageState extends State<EmailVerifiedLandingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _complete();
    });
  }

  Future<void> _complete() async {
    final auth = Provider.of<AuthState>(context, listen: false);
    await auth.getCurrentUser();
    final verified = await auth.reloadAndCheckEmailVerified();
    if (!mounted) return;
    if (verified) {
      await auth.promoteToVerifiedAndContinue();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomePage()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const VerifyEmailPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ToldyaLogo(height: 56),
                const SizedBox(height: 28),
                SizedBox(
                  height: 42,
                  width: 42,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(ToldyaColor.logoBlue),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.emailVerifyAutoCheckMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
