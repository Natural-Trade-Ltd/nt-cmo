// CMO service worker v3 — el HTML SIEMPRE se baja de red (las actualizaciones llegan solas)
const CACHE = 'cmo-v3';
const SHELL = ['./', 'index.html', 'manifest.webmanifest', 'icon.svg'];

self.addEventListener('install', e => {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)).catch(() => {}));
});

self.addEventListener('activate', e => {
  e.waitUntil((async () => {
    const ks = await caches.keys();
    const old = ks.filter(k => k !== CACHE);
    await Promise.all(old.map(k => caches.delete(k)));
    await self.clients.claim();
    if (old.length) {                                  // hubo actualización -> avisa a las pestañas para recargar
      const cs = await self.clients.matchAll({ type: 'window' });
      cs.forEach(c => c.postMessage('sw-updated'));
    }
  })());
});

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);
  if (e.request.method !== 'GET' || url.origin !== location.origin) return;   // Supabase / esm.sh -> red directa
  const isHTML = e.request.mode === 'navigate' || url.pathname.endsWith('/') || url.pathname.endsWith('index.html');
  if (isHTML) {
    // HTML: red fresca sin caché HTTP; caché solo como respaldo offline
    e.respondWith(
      fetch(new Request(url.href, { cache: 'reload' }))
        .then(r => { const cp = r.clone(); caches.open(CACHE).then(c => c.put('index.html', cp)).catch(() => {}); return r; })
        .catch(() => caches.match('index.html'))
    );
    return;
  }
  e.respondWith(
    fetch(e.request)
      .then(r => { const cp = r.clone(); caches.open(CACHE).then(c => c.put(e.request, cp)).catch(() => {}); return r; })
      .catch(() => caches.match(e.request))
  );
});
