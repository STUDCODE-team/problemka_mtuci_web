import 'package:auto_route/auto_route.dart';
import 'package:admin_panel/features/auth/src/bloc/auth_bloc.dart';
import 'package:admin_panel/features/reports/bloc/reports_bloc.dart';
import 'package:admin_panel/features/reports/models/report.dart';
import 'package:admin_panel/router/auto_route.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

String _fmt(DateTime dt) {
  final d = dt.toLocal();
  String p(int n) => n.toString().padLeft(2, '0');
  return '${p(d.day)}.${p(d.month)}.${d.year} ${p(d.hour)}:${p(d.minute)}';
}

@RoutePage()
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  ReportStatus? _activeFilter;

  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(LoadReports());
  }

  void _applyFilter(ReportStatus? status) {
    setState(() => _activeFilter = status);
    context.read<ReportsBloc>().add(LoadReports(status: status));
  }

  void _showReportDetails(ReportListItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ReportsBloc>(),
        child: _ReportDetailSheet(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Админ-панель'),
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthSuccess && state.user.role == 'admin') {
                  return IconButton(
                    icon: const Icon(Icons.manage_accounts),
                    tooltip: 'Пользователи',
                    onPressed: () => context.router.push(const UsersRoute()),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Выйти',
              onPressed: () => context.read<AuthBloc>().add(AuthLogout()),
            ),
          ],
        ),
        body: Column(
          children: [
            _FilterBar(activeFilter: _activeFilter, onFilter: _applyFilter),
            Expanded(
              child: BlocBuilder<ReportsBloc, ReportsState>(
                builder: (context, state) {
                  if (state is ReportsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ReportsLoaded) {
                    if (state.reports.isEmpty) {
                      return const Center(child: Text('Обращений нет.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<ReportsBloc>()
                            .add(LoadReports(status: _activeFilter));
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.reports.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final report = state.reports[index];
                          return _ReportCard(
                            report: report,
                            onTap: () => _showReportDetails(report),
                          );
                        },
                      ),
                    );
                  }
                  return const Center(child: Text('Загрузка...'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final ReportStatus? activeFilter;
  final void Function(ReportStatus?) onFilter;

  const _FilterBar({required this.activeFilter, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    final filters = [null, ...ReportStatus.values];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 8,
        children: filters.map((status) {
          final label = status == null ? 'Все' : status.label;
          final selected = activeFilter == status;
          return FilterChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => onFilter(status),
          );
        }).toList(),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportListItem report;
  final VoidCallback onTap;

  const _ReportCard({required this.report, required this.onTap});

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
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(report.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${report.location} · ${_fmt(report.createdAt)}',
          style: context.texts.bodySmall,
        ),
        trailing: Chip(
          label: Text(
            report.status.label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: _statusColor(report.status),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _ReportDetailSheet extends StatelessWidget {
  final ReportListItem item;

  const _ReportDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportStatusChanged) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Статус изменён на: ${state.report.status.label}'),
            ),
          );
        } else if (state is ReportsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(item.title, style: context.texts.titleLarge),
              const SizedBox(height: 12),
              _InfoRow('Место', item.location),
              _InfoRow('Категория', item.category),
              _InfoRow('Приоритет', item.priority),
              _InfoRow('Дата', _fmt(item.createdAt)),
              _InfoRow('Статус', item.status.label),
              const SizedBox(height: 24),
              if (item.status.allowedTransitions.isNotEmpty) ...[
                Text('Изменить статус', style: context.texts.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: item.status.allowedTransitions.map((next) {
                    return ElevatedButton(
                      onPressed: () {
                        context.read<ReportsBloc>().add(
                              ChangeReportStatus(
                                reportId: item.id,
                                status: next,
                              ),
                            );
                      },
                      child: Text(next.label),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: context.texts.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value, style: context.texts.bodyMedium)),
        ],
      ),
    );
  }
}
