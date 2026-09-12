from pathlib import Path

p = Path('index.html')
s = p.read_text(encoding='utf-8')
original = s

replacements = {
    "pie_name:'Pienissimo',pie_desc:'Order online and pick up at Via Marconi 27. Zero wait.',pie_tag:'TAKEAWAY · BOOK'": "pie_name:'ARGO Direct',pie_desc:'Order directly from ARGO and pick up at Via Marconi 27.',pie_tag:'PICKUP'",
    "pie_name:'Pienissimo',pie_desc:'Online bestellen und in der Via Marconi 27 abholen.',pie_tag:'ABHOLUNG'": "pie_name:'ARGO Direct',pie_desc:'Direkt bei ARGO bestellen und in der Via Marconi 27 abholen.',pie_tag:'ABHOLUNG'",
    "pie_name:'Pienissimo',pie_desc:'Commandez en ligne et récupérez au Via Marconi 27.',pie_tag:'À EMPORTER'": "pie_name:'ARGO Direct',pie_desc:'Commandez directement chez ARGO et récupérez Via Marconi 27.',pie_tag:'À EMPORTER'",
    "pie_name:'Pienissimo',pie_desc:'Pide online y recoge en Via Marconi 27.',pie_tag:'PARA LLEVAR'": "pie_name:'ARGO Direct',pie_desc:'Pide directamente a ARGO y recoge en Via Marconi 27.',pie_tag:'PARA LLEVAR'",
    "footer_tag:'Authentic Greek Street Food in Ancona since 2017.'": "footer_tag:'Authentic Greek Street Food in Ancona.'",
    "footer_tag:'Authentisches Griechisches Street Food in Ancona seit 2017.'": "footer_tag:'Authentisches Griechisches Street Food in Ancona.'",
    "footer_tag:'Street Food Grec Authentique à Ancône depuis 2017.'": "footer_tag:'Street Food Grec Authentique à Ancône.'",
    "footer_tag:'Street Food Griego Auténtico en Ancona desde 2017.'": "footer_tag:'Street Food Griego Auténtico en Ancona.'",
    "footer_tag:'Authentic Greek Street Food ad Ancona dal 2017.'": "footer_tag:'Authentic Greek Street Food ad Ancona.'",
    "footer_tag:'Αυθεντικό Ελληνικό Street Food στην Ανκόνα από το 2017.'": "footer_tag:'Αυθεντικό Ελληνικό Street Food στην Ανκόνα.'",
    "https://instagram.com/argogreek_ancona": "https://instagram.com/argoancona",
    "© 2025 ARGO Greek Comfort Food": "© 2026 ARGO Greek Comfort Food",
    "if(urgEl)urgEl.textContent=T.urg_wed||'Oggi chiusi · Riapriamo Giovedì 12:00';": "if(urgEl)urgEl.textContent=T.urg_wed||'Oggi chiusi · Riapriamo Giovedì 18:30';"
}

for old, new in replacements.items():
    s = s.replace(old, new)

if s == original:
    raise SystemExit('No cleanup changes made')

p.write_text(s, encoding='utf-8')
print('ARGO homepage cleanup applied')
