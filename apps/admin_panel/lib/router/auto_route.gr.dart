// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

import 'package:auto_route/auto_route.dart' as _i7;
import 'package:admin_panel/features/auth/src/pages/login_page.dart' as _i1;
import 'package:admin_panel/features/auth/src/pages/verify_code_page.dart'
    as _i2;
import 'package:admin_panel/features/reports/pages/dashboard_page.dart' as _i3;
import 'package:admin_panel/features/reports/pages/report_detail_page.dart'
    as _i5;
import 'package:admin_panel/features/users/pages/users_page.dart' as _i4;
import 'package:flutter/material.dart' as _i6;

/// generated route for [_i1.LoginPage]
class LoginRoute extends _i7.PageRouteInfo<void> {
  const LoginRoute({List<_i7.PageRouteInfo>? children})
      : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) => const _i1.LoginPage(),
  );
}

/// generated route for [_i2.VerifyCodePage]
class VerifyCodeRoute extends _i7.PageRouteInfo<VerifyCodeRouteArgs> {
  VerifyCodeRoute({
    _i6.Key? key,
    required String email,
    List<_i7.PageRouteInfo>? children,
  }) : super(
          VerifyCodeRoute.name,
          args: VerifyCodeRouteArgs(key: key, email: email),
          initialChildren: children,
        );

  static const String name = 'VerifyCodeRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VerifyCodeRouteArgs>(
        orElse: () => const VerifyCodeRouteArgs(email: ''),
      );
      return _i2.VerifyCodePage(key: args.key, email: args.email);
    },
  );
}

class VerifyCodeRouteArgs {
  const VerifyCodeRouteArgs({this.key, required this.email});

  final _i6.Key? key;
  final String email;

  @override
  String toString() => 'VerifyCodeRouteArgs{key: $key, email: $email}';
}

/// generated route for [_i3.DashboardPage]
class DashboardRoute extends _i7.PageRouteInfo<void> {
  const DashboardRoute({List<_i7.PageRouteInfo>? children})
      : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) => const _i3.DashboardPage(),
  );
}

/// generated route for [_i4.UsersPage]
class UsersRoute extends _i7.PageRouteInfo<void> {
  const UsersRoute({List<_i7.PageRouteInfo>? children})
      : super(UsersRoute.name, initialChildren: children);

  static const String name = 'UsersRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) => const _i4.UsersPage(),
  );
}

/// generated route for [_i5.AdminReportDetailPage]
class AdminReportDetailRoute
    extends _i7.PageRouteInfo<AdminReportDetailRouteArgs> {
  AdminReportDetailRoute({
    _i6.Key? key,
    required String reportId,
    List<_i7.PageRouteInfo>? children,
  }) : super(
          AdminReportDetailRoute.name,
          args: AdminReportDetailRouteArgs(key: key, reportId: reportId),
          initialChildren: children,
        );

  static const String name = 'AdminReportDetailRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AdminReportDetailRouteArgs>(
        orElse: () => const AdminReportDetailRouteArgs(reportId: ''),
      );
      return _i5.AdminReportDetailPage(key: args.key, reportId: args.reportId);
    },
  );
}

class AdminReportDetailRouteArgs {
  const AdminReportDetailRouteArgs({this.key, required this.reportId});

  final _i6.Key? key;
  final String reportId;

  @override
  String toString() =>
      'AdminReportDetailRouteArgs{key: $key, reportId: $reportId}';
}
