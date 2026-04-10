import 'package:auto_route/auto_route.dart';
import 'package:client_app/features/auth/src/bloc/auth_bloc.dart';
import 'package:client_app/features/notifications/src/bloc/notifications_bloc.dart';
import 'package:client_app/features/notifications/src/widgets/notifications_sheet.dart';
import 'package:client_app/features/reports/src/bloc/reports_bloc.dart';
import 'package:client_app/features/reports/src/models/report.dart';
import 'package:client_app/features/reports/src/widgets/report_problem_dialog.dart';
import 'package:client_app/router/auto_route.gr.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ReportStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(LoadMyReports());
  }

  String _statusLabel(S strings, ReportStatus status) {
    switch (status) {
      case ReportStatus.newReport:
        return strings.reportStatusNew;
      case ReportStatus.inProgress:
        return strings.reportStatusInProgress;
      case ReportStatus.resolved:
        return strings.reportStatusResolved;
      case ReportStatus.rejected:
        return strings.reportStatusResolved;
    }
  }

  Color _statusColor(BuildContext context, ReportStatus status) {
    switch (status) {
      case ReportStatus.newReport:
        return context.colors.tertiary;
      case ReportStatus.inProgress:
        return context.colors.primary;
      case ReportStatus.resolved:
        return context.colors.secondary;
      case ReportStatus.rejected:
        return context.colors.error;
    }
  }

  void _onFilterChanged(ReportStatus? status) {
    setState(() => _selectedStatus = status);
    context.read<ReportsBloc>().add(LoadMyReports(status: status));
  }

  Future<void> _openReportDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => const ReportProblemDialog(),
    );
    if (created == true && mounted) {
      context.read<ReportsBloc>().add(LoadMyReports(status: _selectedStatus));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthSuccess ? authState.user.email : '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.school, color: context.colors.primary),
            const SizedBox(width: 8),
            Text(strings.reportAppTitle),
          ],
        ),
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              final unread = state is NotificationsLoaded ? state.unreadCount : 0;
              return IconButton(
                onPressed: () => NotificationsSheet.show(context),
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications_outlined),
                ),
              );
            },
          ),
          IconButton(
            onPressed: () => context.router.push(const SettingsRoute()),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(strings.reportListTitle, style: context.texts.headlineSmall),
              Text(strings.welcome(userName), style: context.texts.bodyLarge),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(strings.reportFilterAll),
                      selected: _selectedStatus == null,
                      onSelected: (_) => _onFilterChanged(null),
                    ),
                    ChoiceChip(
                      label: Text(strings.reportStatusNew),
                      selected: _selectedStatus == ReportStatus.newReport,
                      onSelected: (_) => _onFilterChanged(ReportStatus.newReport),
                    ),
                    ChoiceChip(
                      label: Text(strings.reportStatusInProgress),
                      selected: _selectedStatus == ReportStatus.inProgress,
                      onSelected: (_) => _onFilterChanged(ReportStatus.inProgress),
                    ),
                    ChoiceChip(
                      label: Text(strings.reportStatusResolved),
                      selected: _selectedStatus == ReportStatus.resolved,
                      onSelected: (_) => _onFilterChanged(ReportStatus.resolved),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<ReportsBloc, ReportsState>(
                  builder: (context, state) {
                    if (state is ReportsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ReportsError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.message),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => context
                                  .read<ReportsBloc>()
                                  .add(LoadMyReports(status: _selectedStatus)),
                              child: Text(strings.reportFilterAll),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is ReportsLoaded) {
                      final reports = state.reports;
                      if (reports.isEmpty) {
                        return Center(child: Text(strings.reportListEmpty));
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context
                              .read<ReportsBloc>()
                              .add(LoadMyReports(status: _selectedStatus));
                        },
                        child: ListView.separated(
                          itemCount: reports.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            return _ReportCard(
                              report: report,
                              statusLabel: _statusLabel(strings, report.status),
                              statusColor: _statusColor(context, report.status),
                              onTap: () {
                                context.router.push(ReportDetailRoute(reportId: report.id));
                              },
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: PMButton(text: strings.reportCreateButton, onPressed: _openReportDialog),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.statusLabel,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: context.colors.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      report.title,
                      style: context.texts.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusLabel,
                      style: context.texts.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 12,
                children: [
                  Icon(Icons.place, size: 16, color: context.colors.primary),
                  Expanded(child: Text(report.location, style: context.texts.bodySmall)),
                  Text(
                    report.createdAt.toString().split(' ').first,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
