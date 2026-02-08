import 'package:auto_route/auto_route.dart';
import 'package:client_app/features/reports/src/mock_reports_repository.dart';
import 'package:client_app/features/reports/src/models/report.dart';
import 'package:client_app/features/reports/src/widgets/report_problem_dialog.dart';
import 'package:client_app/router/auto_route.gr.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  final String name;
  final String role;

  const HomePage({super.key, required this.name, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MockReportsRepository _repository = MockReportsRepository.instance;
  ReportStatus? _selectedStatus;

  List<Report> get _reports {
    final all = _repository.fetchReports();
    if (_selectedStatus == null) return all;
    return all.where((report) => report.status == _selectedStatus).toList();
  }

  String _statusLabel(S strings, ReportStatus status) {
    switch (status) {
      case ReportStatus.newReport:
        return strings.reportStatusNew;
      case ReportStatus.inProgress:
        return strings.reportStatusInProgress;
      case ReportStatus.resolved:
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
    }
  }

  Future<void> _openReportDialog() async {
    await showDialog<void>(context: context, builder: (context) => const ReportProblemDialog());
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final reports = _reports;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.school, color: context.colors.primary),
            const SizedBox(width: 8),
            Text(strings.reportAppTitle),
          ],
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(strings.reportListTitle, style: context.texts.headlineSmall),
              Text(strings.welcome(widget.name), style: context.texts.bodyLarge),
              Text(
                strings.homeSubtitle(widget.role),
                style: context.texts.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(strings.reportFilterAll),
                      selected: _selectedStatus == null,
                      onSelected: (_) => setState(() => _selectedStatus = null),
                    ),
                    ChoiceChip(
                      label: Text(strings.reportStatusNew),
                      selected: _selectedStatus == ReportStatus.newReport,
                      onSelected: (_) => setState(() => _selectedStatus = ReportStatus.newReport),
                    ),
                    ChoiceChip(
                      label: Text(strings.reportStatusInProgress),
                      selected: _selectedStatus == ReportStatus.inProgress,
                      onSelected: (_) => setState(() => _selectedStatus = ReportStatus.inProgress),
                    ),
                    ChoiceChip(
                      label: Text(strings.reportStatusResolved),
                      selected: _selectedStatus == ReportStatus.resolved,
                      onSelected: (_) => setState(() => _selectedStatus = ReportStatus.resolved),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: reports.isEmpty
                    ? Center(child: Text(strings.reportListEmpty))
                    : ListView.separated(
                        itemCount: reports.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              context.router.push(ReportDetailRoute(reportId: report.id));
                            },
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              color: context.colors.surfaceContainerHighest,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
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
                                            style: context.texts.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _statusColor(
                                              context,
                                              report.status,
                                            ).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            _statusLabel(strings, report.status),
                                            style: context.texts.labelSmall?.copyWith(
                                              color: _statusColor(context, report.status),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      report.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.texts.bodyMedium,
                                    ),
                                    Row(
                                      spacing: 12,
                                      children: [
                                        Icon(Icons.place, size: 16, color: context.colors.primary),
                                        Expanded(
                                          child: Text(
                                            report.location,
                                            style: context.texts.bodySmall,
                                          ),
                                        ),
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
