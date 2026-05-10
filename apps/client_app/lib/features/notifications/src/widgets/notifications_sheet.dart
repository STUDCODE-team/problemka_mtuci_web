import 'package:client_app/features/notifications/src/bloc/notifications_bloc.dart';
import 'package:client_app/features/notifications/src/models/notification.dart';
import 'package:client_app/features/reports/src/models/report.dart';
import 'package:client_app/router/auto_route.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<NotificationsBloc>(),
        child: const NotificationsSheet(),
      ),
    );
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
        return strings.notificationStatusRejected;
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

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    strings.notificationsTitle,
                    style: context.texts.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  BlocBuilder<NotificationsBloc, NotificationsState>(
                    builder: (context, state) {
                      if (state is NotificationsLoaded && state.unreadCount > 0) {
                        return TextButton(
                          onPressed: () {
                            context
                                .read<NotificationsBloc>()
                                .add(MarkAllNotificationsRead());
                          },
                          child: Text(strings.notificationsMarkAllRead),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  if (state is NotificationsLoaded) {
                    if (state.notifications.isEmpty) {
                      return Center(
                        child: Text(
                          strings.notificationsEmpty,
                          style: context.texts.bodyMedium?.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.notifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final n = state.notifications[index];
                        return _NotificationTile(
                          notification: n,
                          statusLabel: _statusLabel(strings, n.newStatus),
                          statusColor: _statusColor(context, n.newStatus),
                          onTap: () {
                            if (!n.isRead) {
                              context
                                  .read<NotificationsBloc>()
                                  .add(MarkNotificationRead(n.id));
                            }
                            Navigator.of(context).pop();
                            context.router.push(ReportDetailRoute(reportId: n.reportId));
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.statusLabel,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isUnread
            ? context.colors.primaryContainer.withValues(alpha: 0.25)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnread ? context.colors.primary : Colors.transparent,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    notification.reportTitle,
                    style: context.texts.bodyMedium?.copyWith(
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Row(
                    spacing: 4,
                    children: [
                      Text(
                        strings.notificationStatusChanged,
                        style: context.texts.bodySmall?.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                  Text(
                    notification.createdAt.toLocal().toString().split('.').first,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
