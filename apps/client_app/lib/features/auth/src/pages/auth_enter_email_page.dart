import 'package:auto_route/auto_route.dart';
import 'package:client_app/features/auth/src/mock_auth_repository.dart';
import 'package:client_app/router/auto_route.gr.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/gen/assets.gen.dart';
import 'package:ui_kit/ui_kit.dart';

@RoutePage()
class AuthEnterEmailPage extends StatefulWidget {
  const AuthEnterEmailPage({super.key});

  @override
  State<AuthEnterEmailPage> createState() => _AuthEnterEmailPageState();
}

class _AuthEnterEmailPageState extends State<AuthEnterEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  final MockAuthRepository _authRepository = MockAuthRepository.instance;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String input) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(input);
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final strings = S.of(context);

    if (!_isValidEmail(email)) {
      setState(() => _errorText = strings.authInvalidEmail);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await _authRepository.sendCode(email);
      if (!mounted) return;
      context.router.push(AuthEnterCodeRoute(email: email));
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = error.code == 'unknown_email'
            ? strings.authUnknownEmail
            : strings.authInvalidEmail;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Spacer(flex: 1),
                  Assets.images.mtuciPng.image(package: "ui_kit", width: 200),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(strings.authTitle, style: context.texts.headlineLarge),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(strings.authSubtitle, style: context.texts.bodyLarge),
                  ),
                  PMInput(
                    label: strings.authEmailLabel,
                    hint: strings.authEmailHint,
                    controller: _emailController,
                  ),
                  Text(
                    strings.authDemoEmails,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.65),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_errorText != null)
                    Text(
                      _errorText!,
                      style: context.texts.bodyMedium?.copyWith(color: context.colors.error),
                      textAlign: TextAlign.center,
                    ),
                  PMButton(
                    text: strings.authSendCode,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? () {} : _submit,
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
