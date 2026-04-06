import 'package:auto_route/auto_route.dart';
import 'package:client_app/features/auth/src/bloc/auth_bloc.dart';
import 'package:client_app/router/auto_route.gr.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    // Guard against web refresh: email arg is empty when no args were serialised
    // in the URL. Redirect back to the email entry page immediately.
    if (widget.email.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.router.replaceAll([const AuthEnterEmailRoute()]);
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verify() {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    context.read<AuthBloc>().add(AuthVerifyOtp(email: widget.email, code: code));
  }

  void _resendCode() {
    context.read<AuthBloc>().add(AuthRequestOtp(widget.email));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).authResentMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.router.replaceAll([const HomeRoute()]);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
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
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return PMButton(
                          text: strings.authVerifyCode,
                          isLoading: state is AuthLoading,
                          onPressed: state is AuthLoading ? () {} : _verify,
                        );
                      },
                    ),
                    TextButton(
                      onPressed: _resendCode,
                      child: Text(strings.authResendCode),
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
