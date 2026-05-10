import 'package:auto_route/auto_route.dart';
import 'package:admin_panel/core/auth/token_repository.dart';
import 'package:admin_panel/router/auto_route.gr.dart';

class AuthGuard extends AutoRouteGuard {
  final TokenRepository tokenRepository;

  AuthGuard(this.tokenRepository);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (tokenRepository.isLoggedIn) {
      resolver.next();
    } else {
      resolver.redirectUntil(const LoginRoute(), replace: true);
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
        // Protected routes
        AutoRoute(
          page: DashboardRoute.page,
          path: '/dashboard',
          initial: true,
          guards: [AuthGuard(tokenRepository)],
        ),
        AutoRoute(
          page: UsersRoute.page,
          path: '/users',
          guards: [AuthGuard(tokenRepository)],
        ),
        AutoRoute(
          page: AdminReportDetailRoute.page,
          path: '/reports/:reportId',
          guards: [AuthGuard(tokenRepository)],
        ),
        AutoRoute(
          page: AdminSettingsRoute.page,
          path: '/settings',
          guards: [AuthGuard(tokenRepository)],
        ),
        // Auth routes
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(page: VerifyCodeRoute.page, path: '/login/verify'),
      ];
}
