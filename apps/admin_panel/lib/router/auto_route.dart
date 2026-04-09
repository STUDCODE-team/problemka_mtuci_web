import 'package:auto_route/auto_route.dart';
import 'package:admin_panel/router/auto_route.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.custom(
        transitionsBuilder: TransitionsBuilders.fadeIn,
        duration: const Duration(milliseconds: 180),
      );

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, initial: true),
        AutoRoute(page: VerifyCodeRoute.page),
        AutoRoute(page: DashboardRoute.page),
        AutoRoute(page: UsersRoute.page),
      ];
}
