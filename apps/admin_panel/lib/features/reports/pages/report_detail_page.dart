import 'package:auto_route/auto_route.dart';
import 'package:admin_panel/features/reports/bloc/reports_bloc.dart';
import 'package:admin_panel/features/reports/models/report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

String _fmt(DateTime dt) {
  final d = dt.toLocal();
  String p(int n) => n.toString().padLeft(2, '0');
  return '${p(d.day)}.${p(d.month)}.${d.year} ${p(d.hour)}:${p(d.minute)}';
}

@RoutePage()
class AdminReportDetailPage extends StatefulWidget {
  final String reportId;

  const AdminReportDetailPage({super.key, required this.reportId});

  @override
  State<AdminReportDetailPage> createState() => _AdminReportDetailPageState();
}

class _AdminReportDetailPageState extends State<AdminReportDetailPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(LoadAdminReportDetail(widget.reportId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    context.read<ReportsBloc>().add(
          AddAdminComment(reportId: widget.reportId, text: text),
        );
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Детали заявки')),
      body: BlocConsumer<ReportsBloc, ReportsState>(
        listener: (context, state) {
          if (state is AdminDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminDetailError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context
                        .read<ReportsBloc>()
                        .add(LoadAdminReportDetail(widget.reportId)),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }
          if (state is AdminReportDetailLoaded) {
            return _DetailContent(
              state: state,
              commentController: _commentController,
              onSubmitComment: _submitComment,
              onForceStatus: (status) => context.read<ReportsBloc>().add(
                    ForceChangeStatus(
                      reportId: widget.reportId,
                      status: status,
                    ),
                  ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final AdminReportDetailLoaded state;
  final TextEditingController commentController;
  final VoidCallback onSubmitComment;
  final void Function(ReportStatus) onForceStatus;

  const _DetailContent({
    required this.state,
    required this.commentController,
    required this.onSubmitComment,
    required this.onForceStatus,
  });

  Color _statusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.newReport:
        return Colors.blue;
      case ReportStatus.inProgress:
        return Colors.orange;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = state.report;
    final reporter = state.reporter;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + status chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        report.title,
                        style: context.texts.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Chip(
                      label: Text(
                        report.status.label,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: _statusColor(report.status),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(report.description, style: context.texts.bodyLarge),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Info grid
                _InfoSection(
                  children: [
                    _InfoRow('Место', report.location),
                    if (report.room != null) _InfoRow('Кабинет', report.room!),
                    _InfoRow('Категория', report.category),
                    _InfoRow('Приоритет', report.priority),
                    _InfoRow('Тип', report.type),
                    _InfoRow('Создано', _fmt(report.createdAt)),
                    if (report.updatedAt != null)
                      _InfoRow('Обновлено', _fmt(report.updatedAt!)),
                  ],
                ),
                const SizedBox(height: 16),

                // Reporter info
                _SectionTitle('Заявитель'),
                const SizedBox(height: 8),
                if (reporter != null) ...[
                  _InfoRow('Email', reporter.email),
                  _InfoRow('Роль', reporter.role),
                  _InfoRow('ID', report.reporterId),
                ] else ...[
                  _InfoRow('ID', report.reporterId),
                  Text(
                    'Подробная информация недоступна',
                    style: context.texts.bodySmall
                        ?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
                const SizedBox(height: 24),

                // Force status change
                _SectionTitle('Изменить статус (любой)'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ReportStatus.values.map((s) {
                    final isCurrent = s == report.status;
                    return FilledButton.tonal(
                      onPressed: isCurrent ? null : () => onForceStatus(s),
                      style: isCurrent
                          ? null
                          : FilledButton.styleFrom(
                              backgroundColor: _statusColor(s).withValues(alpha: 0.15),
                              foregroundColor: _statusColor(s),
                            ),
                      child: Text(s.label),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Status history
                if (state.history.isNotEmpty) ...[
                  _SectionTitle('История статусов'),
                  const SizedBox(height: 8),
                  ...state.history.map(
                    (h) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_forward,
                              size: 16, color: context.colors.primary),
                          const SizedBox(width: 8),
                          Text(
                            '${_statusLabel(h.oldStatus)} → ${_statusLabel(h.newStatus)}',
                            style: context.texts.bodyMedium,
                          ),
                          const Spacer(),
                          Text(
                            _fmt(h.changedAt),
                            style: context.texts.bodySmall?.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Comments
                _SectionTitle('Комментарии'),
                const SizedBox(height: 8),
                if (state.comments.isEmpty)
                  Text(
                    'Комментариев пока нет.',
                    style: context.texts.bodyMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.5),
                    ),
                  )
                else
                  ...state.comments.map(
                    (c) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.text, style: context.texts.bodyMedium),
                            const SizedBox(height: 4),
                            Text(
                              _fmt(c.createdAt),
                              style: context.texts.bodySmall?.copyWith(
                                color: context.colors.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                // Add comment
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Написать комментарий...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => onSubmitComment(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: onSubmitComment,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(String apiValue) {
    switch (apiValue) {
      case 'new':
        return 'Новое';
      case 'in_progress':
        return 'В работе';
      case 'resolved':
        return 'Решено';
      case 'rejected':
        return 'Отклонено';
      default:
        return apiValue;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: context.texts.titleMedium?.copyWith(fontWeight: FontWeight.w600));
  }
}

class _InfoSection extends StatelessWidget {
  final List<Widget> children;
  const _InfoSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: context.texts.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(child: Text(value, style: context.texts.bodyMedium)),
        ],
      ),
    );
  }
}
