import 'package:auto_route/auto_route.dart';
import 'package:client_app/features/auth/src/bloc/auth_bloc.dart';
import 'package:client_app/router/auto_route.gr.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

@RoutePage()
class AuthEnterEmailPage extends StatefulWidget {
  const AuthEnterEmailPage({super.key});

  @override
  State<AuthEnterEmailPage> createState() => _AuthEnterEmailPageState();
}

class _AuthEnterEmailPageState extends State<AuthEnterEmailPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthTryAutoLogin());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String input) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(input);
  }

  void _submit() {
    final email = _emailController.text.trim();
    final strings = S.of(context);

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.authInvalidEmail)));
      return;
    }

    context.read<AuthBloc>().add(AuthRequestOtp(email));
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthCodeSent) {
          context.router.push(AuthEnterCodeRoute(email: state.email));
        } else if (state is AuthSuccess) {
          context.router.replaceAll([HomeRoute()]);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
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
                    const Spacer(flex: 1),
                    // Assets.images.mtuciPng.image(package: "ui_kit", width: 200),
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
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return PMButton(
                          text: strings.authSendCode,
                          isLoading: state is AuthLoading,
                          onPressed: state is AuthLoading ? () {} : _submit,
                        );
                      },
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
