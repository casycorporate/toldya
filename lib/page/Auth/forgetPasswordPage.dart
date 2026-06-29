import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/helper/constant.dart';
import 'package:toldya/helper/theme.dart';
import 'package:toldya/helper/utility.dart';
import 'package:toldya/page/Auth/widget/bezierContainer.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/widgets/customWidgets.dart';
import 'package:toldya/widgets/toldya_logo.dart';

class ForgetPasswordPage extends StatefulWidget {
  final VoidCallback? loginCallback;

  const ForgetPasswordPage({super.key, this.loginCallback});

  @override
  State<StatefulWidget> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  late final FocusNode _focusNode;
  late final TextEditingController _emailController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSending = false;
  bool _isSent = false;
  String _sentEmail = '';

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _emailController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _body(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: -MediaQuery.of(context).size.height * .15,
          right: -MediaQuery.of(context).size.width * .4,
          child: BezierContainer(),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: fullHeight(context) -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 360),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _isSent ? _sentView(context) : _formView(context),
              ),
            ),
          ),
        ),
        Positioned(top: 40, left: 0, child: _backButton()),
      ],
    );
  }

  Widget _formView(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('forgot-form'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 72),
        const ToldyaLogo(height: 58),
        const SizedBox(height: 26),
        Text(
          l10n.forgotPasswordTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.forgotPasswordSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
            fontSize: 14.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        _entryField(l10n.forgotPasswordEmailHint, controller: _emailController),
        const SizedBox(height: 12),
        _resetInfoCard(context),
        const SizedBox(height: 24),
        _submitButton(context),
        const SizedBox(height: 28),
      ],
    ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.04, end: 0);
  }

  Widget _sentView(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('forgot-sent'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 108,
          width: 108,
          margin: const EdgeInsets.only(bottom: 26),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppNeon.green.withValues(alpha: 0.14),
            boxShadow: [
              BoxShadow(
                color: AppNeon.green.withValues(alpha: 0.25),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.mark_email_read_rounded,
            size: 46,
            color: AppNeon.green,
          ),
        )
            .animate()
            .scaleXY(
              begin: 0.72,
              end: 1,
              duration: 420.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 260.ms),
        Text(
          l10n.forgotPasswordSentTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.forgotPasswordSentMessage(_sentEmail),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            fontSize: 15,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.forgotPasswordSentHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 28),
        _secondaryButton(
          context,
          label: l10n.forgotPasswordTryAgain,
          icon: Icons.refresh_rounded,
          onTap: () {
            setState(() => _isSent = false);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _focusNode.requestFocus();
            });
          },
        ),
        const SizedBox(height: 12),
        _primaryButton(
          context,
          label: l10n.forgotPasswordBackToSignIn,
          icon: Icons.login_rounded,
          onTap: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ],
    ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.04, end: 0);
  }

  Widget _resetInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        border: Border.all(color: AppColor.cardDarkBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_reset_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.forgotPasswordResetMinHint(kMinPasswordLength),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
                fontSize: 12.5,
                height: 1.38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(
                Icons.keyboard_arrow_left,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.back,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entryField(String hint, {required TextEditingController controller}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        border: Border.all(color: AppColor.cardDarkBorder),
      ),
      child: TextField(
        focusNode: _focusNode,
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.alternate_email_rounded,
            color: theme.colorScheme.primary,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _primaryButton(
      context,
      label: _isSending
          ? l10n.forgotPasswordSending
          : l10n.forgotPasswordSendButton,
      icon: _isSending ? null : Icons.send_rounded,
      isBusy: _isSending,
      onTap: _isSending ? null : _submit,
    );
  }

  Widget _primaryButton(
    BuildContext context, {
    required String label,
    IconData? icon,
    bool isBusy = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
            color: theme.colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.32),
                offset: const Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isBusy) ...[
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ] else if (icon != null) ...[
                Icon(icon, size: 19, color: theme.colorScheme.onPrimary),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
            color: theme.colorScheme.surface,
            border: Border.all(color: AppColor.cardDarkBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.82),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.82),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      customSnackBar(_scaffoldKey, AppLocalizations.of(context)!.emailEmpty);
      return;
    }
    var isValidEmail = validateEmal(email);
    if (!isValidEmail) {
      customSnackBar(
          _scaffoldKey, AppLocalizations.of(context)!.validEmailRequired);
      return;
    }

    _focusNode.unfocus();
    setState(() => _isSending = true);
    var state = Provider.of<AuthState>(context, listen: false);
    final ok = await state.forgetPassword(email, scaffoldKey: _scaffoldKey);
    if (!mounted) return;
    setState(() {
      _isSending = false;
      if (ok) {
        _sentEmail = email;
        _isSent = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _body(context),
    );
  }
}
