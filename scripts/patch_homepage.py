from pathlib import Path
import re

p = Path('index.html')
s = p.read_text(encoding='utf-8')
original = s

hero = 'https://drive.google.com/thumbnail?id=18fDHddu3ZTSBvsofyX4pgsKVya1OK1Bo&sz=w1600'
s = re.sub(r'<meta property="og:image" content="[^"]+">', f'<meta property="og:image" content="{hero}">', s, count=1)
s = re.sub(r"\.hero-bg\{position:absolute;inset:0;background:url\('[^']+'\)", f".hero-bg{{position:absolute;inset:0;background:url('{hero}')", s, count=1)

# Current operations: dinner only, Wednesday closed.
s = s.replace('12:00–15:00 · 18:30–23:00', '18:30–23:00')
s = re.sub(r'<optgroup data-i18n-label="optgroup_lunch"[^>]*>.*?</optgroup>', '', s, flags=re.S)
s = s.replace('<option>18:00</option><option>18:30</option>', '<option>18:30</option>')
s = s.replace("const lunch=t>=720&&t<900,dinner=t>=1080&&t<1380,hasPranzo=[1,2,4,5].includes(day);", "const dinner=t>=1110&&t<1380;")
s = s.replace("} else if((hasPranzo&&lunch)||dinner){", "} else if(dinner){")
s = s.replace("const next=t<720&&hasPranzo?'12:00':'18:00';", "const next='18:30';")

replacements = {
    "faq_a_hours:'Δευτ, Τρίτ, Πέμπτ, Παρ: 12:00–15:00 και 18:30–23:00. Σαββ και Κυρ: μόνο βράδυ 18:30–23:00. Τετάρτη κλειστό.'": "faq_a_hours:'Δευτέρα, Τρίτη, Πέμπτη, Παρασκευή, Σάββατο και Κυριακή: 18:30–23:00. Τετάρτη κλειστά.'",
    "faq_a_hours:'Mon, Tue, Thu, Fri: 12:00–15:00 and 18:30–23:00. Sat and Sun: dinner only 18:30–23:00. Wednesday closed.'": "faq_a_hours:'Monday, Tuesday, Thursday, Friday, Saturday and Sunday: 18:30–23:00. Wednesday closed.'",
    "faq_a_hours:'Mo, Di, Do, Fr: 12:00–15:00 und 18:30–23:00. Sa und So: nur Abendessen 18:30–23:00. Mittwoch geschlossen.'": "faq_a_hours:'Mo, Di, Do, Fr, Sa und So: 18:30–23:00. Mittwoch geschlossen.'",
    "faq_a_hours:'Lun, Mar, Jeu, Ven: 12h00–15h00 et 18h00–23h00. Sam et Dim: dîner uniquement 18h00–23h00. Mercredi fermé.'": "faq_a_hours:'Lun, Mar, Jeu, Ven, Sam et Dim: 18h30–23h00. Mercredi fermé.'",
    "faq_a_hours:'Lun, Mar, Jue, Vie: 12:00–15:00 y 18:30–23:00. Sáb y Dom: solo cena 18:30–23:00. Miércoles cerrado.'": "faq_a_hours:'Lun, Mar, Jue, Vie, Sáb y Dom: 18:30–23:00. Miércoles cerrado.'",
    "urg_wed:'Oggi chiusi · Riapriamo Giovedì 12:00 · Prenota in anticipo'": "urg_wed:'Oggi chiusi · Riapriamo Giovedì 18:30 · Prenota in anticipo'",
    "urg_wed:'Σήμερα κλειστοί · Ανοίγουμε Πέμπτη 12:00'": "urg_wed:'Σήμερα κλειστοί · Ανοίγουμε Πέμπτη 18:30'",
    "urg_wed:'Closed today · Reopening Thursday at 12:00'": "urg_wed:'Closed today · Reopening Thursday at 18:30'",
    "urg_wed:'Heute geschlossen · Öffnet Donnerstag um 12:00'": "urg_wed:'Heute geschlossen · Öffnet Donnerstag um 18:30'",
    "urg_wed:'Fermé aujourd\\'hui · Réouverture jeudi à 12h00'": "urg_wed:'Fermé aujourd\\'hui · Réouverture jeudi à 18h30'",
    "urg_wed:'Cerrados hoy · Reabrimos el jueves a las 12:00'": "urg_wed:'Cerrados hoy · Reabrimos el jueves a las 18:30'",
    "Sì! Spanakopita, Tiropita, Dakos, Insalata Greca, Tzatziki, Pita Dolmas — tutti segnati con 🌿.": "Sì. Abbiamo Pita Vegetariana, Pita Vegan, Pita Dolmas, Insalata Greca, mezedes e salse vegetariane. La disponibilità può variare."
}
for old, new in replacements.items():
    s = s.replace(old, new)

