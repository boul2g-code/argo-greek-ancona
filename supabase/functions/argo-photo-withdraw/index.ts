import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const cors={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type","Access-Control-Allow-Methods":"POST, OPTIONS"};
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers:{...cors,"Content-Type":"application/json","Cache-Control":"no-store","X-Content-Type-Options":"nosniff"}});

Deno.serve(async(req:Request)=>{
  if(req.method==="OPTIONS")return new Response("ok",{headers:cors});
  if(req.method!=="POST")return json({error:"Method not allowed"},405);
  try{
    const {admin_token,item_id}=await req.json();
    if(!admin_token||!/^[0-9a-f-]{36}$/i.test(String(item_id||"")))return json({error:"Missing or invalid fields"},400);
    const sb=createClient(Deno.env.get("SUPABASE_URL")!,Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,{auth:{persistSession:false}});
    const {data,error}=await sb.rpc("argo_admin_withdraw_menu_photo",{p_token:String(admin_token),p_item_id:String(item_id)});
    if(error){
      if(/unauthorized/i.test(error.message))return json({error:"Unauthorized"},401);
      if(/not found/i.test(error.message))return json({error:error.message},404);
      return json({error:"Photo withdrawal failed"},500);
    }
    return json({ok:data===true,item_id});
  }catch(_){return json({error:"Invalid request"},400);}
});
