const CACHE='argo-admin-v6';
const APP=['./manifest.webmanifest','../admin-icon.svg'];

self.addEventListener('install',e=>{
  e.waitUntil(
    caches.open(CACHE)
      .then(c=>c.addAll(APP))
      .catch(()=>{})
      .then(()=>self.skipWaiting())
  );
});

self.addEventListener('activate',e=>{
  e.waitUntil(Promise.all([
    caches.keys().then(keys=>Promise.all(keys.filter(k=>k.startsWith('argo-admin-')&&k!==CACHE).map(k=>caches.delete(k)))),
    self.clients.claim()
  ]));
});

self.addEventListener('fetch',e=>{
  if(e.request.method!=='GET')return;
  const u=new URL(e.request.url);
  if(u.origin!==self.location.origin)return;
  const html=e.request.mode==='navigate'||u.pathname.endsWith('.html')||u.pathname.endsWith('/admin/');
  if(html){
    e.respondWith(fetch(e.request,{cache:'no-store'}));
    return;
  }
  e.respondWith(caches.match(e.request).then(cached=>cached||fetch(e.request).then(r=>{
    if(r&&r.ok){
      const copy=r.clone();
      caches.open(CACHE).then(c=>c.put(e.request,copy));
    }
    return r;
  })));
});

self.addEventListener('push',e=>{
  let d={title:'🍽️ ARGO · NUOVO ORDINE',body:'È arrivato un nuovo ordine',url:'./orders.html'};
  try{if(e.data)d={...d,...e.data.json()}}catch(_){}
  const tag=d.orderId?'argo-order-'+d.orderId:(d.tag||'argo-order');
  e.waitUntil((async()=>{
    await self.registration.showNotification(d.title,{
      body:d.body,
      icon:'../admin-icon.svg',
      badge:'../admin-icon.svg',
      tag,
      renotify:true,
      requireInteraction:true,
      silent:false,
      timestamp:Date.now(),
      data:{url:d.url||'./orders.html',orderId:d.orderId||null},
      vibrate:[500,180,500,180,900]
    });
    if(self.registration.setAppBadge){
      try{await self.registration.setAppBadge()}catch(_){}
    }
  })());
});

self.addEventListener('notificationclick',e=>{
  e.notification.close();
  const target=new URL(e.notification.data?.url||'./orders.html',self.location.href).href;
  e.waitUntil((async()=>{
    if(self.registration.clearAppBadge){
      try{await self.registration.clearAppBadge()}catch(_){}
    }
    const ws=await clients.matchAll({type:'window',includeUncontrolled:true});
    const adminWindows=ws.filter(w=>{
      try{return new URL(w.url).origin===new URL(target).origin}catch(_){return false}
    });
    for(const w of adminWindows){
      if('navigate'in w)await w.navigate(target);
      if('focus'in w)return w.focus();
    }
    return clients.openWindow(target);
  })());
});
