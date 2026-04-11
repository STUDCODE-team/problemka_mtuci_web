import 'package:admin_panel/core/api/api_client.dart';
import 'package:admin_panel/core/auth/token_repository.dart';
import 'package:admin_panel/features/auth/src/auth_repository.dart';
import 'package:admin_panel/features/auth/src/bloc/auth_bloc.dart';
import 'package:admin_panel/features/reports/bloc/reports_bloc.dart';
import 'package:admin_panel/features/reports/repositories/reports_repository.dart';
import 'package:admin_panel/features/users/bloc/users_bloc.dart';
import 'package:admin_panel/features/users/repositories/users_repository.dart';
import 'package:admin_panel/router/auto_route.dart';
import 'package:admin_panel/router/auto_route.gr.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ui_kit/ui_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://devapi.problemka-mtuci.tech',
  );

  final tokenRepository = TokenRepository();
  final storedToken = await tokenRepository.getAccessToken();
  if (storedToken != null) {
    tokenRepository.setAccessTokenSync(storedToken);
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

  final authRepository = AuthRepository(
    apiClient: apiClient,
    tokenRepository: tokenRepository,
  );

  // Create bloc early, fire auto-login before runApp.
  // AuthGuard on DashboardRoute lets the user in immediately if token is
  // in memory — validation runs in background.
  final authBloc = AuthBloc(authRepository: authRepository);
  if (storedToken != null) {
    authBloc.add(AuthTryAutoLogin());
  }

  final reportsRepository = ReportsRepository(apiClient: apiClient);
  final usersRepository = UsersRepository(apiClient: apiClient);

  runApp(MyApp(
    appRouter: appRouter,
    authBloc: authBloc,
    reportsRepository: reportsRepository,
    usersRepository: usersRepository,
  ));
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
          create: (_) => ReportsBloc(
            repository: reportsRepository,
            usersRepository: usersRepository,
          ),
        ),
        BlocProvider(create: (_) => UsersBloc(repository: usersRepository)),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            appRouter.replaceAll([const DashboardRoute()]);
          } else if (state is AuthInitial) {
            appRouter.replaceAll([const LoginRoute()]);
          }
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter.config(),
          title: 'Админ-панель МТУСИ',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.supportedLocales,
        ),
      ),
    );
  }
}
