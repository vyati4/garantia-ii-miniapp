// Service Worker — офлайн-оболочка МВП «Гарантия ИИ».
// Стратегия: статика (оболочка) — cache-first; API — network-only (никогда не кэшируем данные/ПДн).
const CACHE = 'garantia-ii-v1';
const SHELL = [
  './',
  './index.html',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-512.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET') return;                 // POST (/api/package и пр.) — не трогаем
  const url = new URL(request.url);
  if (url.pathname.startsWith('/api/')) return;         // данные и ПДн — только из сети, без кэша

  event.respondWith(
    caches.match(request).then((cached) => {
      if (cached) return cached;
      return fetch(request)
        .then((res) => {
          if (res.ok && url.origin === self.location.origin) {
            const copy = res.clone();
            caches.open(CACHE).then((c) => c.put(request, copy));
          }
          return res;
        })
        .catch(() => caches.match('./index.html'));      // офлайн-фолбэк на оболочку
    })
  );
});
