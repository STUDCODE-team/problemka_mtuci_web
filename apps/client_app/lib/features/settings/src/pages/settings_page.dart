import 'package:auto_route/auto_route.dart';
import 'package:client_app/features/auth/src/bloc/auth_bloc.dart';
import 'package:client_app/features/settings/src/locale_cubit.dart';
import 'package:client_app/features/settings/src/theme_cubit.dart';
import 'package:client_app/router/auto_route.gr.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final themeMode = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                children: [
                  // Theme
                  ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: Text(strings.settingsTheme),
                    subtitle: Text(
                      themeMode == ThemeMode.dark
                          ? strings.settingsThemeDark
                          : strings.settingsThemeLight,
                    ),
                    trailing: Switch(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (_) => context.read<ThemeCubit>().toggle(),
                    ),
                  ),
                  const Divider(),

                  // Language
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(strings.settingsLanguage),
                    subtitle: Text(locale?.languageCode == 'en' ? 'English' : 'Русский'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Русский'),
                          showCheckmark: false,
                          selected: locale?.languageCode != 'en',
                          labelStyle: locale?.languageCode != 'en'
                              ? const TextStyle(color: Colors.white)
                              : null,
                          onSelected: (_) =>
                              context.read<LocaleCubit>().setLocale(const Locale('ru')),
                        ),
                        ChoiceChip(
                          label: const Text('English'),
                          showCheckmark: false,
                          selected: locale?.languageCode == 'en',
                          labelStyle: locale?.languageCode == 'en'
                              ? const TextStyle(color: Colors.white)
                              : null,
                          onSelected: (_) =>
                              context.read<LocaleCubit>().setLocale(const Locale('en')),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Logout
                  ListTile(
                    leading: Icon(Icons.logout, color: context.colors.error),
                    title: Text(
                      strings.settingsLogout,
                      style: TextStyle(color: context.colors.error),
                    ),
                    onTap: () {
                      context.read<AuthBloc>().add(AuthLogout());
                      context.router.replaceAll([const AuthEnterEmailRoute()]);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
