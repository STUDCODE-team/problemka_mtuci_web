import 'dart:convert';
import 'dart:js_interop';

import 'package:client_app/core/api/api_client.dart';
import 'package:flutter/foundation.dart';

// JS interop bindings (calls functions defined in index.html)
@JS('pushSubscribeJson')
external JSPromise<JSString?> _jsSubscribe(String vapidPublicKey);

@JS('pushUnsubscribeJson')
external JSPromise<JSString?> _jsUnsubscribe();

class PushSubscriptionService {
  final ApiClient _apiClient;

  PushSubscriptionService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch VAPID public key, subscribe in the browser, send subscription to backend.
  Future<void> subscribe() async {
    if (!kIsWeb) return;
    try {
      // 1. Get VAPID public key from backend
      final keyResponse =
          await _apiClient.dio.get('/api/notifications/push/vapid-public-key');
      final vapidPublicKey = keyResponse.data['public_key'] as String?;
      if (vapidPublicKey == null || vapidPublicKey.isEmpty) return;

      // 2. Subscribe in browser (JS), returns JSON string or null
      final jsResult = await _jsSubscribe(vapidPublicKey).toDart;
      if (jsResult == null) return;

      final subJson = jsonDecode(jsResult.toDart) as Map<String, dynamic>;

      // 3. Send subscription to backend
      await _apiClient.dio.post(
        '/api/notifications/push/subscribe',
        data: {
          'endpoint': subJson['endpoint'],
          'p256dh': subJson['p256dh'],
          'auth': subJson['auth'],
        },
      );
    } catch (e) {
      debugPrint('[PushSubscriptionService] subscribe error: $e');
    }
  }

  /// Unsubscribe from push in browser and notify backend.
  Future<void> unsubscribe() async {
    if (!kIsWeb) return;
    try {
      final jsResult = await _jsUnsubscribe().toDart;
      if (jsResult == null) return;

      final subJson = jsonDecode(jsResult.toDart) as Map<String, dynamic>;

      await _apiClient.dio.post(
        '/api/notifications/push/unsubscribe',
        data: {
          'endpoint': subJson['endpoint'],
          'p256dh': subJson['p256dh'],
          'auth': subJson['auth'],
        },
      );
    } catch (e) {
      debugPrint('[PushSubscriptionService] unsubscribe error: $e');
    }
  }
}
