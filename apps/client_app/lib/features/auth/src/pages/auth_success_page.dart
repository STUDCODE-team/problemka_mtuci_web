import 'package:auto_route/auto_route.dart';
import 'package:client_app/router/auto_route.gr.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

@RoutePage()
class AuthSuccessPage extends StatelessWidget {
  final String name;
  final String role;

  const AuthSuccessPage({super.key, required this.name, required this.role});

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
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Spacer(flex: 1),
                  Icon(Icons.check_circle, size: 96, color: context.colors.primary),
                  Text(strings.authSuccessTitle, style: context.texts.headlineLarge),
                  Text(
                    strings.authSuccessSubtitle(name),
                    style: context.texts.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  PMButton(
                    text: strings.authContinue,
                    onPressed: () {
                      context.router.replaceAll([HomeRoute(name: name, role: role)]);
                    },
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
