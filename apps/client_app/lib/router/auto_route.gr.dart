// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:client_app/features/auth/src/pages/auth_enter_code_page.dart'
    as _i1;
import 'package:client_app/features/auth/src/pages/auth_enter_email_page.dart'
    as _i2;
import 'package:client_app/features/auth/src/pages/auth_success_page.dart'
    as _i3;
import 'package:client_app/features/home/src/pages/home_page.dart' as _i4;
import 'package:client_app/features/reports/src/pages/report_detail_page.dart'
    as _i5;

/// generated route for
/// [_i1.AuthEnterCodePage]
class AuthEnterCodeRoute extends _i6.PageRouteInfo<AuthEnterCodeRouteArgs> {
  AuthEnterCodeRoute({
    required String email,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         AuthEnterCodeRoute.name,
         args: AuthEnterCodeRouteArgs(email: email),
         initialChildren: children,
       );

  static const String name = 'AuthEnterCodeRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AuthEnterCodeRouteArgs>();
      return _i1.AuthEnterCodePage(email: args.email);
    },
  );
}

class AuthEnterCodeRouteArgs {
  const AuthEnterCodeRouteArgs({required this.email});

  final String email;

  @override
  String toString() {
    return 'AuthEnterCodeRouteArgs{email: $email}';
  }
}

/// generated route for
/// [_i2.AuthEnterEmailPage]
class AuthEnterEmailRoute extends _i6.PageRouteInfo<void> {
  const AuthEnterEmailRoute({List<_i6.PageRouteInfo>? children})
    : super(AuthEnterEmailRoute.name, initialChildren: children);

  static const String name = 'AuthEnterEmailRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i2.AuthEnterEmailPage();
    },
  );
}

/// generated route for
/// [_i3.AuthSuccessPage]
class AuthSuccessRoute extends _i6.PageRouteInfo<AuthSuccessRouteArgs> {
  AuthSuccessRoute({
    required String name,
    required String role,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         AuthSuccessRoute.name,
         args: AuthSuccessRouteArgs(name: name, role: role),
         initialChildren: children,
       );

  static const String name = 'AuthSuccessRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AuthSuccessRouteArgs>();
      return _i3.AuthSuccessPage(name: args.name, role: args.role);
    },
  );
}

class AuthSuccessRouteArgs {
  const AuthSuccessRouteArgs({required this.name, required this.role});

  final String name;

  final String role;

  @override
  String toString() {
    return 'AuthSuccessRouteArgs{name: $name, role: $role}';
  }
}

/// generated route for
/// [_i4.HomePage]
class HomeRoute extends _i6.PageRouteInfo<HomeRouteArgs> {
  HomeRoute({
    required String name,
    required String role,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         HomeRoute.name,
         args: HomeRouteArgs(name: name, role: role),
         initialChildren: children,
       );

  static const String name = 'HomeRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HomeRouteArgs>();
      return _i4.HomePage(name: args.name, role: args.role);
    },
  );
}

class HomeRouteArgs {
  const HomeRouteArgs({required this.name, required this.role});

  final String name;

  final String role;

  @override
  String toString() {
    return 'HomeRouteArgs{name: $name, role: $role}';
  }
}

/// generated route for
/// [_i5.ReportDetailPage]
class ReportDetailRoute extends _i6.PageRouteInfo<ReportDetailRouteArgs> {
  ReportDetailRoute({
    required String reportId,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         ReportDetailRoute.name,
         args: ReportDetailRouteArgs(reportId: reportId),
         initialChildren: children,
       );

  static const String name = 'ReportDetailRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReportDetailRouteArgs>();
      return _i5.ReportDetailPage(reportId: args.reportId);
    },
  );
}

class ReportDetailRouteArgs {
  const ReportDetailRouteArgs({required this.reportId});

  final String reportId;

  @override
  String toString() {
    return 'ReportDetailRouteArgs{reportId: $reportId}';
  }
}
