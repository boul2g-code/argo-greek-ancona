from pathlib import Path

p=Path('ordina/index.html')
s=p.read_text(encoding='utf-8')

s=s.replace("'Authorization':'Bearer '+KEY,","")
marker="async function load(){const cacheKey='argo_direct_cache_v3';let had=false;"
if marker in s and 'argo_emergency_fallback_v3' not in s:
    replacement="""async function load(){const cacheKey='argo_direct_cache_v3';let had=false;const argo_emergency_fallback_v3=true;
try{const sr=await fetch('menu-snapshot.json',{cache:'no-store'});if(sr.ok){const snap=await sr.json();if(Array.isArray(snap.items)&&snap.items.length){cats=snap.cats||[];items=snap.items||[];groups=snap.groups||[];options=snap.options||[];links=snap.links||[];had=true;renderCats();render();}}}catch(e){}
"""
    s=s.replace(marker,replacement,1)
old="if(!had)$('menu').innerHTML='<div style=\"grid-column:1/-1;padding:28px;text-align:center;color:#aab5c2\">Caricamento menu…</div>';"
new="""if(!had){try{const er=await fetch('../menu.json',{cache:'no-store'});if(er.ok){const em=await er.json();const names=(em.categories||[]).filter(function(x){return x&&x!=='Tutte'});cats=names.map(function(n,i){return {id:'legacy-cat-'+i,name:n,sort_order:i}});const cmap={};cats.forEach(function(c){cmap[c.name]=c.id});items=(em.items||[]).filter(function(x){return x.available!==false}).map(function(x,i){return {id:'legacy-'+String(x.id||i),category_id:cmap[x.category]||(cats[0]&&cats[0].id),name:x.name,description:x.description||'',price:Number(x.price||0),image_url:x.image||'',sort_order:i}});groups=[];options=[];links=[];if(items.length){had=true;renderCats();render();const note=document.createElement('div');note.style.cssText='grid-column:1/-1;background:#3b2f1f;border:1px solid #8b6b3c;color:#f4dfb5;padding:12px 14px;border-radius:10px;margin-bottom:10px;font-size:13px;line-height:1.4';note.textContent='Menu di emergenza in sola consultazione. Il sistema ordini live è temporaneamente non disponibile.';$('menu').prepend(note);}}}catch(e){}}if(!had)$('menu').innerHTML='<div style=\"grid-column:1/-1;padding:20px;text-align:center;color:#ffb4b4\">Menu momentaneamente non disponibile.</div>';"
if old in s:
    s=s.replace(old,new,1)
p.write_text(s,encoding='utf-8')
