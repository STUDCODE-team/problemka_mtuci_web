import 'package:auto_route/auto_route.dart';
import 'package:client_app/core/auth/token_repository.dart';
import 'package:client_app/router/auto_route.gr.dart';

class AuthGuard extends AutoRouteGuard {
  final TokenRepository tokenRepository;

  AuthGuard(this.tokenRepository);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (tokenRepository.isLoggedIn) {
      resolver.next();
    } else {
      resolver.redirectUntil(const AuthEnterEmailRoute(), replace: true);
    }
  }
}

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  final TokenRepository tokenRepository;

  AppRouter({required this.tokenRepository});

  @override
  RouteType get defaultRouteType => RouteType.custom(
        transitionsBuilder: TransitionsBuilders.fadeIn,
        duration: const Duration(milliseconds: 180),
      );

  @override
  List<AutoRoute> get routes => [
        // Protected routes — guard redirects to login if no token
        AutoRoute(
          page: HomeRoute.page,
          path: '/home',
          initial: true,
          guards: [AuthGuard(tokenRepository)],
        ),
        AutoRoute(
          page: ReportDetailRoute.page,
          path: '/reports/:reportId',
          guards: [AuthGuard(tokenRepository)],
        ),
        AutoRoute(
          page: CreateReportRoute.page,
          path: '/reports/create',
          guards: [AuthGuard(tokenRepository)],
        ),
        AutoRoute(
          page: ReportEditRoute.page,
          path: '/reports/:reportId/edit',
          guards: [AuthGuard(tokenRepository)],
        ),
        AutoRoute(
          page: SettingsRoute.page,
          path: '/settings',
          guards: [AuthGuard(tokenRepository)],
        ),
        // Auth routes — no guard
        AutoRoute(page: AuthEnterEmailRoute.page, path: '/login'),
        AutoRoute(page: AuthEnterCodeRoute.page, path: '/login/verify'),
        AutoRoute(page: AuthSuccessRoute.page, path: '/auth-success'),
      ];
}
