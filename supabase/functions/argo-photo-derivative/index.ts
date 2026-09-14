import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const cors={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type","Access-Control-Allow-Methods":"POST, OPTIONS"};
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers:{...cors,"Content-Type":"application/json","X-Content-Type-Options":"nosniff"}});

function jpegDimensions(bytes:Uint8Array){
  if(bytes.length<4||bytes[0]!==0xff||bytes[1]!==0xd8)return null;
  let i=2;
  while(i+8<bytes.length){
    if(bytes[i]!==0xff){i++;continue;}
    const marker=bytes[i+1]; i+=2;
    if(marker===0xd8||marker===0xd9)continue;
    if(i+2>bytes.length)return null;
    const len=(bytes[i]<<8)|bytes[i+1];
    if(len<2||i+len>bytes.length)return null;
    if(len>=7&&((marker>=0xc0&&marker<=0xc3)||(marker>=0xc5&&marker<=0xc7)||(marker>=0xc9&&marker<=0xcb)||(marker>=0xcd&&marker<=0xcf))){
      return {height:(bytes[i+3]<<8)|bytes[i+4],width:(bytes[i+5]<<8)|bytes[i+6]};
    }
    i+=len;
  }
  return null;
}

Deno.serve(async(req:Request)=>{
  if(req.method==="OPTIONS")return new Response("ok",{headers:cors});
  if(req.method!=="POST")return json({error:"Method not allowed"},405);
  if(!(req.headers.get("content-type")||"").toLowerCase().includes("multipart/form-data"))return json({error:"Expected multipart form data"},400);
  try{
    const form=await req.formData();
    const token=String(form.get("admin_token")||"");
    const mediaId=String(form.get("media_id")||"");
    const file=form.get("file");
    if(!token||!/^[0-9a-f-]{36}$/i.test(mediaId)||!(file instanceof File))return json({error:"Missing or invalid fields"},400);
    const sb=createClient(Deno.env.get("SUPABASE_URL")!,Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,{auth:{persistSession:false}});
    const {data:ok,error:authError}=await sb.rpc("argo_admin_valid",{p_token:token});
    if(authError||!ok)return json({error:"Unauthorized"},401);
    if(file.type!=="image/jpeg"||file.size<1000||file.size>3_000_000)return json({error:"Derivative must be a JPEG up to 3 MB"},400);
    const bytes=new Uint8Array(await file.arrayBuffer());
    const dimensions=jpegDimensions(bytes);
    if(!dimensions||dimensions.width!==1200||dimensions.height!==800)return json({error:"Derivative must be exactly 1200x800"},400);
    const {data:media,error:mediaError}=await sb.from("argo_media_library").select("id,active,preview_storage_path").eq("id",mediaId).eq("active",true).maybeSingle();
    if(mediaError||!media)return json({error:"Media not found"},404);
    if(!media.preview_storage_path)return json({error:"Private original required before crop"},409);
    const path=`argo-menu-derivatives/${mediaId}.jpg`;
    const {error:uploadError}=await sb.storage.from("argo-admin-media").upload(path,bytes,{contentType:"image/jpeg",cacheControl:"31536000",upsert:true});
    if(uploadError)return json({error:"Derivative upload failed"},500);
    const {error:updateError}=await sb.from("argo_media_library").update({menu_derivative_storage_path:path,menu_derivative_ready:true}).eq("id",mediaId).eq("active",true);
    if(updateError)return json({error:"Derivative saved but QA state update failed"},500);
    return json({ok:true,media_id:mediaId,width:dimensions.width,height:dimensions.height});
  }catch(e){return json({error:e instanceof Error?e.message:String(e)},500);}
});
