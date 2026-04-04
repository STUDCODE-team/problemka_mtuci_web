// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:client_app/features/auth/src/pages/auth_enter_code_page.dart'
    as _i1;
import 'package:client_app/features/auth/src/pages/auth_enter_email_page.dart'
    as _i2;
import 'package:client_app/features/auth/src/pages/auth_success_page.dart'
    as _i3;
import 'package:client_app/features/home/src/pages/home_page.dart' as _i4;
import 'package:client_app/features/reports/src/pages/report_detail_page.dart'
    as _i5;
import 'package:client_app/features/settings/src/pages/settings_page.dart'
    as _i6;
import 'package:flutter/material.dart' as _i8;

/// generated route for
/// [_i1.AuthEnterCodePage]
class AuthEnterCodeRoute extends _i7.PageRouteInfo<AuthEnterCodeRouteArgs> {
  AuthEnterCodeRoute({
    _i8.Key? key,
    required String email,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         AuthEnterCodeRoute.name,
         args: AuthEnterCodeRouteArgs(key: key, email: email),
         initialChildren: children,
       );

  static const String name = 'AuthEnterCodeRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AuthEnterCodeRouteArgs>();
      return _i1.AuthEnterCodePage(key: args.key, email: args.email);
    },
  );
}

class AuthEnterCodeRouteArgs {
  const AuthEnterCodeRouteArgs({this.key, required this.email});

  final _i8.Key? key;

  final String email;

  @override
  String toString() {
    return 'AuthEnterCodeRouteArgs{key: $key, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AuthEnterCodeRouteArgs) return false;
    return key == other.key && email == other.email;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode;
}

/// generated route for
/// [_i2.AuthEnterEmailPage]
class AuthEnterEmailRoute extends _i7.PageRouteInfo<void> {
  const AuthEnterEmailRoute({List<_i7.PageRouteInfo>? children})
    : super(AuthEnterEmailRoute.name, initialChildren: children);

  static const String name = 'AuthEnterEmailRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i2.AuthEnterEmailPage();
    },
  );
}

/// generated route for
/// [_i3.AuthSuccessPage]
class AuthSuccessRoute extends _i7.PageRouteInfo<AuthSuccessRouteArgs> {
  AuthSuccessRoute({
    _i8.Key? key,
    required String name,
    required String role,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         AuthSuccessRoute.name,
         args: AuthSuccessRouteArgs(key: key, name: name, role: role),
         initialChildren: children,
       );

  static const String name = 'AuthSuccessRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AuthSuccessRouteArgs>();
      return _i3.AuthSuccessPage(
        key: args.key,
        name: args.name,
        role: args.role,
      );
    },
  );
}

class AuthSuccessRouteArgs {
  const AuthSuccessRouteArgs({
    this.key,
    required this.name,
    required this.role,
  });

  final _i8.Key? key;

  final String name;

  final String role;

  @override
  String toString() {
    return 'AuthSuccessRouteArgs{key: $key, name: $name, role: $role}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AuthSuccessRouteArgs) return false;
    return key == other.key && name == other.name && role == other.role;
  }

  @override
  int get hashCode => key.hashCode ^ name.hashCode ^ role.hashCode;
}

/// generated route for
/// [_i4.HomePage]
class HomeRoute extends _i7.PageRouteInfo<void> {
  const HomeRoute({List<_i7.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i4.HomePage();
    },
  );
}

/// generated route for
/// [_i5.ReportDetailPage]
class ReportDetailRoute extends _i7.PageRouteInfo<ReportDetailRouteArgs> {
  ReportDetailRoute({
    _i8.Key? key,
    required String reportId,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         ReportDetailRoute.name,
         args: ReportDetailRouteArgs(key: key, reportId: reportId),
         initialChildren: children,
       );

  static const String name = 'ReportDetailRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReportDetailRouteArgs>();
      return _i5.ReportDetailPage(key: args.key, reportId: args.reportId);
    },
  );
}

class ReportDetailRouteArgs {
  const ReportDetailRouteArgs({this.key, required this.reportId});

  final _i8.Key? key;

  final String reportId;

  @override
  String toString() {
    return 'ReportDetailRouteArgs{key: $key, reportId: $reportId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReportDetailRouteArgs) return false;
    return key == other.key && reportId == other.reportId;
  }

  @override
  int get hashCode => key.hashCode ^ reportId.hashCode;
}

/// generated route for
/// [_i6.SettingsPage]
class SettingsRoute extends _i7.PageRouteInfo<void> {
  const SettingsRoute({List<_i7.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i6.SettingsPage();
    },
  );
}
