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
    final bloc = context.read<ReportsBloc>();
    context.router.push(AdminReportDetailRoute(reportId: item.id)).then((_) {
      if (mounted) bloc.add(LoadReports(status: _activeFilter));
    });
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
