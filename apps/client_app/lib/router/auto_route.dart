import 'package:auto_route/auto_route.dart';
import 'package:client_app/router/auto_route.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.custom(
        transitionsBuilder: TransitionsBuilders.fadeIn,
        duration: const Duration(milliseconds: 180),
      );

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: AuthEnterEmailRoute.page, initial: true),
    AutoRoute(page: AuthEnterCodeRoute.page),
    AutoRoute(page: AuthSuccessRoute.page),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: ReportDetailRoute.page),
    AutoRoute(page: CreateReportRoute.page),
    AutoRoute(page: ReportEditRoute.page),
    AutoRoute(page: SettingsRoute.page),
  ];

  @override
  List<AutoRouteGuard> get guards => [];
}
