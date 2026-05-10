import 'package:admin_panel/core/api/api_client.dart';
import 'package:admin_panel/core/auth/token_repository.dart';
import 'package:admin_panel/features/auth/src/auth_repository.dart';
import 'package:admin_panel/features/auth/src/bloc/auth_bloc.dart';
import 'package:admin_panel/features/reports/bloc/reports_bloc.dart';
import 'package:admin_panel/features/reports/repositories/reports_repository.dart';
import 'package:admin_panel/features/settings/locale_cubit.dart';
import 'package:admin_panel/features/settings/theme_cubit.dart';
import 'package:admin_panel/features/users/bloc/users_bloc.dart';
import 'package:admin_panel/features/users/repositories/users_repository.dart';
import 'package:admin_panel/router/auto_route.dart';
import 'package:admin_panel/router/auto_route.gr.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ui_kit/ui_kit.dart';

void main() async {
  const glitchtipDsn = String.fromEnvironment('GLITCHTIP_DSN');

  await SentryFlutter.init((options) {
    options.dsn = glitchtipDsn;
    options.tracesSampleRate = 0.01;
    options.enableAutoSessionTracking = false;
    options.environment = const String.fromEnvironment('APP_ENV', defaultValue: 'development');
  }, appRunner: _bootstrap);
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppTheme.preloadFonts();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://devapi.problemka-mtuci.tech',
  );

  final tokenRepository = TokenRepository();
  final hasSession = await tokenRepository.hasPersistedSession();
  if (hasSession) {
    tokenRepository.setLoggedIn();
  }

  late final AppRouter appRouter;
  appRouter = AppRouter(tokenRepository: tokenRepository);

  final apiClient = ApiClient(
    baseUrl: apiBaseUrl,
    tokenRepository: tokenRepository,
    onSessionExpired: () {
      tokenRepository.clearAll();
      appRouter.replaceAll([const LoginRoute()]);
    },
  );

  final authRepository = AuthRepository(apiClient: apiClient, tokenRepository: tokenRepository);

  // Create bloc early, fire auto-login before runApp.
  // If hasSession=true, AuthGuard lets the user through immediately while
  // tryAutoLogin validates the cookie in the background.
  final authBloc = AuthBloc(authRepository: authRepository);
  if (hasSession) {
    authBloc.add(AuthTryAutoLogin());
  }

  final reportsRepository = ReportsRepository(apiClient: apiClient);
  final usersRepository = UsersRepository(apiClient: apiClient);

  runApp(
    MyApp(
      appRouter: appRouter,
      authBloc: authBloc,
      reportsRepository: reportsRepository,
      usersRepository: usersRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  final AuthBloc authBloc;
  final ReportsRepository reportsRepository;
  final UsersRepository usersRepository;

  const MyApp({
    super.key,
    required this.appRouter,
    required this.authBloc,
    required this.reportsRepository,
    required this.usersRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider(
          create: (_) =>
              ReportsBloc(repository: reportsRepository, usersRepository: usersRepository),
        ),
        BlocProvider(create: (_) => UsersBloc(repository: usersRepository)),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            appRouter.replaceAll([const DashboardRoute()]);
          } else if (state is AuthInitial) {
            appRouter.replaceAll([const LoginRoute()]);
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BlocBuilder<LocaleCubit, Locale?>(
              builder: (context, locale) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  routerConfig: appRouter.config(),
                  title: 'Админ-панель МТУСИ',
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
