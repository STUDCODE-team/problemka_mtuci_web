import 'package:auto_route/annotations.dart';
import 'package:client_app/features/reports/src/mock_reports_repository.dart';
import 'package:client_app/features/reports/src/models/report.dart';
import 'package:client_app/features/reports/src/widgets/report_problem_dialog.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

@RoutePage()
class ReportDetailPage extends StatelessWidget {
  final String reportId;

  const ReportDetailPage({super.key, required this.reportId});

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

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final report = MockReportsRepository.instance.getById(reportId);

    if (report == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(strings.reportNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.reportDetailTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          report.title,
                          style: context.texts.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(context, report.status).withValues(alpha: 0.15),
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
                  Text(report.description, style: context.texts.bodyLarge),
                  Divider(color: context.colors.outlineVariant),
                  _DetailRow(label: strings.reportDetailLocation, value: report.location),
                  _DetailRow(label: strings.reportDetailRoom, value: report.room),
                  _DetailRow(label: strings.reportDetailCategory, value: report.category),
                  _DetailRow(label: strings.reportDetailPriority, value: report.priority),
                  _DetailRow(label: strings.reportDetailReporter, value: report.reporter),
                  _DetailRow(
                    label: strings.reportDetailDate,
                    value: report.createdAt.toString().split(' ').first,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: PMButton(
            text: strings.reportCreateButton,
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) => const ReportProblemDialog(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: context.texts.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(child: Text(value, style: context.texts.bodyMedium)),
      ],
    );
  }
}
