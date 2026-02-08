import 'package:auto_route/auto_route.dart';
import 'package:client_app/router/auto_route.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: AuthEnterEmailRoute.page, initial: true),
    AutoRoute(page: AuthEnterCodeRoute.page),
    AutoRoute(page: AuthSuccessRoute.page),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: ReportDetailRoute.page),
  ];

  @override
  List<AutoRouteGuard> get guards => [];
}
