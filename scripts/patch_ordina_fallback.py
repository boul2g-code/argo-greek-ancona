from pathlib import Path

p=Path('ordina/index.html')
s=p.read_text(encoding='utf-8')

s=s.replace("let items=[],cats=[],groups=[],options=[],links=[],cart=[],promoState=null,currentItem=null;","let items=[],cats=[],groups=[],options=[],links=[],cart=[],promoState=null,currentItem=null,emergencyMode=false;")

legacy_old="if(items.length){had=true;renderCats();render();const note=document.createElement('div');note.style.cssText='grid-column:1/-1;background:#3b2f1f;border:1px solid #8b6b3c;color:#f4dfb5;padding:12px 14px;border-radius:10px;margin-bottom:10px;font-size:13px;line-height:1.4';note.textContent='Menu di emergenza in sola consultazione. Il sistema ordini live è temporaneamente non disponibile.';$('menu').prepend(note);}}}catch(e){}}"
legacy_new="if(items.length){emergencyMode=true;had=true;const cartBox=document.querySelector('.cart');if(cartBox)cartBox.style.display='none';renderCats();render();const note=document.createElement('div');note.style.cssText='grid-column:1/-1;background:#3b2f1f;border:1px solid #8b6b3c;color:#f4dfb5;padding:12px 14px;border-radius:10px;margin-bottom:10px;font-size:13px;line-height:1.4';note.textContent='Menu di emergenza in sola consultazione. Prezzi e ordini tornano disponibili appena il servizio live viene ripristinato.';$('menu').prepend(note);}}}catch(e){}}"
if legacy_old in s:
    s=s.replace(legacy_old,legacy_new,1)

live_old="cats=c||[];items=m||[];groups=g||[];options=o||[];links=l||[];try{localStorage.setItem(cacheKey,JSON.stringify({cats,items,groups,options,links,ts:Date.now()}))}catch(_){}renderCats();render()"
live_new="cats=c||[];items=m||[];groups=g||[];options=o||[];links=l||[];emergencyMode=false;const cartBox=document.querySelector('.cart');if(cartBox)cartBox.style.display='block';try{localStorage.setItem(cacheKey,JSON.stringify({cats,items,groups,options,links,ts:Date.now()}))}catch(_){}renderCats();render()"
if live_old in s:
    s=s.replace(live_old,live_new,1)

render_old="function render(cat='all'){$('menu').innerHTML=items.filter(x=>cat==='all'||x.category_id===cat).map(x=>`<div class=\"item\">${x.image_url?`<img class=\"itemPhoto\" src=\"${esc(x.image_url)}\" alt=\"${esc(x.name)}\" loading=\"lazy\" referrerpolicy=\"no-referrer\" onerror=\"this.remove()\">`:''}<div class=\"itemBody\"><h3>${esc(x.name)}</h3><div class=\"desc\">${esc(x.description||'')}</div><div class=\"foot\"><span class=\"price\">${euro(x.price)}</span><button class=\"add\" onclick=\"startAdd('${x.id}')\">${hasMods(x.id)?'PERSONALIZZA +':'+ AGGIUNGI'}</button></div></div></div>`).join('')}"
render_new="function render(cat='all'){$('menu').innerHTML=items.filter(x=>cat==='all'||x.category_id===cat).map(x=>{const price=emergencyMode?'Prezzo temporaneamente non disponibile':euro(x.price);const action=emergencyMode?'':`<button class=\"add\" onclick=\"startAdd('${x.id}')\">${hasMods(x.id)?'PERSONALIZZA +':'+ AGGIUNGI'}</button>`;return `<div class=\"item\">${x.image_url?`<img class=\"itemPhoto\" src=\"${esc(x.image_url)}\" alt=\"${esc(x.name)}\" loading=\"lazy\" referrerpolicy=\"no-referrer\" onerror=\"this.remove()\">`:''}<div class=\"itemBody\"><h3>${esc(x.name)}</h3><div class=\"desc\">${esc(x.description||'')}</div><div class=\"foot\"><span class=\"price\">${price}</span>${action}</div></div></div>`}).join('')}"
if render_old in s:
    s=s.replace(render_old,render_new,1)

p.write_text(s,encoding='utf-8')
