// Problemka MTUCI — Web Push Service Worker

self.addEventListener('push', function (event) {
  if (!event.data) return;

  let payload;
  try {
    payload = event.data.json();
  } catch {
    payload = { title: 'Уведомление', body: event.data.text() };
  }

  const title = payload.title || 'Проблемка МТУСИ';
  const options = {
    body: payload.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: { reportId: payload.reportId || null, url: self.registration.scope },
    vibrate: [200, 100, 200],
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', function (event) {
  event.notification.close();

  const scope = self.registration.scope;

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function (clientList) {
      // Focus existing window if open
      for (const client of clientList) {
        if (client.url.startsWith(scope) && 'focus' in client) {
          return client.focus();
        }
      }
      // Otherwise open a new window
      return clients.openWindow(scope);
    })
  );
});