legacy_menu = """async function loadMenu(){
  try{
    const r=await fetch('menu.json');const d=await r.json();
    menuData=d.items||[];renderFilters();renderMenu();
  }catch(e){document.getElementById('menu-grid').innerHTML='<p style=\"color:rgba(255,255,255,.3);padding:40px;text-align:center;grid-column:1/-1\">Menu in caricamento...</p>'}
}"""
live_menu = """async function loadMenu(){
  const SUPA='https://zibubwrntdmdxyimqddo.supabase.co';
  const KEY='sb_publishable_IGXGYoh2jg1ardyg9jW3vg_DTybVlOL';
  const H={'apikey':KEY,'Authorization':'Bearer '+KEY};
  try{
    const [cr,mr]=await Promise.all([
      fetch(SUPA+'/rest/v1/argo_menu_categories?select=id,name&active=eq.true&order=sort_order.asc',{headers:H}),
      fetch(SUPA+'/rest/v1/argo_menu_items?select=id,category_id,name,description,price,image_url,sort_order&active=eq.true&order=sort_order.asc',{headers:H})
    ]);
    if(!cr.ok||!mr.ok)throw new Error('menu_http');
    const cats=await cr.json(),rows=await mr.json(),catMap=Object.fromEntries(cats.map(c=>[c.id,c.name]));
    menuData=rows.map((x,idx)=>({id:idx+1,sourceId:x.id,name:x.name,description:x.description||'',price:Number(x.price||0),image:x.image_url||'',category:catMap[x.category_id]||'Altro',available:true}));
    renderFilters();renderMenu();
  }catch(e){
    console.error(e);
    document.getElementById('menu-grid').innerHTML='<p style=\"color:rgba(255,255,255,.45);padding:40px;text-align:center;grid-column:1/-1\">Menu temporaneamente non disponibile. Usa ARGO Direct per vedere il menu aggiornato.</p>';
  }
}"""
if legacy_menu not in s:
    raise SystemExit('Expected legacy loadMenu block not found')
s = s.replace(legacy_menu, live_menu, 1)

s = s.replace(
    "const catEmoji={'Pita Carne':'🥙','Pita Vegetariana':'🌿','Piatti':'🍽️','Antipasti':'🫒','Salse':'🥣','Dolci':'🍯','Bevande':'🍺'};",
    "const catEmoji={'Pita':'🥙','Piatti':'🍽️','Mezedes':'🫒','Insalate':'🥗','Vegetariano':'🌿','Salse':'🥣','Dolci':'🍯','Bevande':'🥤','Birre':'🍺','Vini':'🍷','Posate':'🍴'};"
)

s = re.sub(
    r"const SYS=`Sei l'assistente ARGO Greek Comfort Food, Ancona Via Marconi 27\..*?Max 2-3 frasi per risposta\.`;",
    "const SYS=`Sei l'assistente ARGO Greek Comfort Food, Ancona Via Marconi 27. Rispondi in italiano, breve e diretto. Orari attuali: Lun, Mar, Gio, Ven, Sab e Dom 18:30-23:00. Mercoledì CHIUSO. Ritiro: ARGO Direct. Delivery: Deliveroo o Just Eat. Prenotazione tavolo: Pienissimo. Catering: disponibile su richiesta. Non inventare prezzi o disponibilità: rimanda al menu live. Max 2-3 frasi per risposta.`;",
    s,
    count=1,
    flags=re.S
)

if "fetch('menu.json')" in s:
    raise SystemExit('Legacy menu.json fetch still present')
if '12:00–15:00 · 18:30–23:00' in s:
    raise SystemExit('Old visible lunch hours still present')
if s == original:
    raise SystemExit('No changes made')

p.write_text(s, encoding='utf-8')
print('ARGO homepage patch applied safely')
