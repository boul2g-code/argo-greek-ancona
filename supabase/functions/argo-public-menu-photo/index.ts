import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const cors={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"GET, OPTIONS"};
const common={...cors,"X-Content-Type-Options":"nosniff"};
const approvedRepoPrefix="https://boul2g-code.github.io/argo-greek-ancona/assets/menu/verified/";
function b64ToBytes(v:string){const bin=atob(v);const out=new Uint8Array(bin.length);for(let i=0;i<bin.length;i++)out[i]=bin.charCodeAt(i);return out;}

Deno.serve(async(req:Request)=>{
  if(req.method==="OPTIONS") return new Response("ok",{headers:cors});
  if(req.method!=="GET") return new Response("Method not allowed",{status:405,headers:common});
  const item=new URL(req.url).searchParams.get("item")||"";
  if(!/^[0-9a-f-]{36}$/i.test(item)) return new Response("Bad item",{status:400,headers:common});
  const sb=createClient(Deno.env.get("SUPABASE_URL")!,Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,{auth:{persistSession:false}});
  const {data:media,error}=await sb.from("argo_media_library").select("menu_derivative_storage_path")
    .eq("linked_menu_item_id",item).eq("category","menu_verified").eq("status","menu").eq("menu_derivative_ready",true).eq("active",true).maybeSingle();
  if(error||!media) return new Response("Approved derivative not available",{status:404,headers:{...common,"Cache-Control":"public, max-age=60"}});
  const {data:cached}=await sb.from("argo_public_menu_photo_cache").select("image_b64,mime_type").eq("item_id",item).maybeSingle();
  if(cached?.image_b64) try{
    return new Response(b64ToBytes(cached.image_b64),{status:200,headers:{...common,"Content-Type":cached.mime_type||"image/jpeg","Cache-Control":"public, max-age=31536000, immutable","X-ARGO-Photo":"verified-cache-v5"}});
  }catch(_){ }
  if(media.menu_derivative_storage_path){
    const {data:blob,error:dlErr}=await sb.storage.from("argo-admin-media").download(media.menu_derivative_storage_path);
    if(!dlErr&&blob) return new Response(await blob.arrayBuffer(),{status:200,headers:{...common,"Content-Type":blob.type||"image/jpeg","Cache-Control":"public, max-age=300","X-ARGO-Photo":"verified-private-derivative-v6"}});
  }
  const {data:menuItem}=await sb.from("argo_menu_items").select("image_url").eq("id",item).eq("active",true).maybeSingle();
  const approvedUrl=String(menuItem?.image_url||"");
  if(approvedUrl.startsWith(approvedRepoPrefix)) try{
    const r=await fetch(approvedUrl,{redirect:"follow"}); const ct=(r.headers.get("content-type")||"").toLowerCase();
    if(r.ok&&ct.startsWith("image/")){const buf=await r.arrayBuffer();if(buf.byteLength>=1000&&buf.byteLength<=5_000_000)return new Response(buf,{status:200,headers:{...common,"Content-Type":ct.split(";")[0]||"image/jpeg","Cache-Control":"public, max-age=86400","X-ARGO-Photo":"verified-repo-derivative-v5"}});}
  }catch(_){ }
  return new Response("Approved derivative source unavailable",{status:404,headers:{...common,"Cache-Control":"public, max-age=60"}});
});
