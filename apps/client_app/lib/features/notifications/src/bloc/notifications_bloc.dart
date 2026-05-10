import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_app/features/notifications/src/models/notification.dart';
import 'package:client_app/features/notifications/src/notifications_repository.dart';

// --- Events ---

abstract class NotificationsEvent {}

class LoadNotifications extends NotificationsEvent {}

class MarkNotificationRead extends NotificationsEvent {
  final String notificationId;
  MarkNotificationRead(this.notificationId);
}

class MarkAllNotificationsRead extends NotificationsEvent {}

class _PollTick extends NotificationsEvent {}

// --- States ---

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> notifications;
  NotificationsLoaded(this.notifications);

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError(this.message);
}

// --- BLoC ---

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;
  Timer? _pollTimer;

  static const _pollInterval = Duration(seconds: 30);

  NotificationsBloc({required NotificationsRepository repository})
      : _repository = repository,
        super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
    on<_PollTick>(_onPollTick);

    _startPolling();
  }

  void _startPolling() {
    add(LoadNotifications());
    _pollTimer = Timer.periodic(_pollInterval, (_) => add(_PollTick()));
  }

  Future<void> _onLoad(LoadNotifications event, Emitter<NotificationsState> emit) async {
    try {
      final notifications = await _repository.fetchMyNotifications();
      emit(NotificationsLoaded(notifications));
    } on DioException catch (_) {
      // Silently ignore on initial load to not disrupt UI
    }
  }

  Future<void> _onPollTick(_PollTick event, Emitter<NotificationsState> emit) async {
    try {
      final notifications = await _repository.fetchMyNotifications();
      emit(NotificationsLoaded(notifications));
    } on DioException catch (_) {
      // Ignore poll errors silently
    }
  }

  Future<void> _onMarkRead(
      MarkNotificationRead event, Emitter<NotificationsState> emit) async {
    // Optimistic update
    if (state is NotificationsLoaded) {
      final current = (state as NotificationsLoaded).notifications;
      final updated = current
          .map((n) => n.id == event.notificationId ? n.copyWith(isRead: true) : n)
          .toList();
      emit(NotificationsLoaded(updated));
    }
    try {
      await _repository.markRead(event.notificationId);
    } on DioException catch (_) {
      // Reload on failure
      add(LoadNotifications());
    }
  }

  Future<void> _onMarkAllRead(
      MarkAllNotificationsRead event, Emitter<NotificationsState> emit) async {
    // Optimistic update
    if (state is NotificationsLoaded) {
      final current = (state as NotificationsLoaded).notifications;
      final updated = current.map((n) => n.copyWith(isRead: true)).toList();
      emit(NotificationsLoaded(updated));
    }
    try {
      await _repository.markAllRead();
    } on DioException catch (_) {
      add(LoadNotifications());
    }
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
