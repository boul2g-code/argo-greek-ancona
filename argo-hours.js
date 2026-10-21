/* ARGO opening hours — single source of truth is argo_site_settings.hours (editable in admin/hours.html).
   dow keys: 0=Sunday ... 6=Saturday. All times are Europe/Rome. */
(function(){
const SUPA='https://xbzixjrdglpsssgnzrxl.supabase.co',KEY='sb_publishable_GdFwld1NP2ZEbpkbUYm2SA_THrug4uo',ZONE='Europe/Rome',CK='argo_hours_v1';
const FALLBACK={days:{0:{open:true,from:'18:30',to:'23:00'},1:{open:true,from:'18:30',to:'23:00'},2:{open:false,from:'18:30',to:'23:00'},3:{open:true,from:'18:30',to:'23:00'},4:{open:true,from:'18:30',to:'23:00'},5:{open:true,from:'18:30',to:'23:00'},6:{open:true,from:'18:30',to:'23:00'}}};
const NAMES={
 it:{s:['Dom','Lun','Mar','Mer','Gio','Ven','Sab'],l:['domenica','lunedì','martedì','mercoledì','giovedì','venerdì','sabato'],closed:'Chiuso'},
 en:{s:['Sun','Mon','Tue','Wed','Thu','Fri','Sat'],l:['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'],closed:'Closed'},
 el:{s:['Κυρ','Δευ','Τρι','Τετ','Πεμ','Παρ','Σαβ'],l:['Κυριακή','Δευτέρα','Τρίτη','Τετάρτη','Πέμπτη','Παρασκευή','Σάββατο'],closed:'Κλειστά'},
 es:{s:['Dom','Lun','Mar','Mié','Jue','Vie','Sáb'],l:['domingo','lunes','martes','miércoles','jueves','viernes','sábado'],closed:'Cerrado'},
 de:{s:['So','Mo','Di','Mi','Do','Fr','Sa'],l:['Sonntag','Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag'],closed:'Geschlossen'},
 fr:{s:['Dim','Lun','Mar','Mer','Jeu','Ven','Sam'],l:['dimanche','lundi','mardi','mercredi','jeudi','vendredi','samedi'],closed:'Fermé'}
};
const ORDER=[1,2,3,4,5,6,0]; // Monday first
let data=FALLBACK,loaded=null;
function valid(h){try{if(!h||!h.days)return false;for(let i=0;i<7;i++){const d=h.days[i];if(!d||typeof d.open!=='boolean'||!/^\d\d:\d\d$/.test(d.from)||!/^\d\d:\d\d$/.test(d.to))return false}return true}catch(e){return false}}
try{const c=JSON.parse(localStorage.getItem(CK)||'null');if(valid(c))data=c}catch(e){}
function mins(s){const p=String(s).split(':');return(+p[0])*60+(+p[1])}
function day(dow){const d=data.days[dow]||FALLBACK.days[dow];return{open:!!d.open,from:mins(d.from),to:mins(d.to),fromText:d.from,toText:d.to}}
function romeNow(d){const p=new Intl.DateTimeFormat('en-US',{timeZone:ZONE,weekday:'short',hour:'2-digit',minute:'2-digit',hourCycle:'h23'}).formatToParts(d||new Date()),o={};for(const x of p)o[x.type]=x.value;return{dow:['Sun','Mon','Tue','Wed','Thu','Fri','Sat'].indexOf(o.weekday),mins:(+o.hour)*60+(+o.minute)}}
function isOpenNow(d){const n=romeNow(d),h=day(n.dow);return h.open&&n.mins>=h.from&&n.mins<h.to}
function summary(lang){
 const N=NAMES[lang]||NAMES.it,groups=new Map(),closed=[];
 for(const dow of ORDER){const h=day(dow);if(!h.open){closed.push(dow);continue}const k=h.fromText+'–'+h.toText;if(!groups.has(k))groups.set(k,[]);groups.get(k).push(dow)}
 const parts=[];
 for(const [range,list] of groups){
  const idx=list.map(d=>ORDER.indexOf(d)),runs=[];let s=0;
  for(let i=1;i<=idx.length;i++){if(i===idx.length||idx[i]!==idx[i-1]+1){runs.push(idx.slice(s,i));s=i}}
  const names=runs.map(r=>r.length>=3?N.s[ORDER[r[0]]]+'–'+N.s[ORDER[r[r.length-1]]]:r.map(i=>N.s[ORDER[i]]).join(', ')).join(', ');
  parts.push(names+' '+range);
 }
 let out=parts.join(' · ');
 if(closed.length)out+=(out?'. ':'')+N.closed+': '+closed.map(d=>N.l[d]).join(', ');
 return out+(closed.length?'':'');
}
function load(){
 if(loaded)return loaded;
 loaded=fetch(SUPA+'/rest/v1/rpc/argo_public_hours',{method:'POST',headers:{apikey:KEY,'Content-Type':'application/json'},body:'{}'})
  .then(r=>r.ok?r.json():Promise.reject(r.status))
  .then(h=>{if(valid(h)){data=h;try{localStorage.setItem(CK,JSON.stringify(h))}catch(e){}}return data})
  .catch(()=>data);
 return loaded;
}
window.ARGO_HOURS={load,get:()=>data,day,romeNow,isOpenNow,summary,fallback:FALLBACK,names:NAMES,minsToText:m=>String(Math.floor(m/60)).padStart(2,'0')+':'+String(m%60).padStart(2,'0')};
})();
