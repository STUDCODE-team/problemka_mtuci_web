import 'package:client_app/core/api/api_client.dart';
import 'package:client_app/core/auth/token_repository.dart';
import 'package:client_app/features/auth/src/auth_repository.dart';
import 'package:client_app/features/auth/src/bloc/auth_bloc.dart';
import 'package:client_app/features/reports/src/bloc/reports_bloc.dart';
import 'package:client_app/features/reports/src/reports_repository.dart';
import 'package:client_app/features/settings/src/locale_cubit.dart';
import 'package:client_app/features/settings/src/theme_cubit.dart';
import 'package:client_app/router/auto_route.dart';
import 'package:client_app/router/auto_route.gr.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost');

  final tokenRepository = TokenRepository();
  late final AppRouter appRouter;
  appRouter = AppRouter();

  final apiClient = ApiClient(
    baseUrl: apiBaseUrl,
    tokenRepository: tokenRepository,
    onSessionExpired: () {
      tokenRepository.clearAll();
      appRouter.replaceAll([const AuthEnterEmailRoute()]);
    },
  );

  final authRepository = AuthRepository(
    apiClient: apiClient,
    tokenRepository: tokenRepository,
  );

  final reportsRepository = ReportsRepository(apiClient: apiClient);

  runApp(MyApp(
    appRouter: appRouter,
    authRepository: authRepository,
    reportsRepository: reportsRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  final AuthRepository authRepository;
  final ReportsRepository reportsRepository;

  const MyApp({
    super.key,
    required this.appRouter,
    required this.authRepository,
    required this.reportsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authRepository: authRepository)),
        BlocProvider(create: (_) => ReportsBloc(repository: reportsRepository)),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) {
              return ResponsiveApp(
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  routerConfig: appRouter.config(),
                  title: 'Problemka MTUCI',
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: themeMode,
                  locale: locale,
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: S.supportedLocales,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
