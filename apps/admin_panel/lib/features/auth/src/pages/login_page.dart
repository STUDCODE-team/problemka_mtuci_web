import 'package:auto_route/auto_route.dart';
import 'package:admin_panel/features/auth/src/bloc/auth_bloc.dart';
import 'package:admin_panel/router/auto_route.gr.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();

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
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).authInvalidEmail)),
      );
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
          context.router.push(VerifyCodeRoute(email: state.email));
        } else if (state is AuthSuccess) {
          context.router.replaceAll([const DashboardRoute()]);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
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
                    Icon(Icons.admin_panel_settings,
                        size: 64, color: context.colors.primary),
                    Text('Админ-панель',
                        style: context.texts.headlineSmall),
                    Text(strings.authSubtitle,
                        style: context.texts.bodyMedium),
                    const SizedBox(height: 8),
                    PMInput(
                      label: strings.authEmailLabel,
                      hint: strings.authEmailHint,
                      controller: _emailController,
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
