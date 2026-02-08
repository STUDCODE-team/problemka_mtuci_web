import 'package:auto_route/auto_route.dart';
import 'package:client_app/features/auth/src/mock_auth_repository.dart';
import 'package:client_app/router/auto_route.gr.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

@RoutePage()
class AuthEnterCodePage extends StatefulWidget {
  final String email;

  const AuthEnterCodePage({super.key, required this.email});

  @override
  State<AuthEnterCodePage> createState() => _AuthEnterCodePageState();
}

class _AuthEnterCodePageState extends State<AuthEnterCodePage> {
  final TextEditingController _codeController = TextEditingController();
  final MockAuthRepository _authRepository = MockAuthRepository.instance;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final strings = S.of(context);
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() => _errorText = strings.authInvalidCode);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final user = await _authRepository.verifyCode(email: widget.email, code: code);
      if (!mounted) return;
      context.router.replace(AuthSuccessRoute(name: user.name, role: user.role));
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = error.code == 'invalid_code'
            ? strings.authInvalidCode
            : strings.authUnknownEmail;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendCode() async {
    final strings = S.of(context);
    setState(() => _errorText = null);
    try {
      await _authRepository.sendCode(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.authResentMessage)));
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = error.code == 'unknown_email'
            ? strings.authUnknownEmail
            : strings.authInvalidEmail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Spacer(flex: 1),
                  Text(strings.authCodeTitle, style: context.texts.headlineLarge),
                  Text(
                    strings.authCodeSubtitle(widget.email),
                    style: context.texts.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  PMInput(
                    label: strings.authCodeLabel,
                    hint: strings.authCodeHint,
                    controller: _codeController,
                  ),
                  Text(
                    strings.authDemoCode(MockAuthRepository.demoCode),
                    style: context.texts.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                  if (_errorText != null)
                    Text(
                      _errorText!,
                      style: context.texts.bodyMedium?.copyWith(color: context.colors.error),
                      textAlign: TextAlign.center,
                    ),
                  PMButton(
                    text: strings.authVerifyCode,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? () {} : _verify,
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _resendCode,
                    child: Text(strings.authResendCode),
                  ),
                  Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
