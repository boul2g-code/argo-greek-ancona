import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const norm = (value: string) => value.trim().toLowerCase();
const allowedTypes = new Set(["image/jpeg", "image/jpg", "image/png", "image/webp", "image/gif"]);

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405, headers: cors });
  if (!String(req.headers.get("content-type") || "").toLowerCase().includes("multipart/form-data")) {
    return new Response("Expected multipart form data", { status: 400, headers: cors });
  }

  try {
    const form = await req.formData();
    const adminToken = String(form.get("admin_token") || "");
    const requestedMediaId = String(form.get("media_id") || "");
    const file = form.get("file");
    if (!adminToken || !(file instanceof File)) return new Response("Missing fields", { status: 400, headers: cors });
    if (!allowedTypes.has(file.type)) return new Response("Unsupported image type", { status: 415, headers: cors });
    if (file.size > 5 * 1024 * 1024) return new Response("File too large", { status: 413, headers: cors });
    if (!file.name.trim() || file.name.length > 180) return new Response("Invalid filename", { status: 400, headers: cors });

    const url = Deno.env.get("SUPABASE_URL")!;
    const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const sb = createClient(url, service, { auth: { persistSession: false } });
    const { data: ok, error: authErr } = await sb.rpc("argo_admin_valid", { p_token: adminToken });
    if (authErr || !ok) return new Response("Unauthorized", { status: 401, headers: cors });

    let mediaId = requestedMediaId;
    let sourceFilename = file.name.trim();
    let created = false;

    if (mediaId) {
      const { data: media, error: mediaErr } = await sb.from("argo_media_library")
        .select("id,source_filename,active").eq("id", mediaId).eq("active", true).maybeSingle();
      if (mediaErr || !media) return new Response("Media not found", { status: 404, headers: cors });
      sourceFilename = media.source_filename || "";
      if (norm(file.name) !== norm(sourceFilename)) {
        return new Response(`Filename mismatch: expected ${sourceFilename}`, { status: 409, headers: cors });
      }
    } else {
      const { data: media, error: insertErr } = await sb.from("argo_media_library").insert({
        title: sourceFilename,
        source_filename: sourceFilename,
        category: "menu_candidate",
        recommended_for: "Nuova fotografia ARGO: identificare il prodotto e verificare porzione, composizione e plating.",
        status: "future",
        notes: "Caricata dal nuovo shooting; nessun collegamento o pubblicazione automatica.",
        active: true,
        sort_order: 10,
      }).select("id").single();
      if (insertErr || !media) return new Response(`DB insert failed: ${insertErr?.message || "unknown"}`, { status: 500, headers: cors });
      mediaId = media.id;
      created = true;
    }

    const ext = file.type === "image/png" ? "png" : file.type === "image/webp" ? "webp" : file.type === "image/gif" ? "gif" : "jpg";
    const path = `argo-library/${mediaId}.${ext}`;
    const bytes = new Uint8Array(await file.arrayBuffer());
    const { error: uploadErr } = await sb.storage.from("argo-admin-media").upload(path, bytes, {
      contentType: file.type,
      upsert: !created,
      cacheControl: "31536000",
    });
    if (uploadErr) {
      if (created) await sb.from("argo_media_library").delete().eq("id", mediaId);
      return new Response(`Upload failed: ${uploadErr.message}`, { status: 500, headers: cors });
    }

    const { error: updateErr } = await sb.from("argo_media_library").update({ preview_storage_path: path }).eq("id", mediaId);
    if (updateErr) {
      await sb.storage.from("argo-admin-media").remove([path]);
      if (created) await sb.from("argo_media_library").delete().eq("id", mediaId);
      return new Response(`DB update failed: ${updateErr.message}`, { status: 500, headers: cors });
    }

    return new Response(JSON.stringify({ ok: true, created, media_id: mediaId, filename: sourceFilename, preview_storage_path: path }), {
      status: 200,
      headers: { ...cors, "Content-Type": "application/json", "Cache-Control": "no-store" },
    });
  } catch (error) {
    return new Response(`Import error: ${error instanceof Error ? error.message : String(error)}`, { status: 500, headers: cors });
  }
});
