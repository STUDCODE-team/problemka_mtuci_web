import 'package:auto_route/auto_route.dart';
import 'package:admin_panel/features/auth/src/bloc/auth_bloc.dart';
import 'package:admin_panel/router/auto_route.gr.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

@RoutePage()
class VerifyCodePage extends StatefulWidget {
  final String email;

  const VerifyCodePage({super.key, required this.email});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verify() {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    context.read<AuthBloc>().add(
      AuthVerifyOtp(email: widget.email, code: code),
    );
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
          context.router.replaceAll([const DashboardRoute()]);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    Text(strings.authCodeTitle,
                        style: context.texts.headlineSmall),
                    Text(
                      strings.authCodeSubtitle(widget.email),
                      style: context.texts.bodyMedium,
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
