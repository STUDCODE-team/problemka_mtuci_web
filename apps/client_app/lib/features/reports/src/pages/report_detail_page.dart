import 'package:auto_route/auto_route.dart';
import 'package:client_app/features/reports/src/bloc/reports_bloc.dart';
import 'package:client_app/router/auto_route.gr.dart';
import 'package:client_app/features/reports/src/models/report.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

@RoutePage()
class ReportDetailPage extends StatefulWidget {
  final String reportId;

  const ReportDetailPage({super.key, required this.reportId});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(LoadReportDetail(widget.reportId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    context.read<ReportsBloc>().add(AddComment(reportId: widget.reportId, text: text));
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.reportDetailTitle),
        actions: [
          BlocBuilder<ReportsBloc, ReportsState>(
            builder: (context, state) {
              if (state is ReportDetailLoaded &&
                  state.report.status == ReportStatus.newReport) {
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: strings.reportEditTitle,
                  onPressed: () async {
                    final updated = await context.router
                        .push(ReportEditRoute(reportId: widget.reportId));
                    if (updated == true && context.mounted) {
                      context
                          .read<ReportsBloc>()
                          .add(LoadReportDetail(widget.reportId));
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReportsError) {
            return Center(child: Text(state.message));
          }
          if (state is ReportDetailLoaded) {
            final report = state.report;
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        // Title + status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                report.title,
                                style: context.texts.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(context, report.status)
                                    .withValues(alpha: 0.15),
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

                        // Description
                        Text(report.description, style: context.texts.bodyLarge),
                        Divider(color: context.colors.outlineVariant),

                        // Details
                        _DetailRow(
                            label: strings.reportDetailLocation, value: report.location),
                        if (report.room != null)
                          _DetailRow(label: strings.reportDetailRoom, value: report.room!),
                        _DetailRow(
                            label: strings.reportDetailCategory, value: report.category),
                        _DetailRow(
                            label: strings.reportDetailPriority, value: report.priority),
                        _DetailRow(
                          label: strings.reportDetailDate,
                          value: report.createdAt.toString().split(' ').first,
                        ),

                        // Status history
                        if (state.history.isNotEmpty) ...[
                          Divider(color: context.colors.outlineVariant),
                          Text(strings.reportHistoryTitle,
                              style: context.texts.titleMedium),
                          ...state.history.map((h) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_forward,
                                        size: 16, color: context.colors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${h.oldStatus} → ${h.newStatus}',
                                      style: context.texts.bodyMedium,
                                    ),
                                    const Spacer(),
                                    Text(
                                      h.changedAt.toString().split(' ').first,
                                      style: context.texts.bodySmall?.copyWith(
                                        color: context.colors.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],

                        // Comments
                        Divider(color: context.colors.outlineVariant),
                        Text(strings.reportCommentsTitle,
                            style: context.texts.titleMedium),
                        if (state.comments.isEmpty)
                          Text(strings.reportCommentsEmpty,
                              style: context.texts.bodyMedium?.copyWith(
                                color: context.colors.onSurface.withValues(alpha: 0.5),
                              ))
                        else
                          ...state.comments.map((c) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.text, style: context.texts.bodyMedium),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.createdAt.toString().split(' ').first,
                                        style: context.texts.bodySmall?.copyWith(
                                          color: context.colors.onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),

                        // Add comment
                        Row(
                          spacing: 8,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: strings.reportCommentHint,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _submitComment,
                              icon: Icon(Icons.send, color: context.colors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
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
