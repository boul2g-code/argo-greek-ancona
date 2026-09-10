const net = require('net');
const fs = require('fs');
const path = require('path');

// Load a local .env without external dependencies.
const envPath = path.join(__dirname, '.env');
if (fs.existsSync(envPath)) {
  for (const raw of fs.readFileSync(envPath, 'utf8').split(/\r?\n/)) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;
    const i = line.indexOf('=');
    if (i > 0 && process.env[line.slice(0, i)] == null) process.env[line.slice(0, i)] = line.slice(i + 1);
  }
}

const cfg = {
  url: process.env.SUPABASE_URL || 'https://zibubwrntdmdxyimqddo.supabase.co',
  key: process.env.SUPABASE_KEY || 'sb_publishable_IGXGYoh2jg1ardyg9jW3vg_DTybVlOL',
  email: process.env.ARGO_ADMIN_EMAIL,
  password: process.env.ARGO_ADMIN_PASSWORD,
  host: process.env.PRINTER_HOST || '192.168.1.130',
  port: Number(process.env.PRINTER_PORT || 9100),
  poll: Number(process.env.POLL_MS || 2500)
};
if (!cfg.email || !cfg.password) {
  console.error('Missing ARGO_ADMIN_EMAIL / ARGO_ADMIN_PASSWORD in print-bridge/.env');
  process.exit(1);
}

let token = null;
let baselineReady = false;
const seen = new Map();
let busy = false;

async function rpc(name, body) {
  const r = await fetch(`${cfg.url}/rest/v1/rpc/${name}`, {
    method: 'POST',
    headers: { apikey: cfg.key, Authorization: `Bearer ${cfg.key}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });
  if (!r.ok) throw new Error(`${name}: ${r.status} ${await r.text()}`);
  return r.json();
}

async function login() {
  token = await rpc('argo_admin_login', { p_email: cfg.email, p_password: cfg.password });
  console.log('ARGO admin session ready');
}

const euro = n => Number(n || 0).toFixed(2).replace('.', ',');
const clean = s => String(s || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[^\x20-\x7E]/g, '?');
const hr = () => '------------------------------------------\n';

function ticket(o) {
  const out = [];
  out.push('\x1b@');                 // initialize
  out.push('\x1ba\x01');            // center
  out.push('\x1bE\x01');            // bold on
  out.push('ARGO GREEK COMFORT FOOD\n');
  out.push('*** ORDINE SITO ***\n');
  out.push('\x1bE\x00\x1ba\x00'); // bold off, left
  out.push(hr());
  out.push('\x1d!\x11');            // double size
  out.push(`#${o.order_number}  ${clean(o.order_type).toUpperCase()}\n`);
  out.push('\x1d!\x00');
  out.push(`${new Date(o.created_at).toLocaleString('it-IT')}\n`);
  if (o.requested_at) out.push(`RICHIESTO: ${new Date(o.requested_at).toLocaleTimeString('it-IT',{hour:'2-digit',minute:'2-digit'})}\n`);
  out.push(hr());
  out.push(`CLIENTE: ${clean(o.customer_name)}\nTEL: ${clean(o.phone)}\n`);
  if (o.address) out.push(`INDIRIZZO: ${clean(o.address)}\n`);
  out.push(hr());
  for (const i of (o.items || [])) {
    out.push('\x1bE\x01');
    out.push(`${i.quantity} x ${clean(i.name)}\n`);
    out.push('\x1bE\x00');
    if (i.modifiers && Array.isArray(i.modifiers)) {
      for (const m of i.modifiers) out.push(`   + ${clean(m.label || m.name || m)}\n`);
    }
    if (i.notes) out.push(`   NOTE: ${clean(i.notes)}\n`);
  }
  out.push(hr());
  if (o.notes) out.push(`NOTE ORDINE: ${clean(o.notes)}\n${hr()}`);
  if (Number(o.discount_amount) > 0) {
    out.push(`SUBTOTALE EUR ${euro(o.subtotal)}\n`);
    out.push(`SCONTO ${clean(o.promo_code)} - EUR ${euro(o.discount_amount)}\n`);
  }
  out.push('\x1bE\x01\x1d!\x11');
  out.push(`TOTALE EUR ${euro(o.total)}\n`);
  out.push('\x1d!\x00\x1bE\x00');
  out.push(`PAGAMENTO: ${clean(o.payment_method).toUpperCase()}\n`);
  out.push('\n\x1ba\x01--- ARGO SITO WEB ---\n\n\n');
  out.push('\x1dV\x00');            // full cut
  return Buffer.from(out.join(''), 'binary');
}

function sendToPrinter(buf) {
  return new Promise((resolve, reject) => {
    const s = net.createConnection({ host: cfg.host, port: cfg.port, timeout: 5000 });
    s.on('connect', () => s.end(buf));
    s.on('timeout', () => s.destroy(new Error('printer timeout')));
    s.on('error', reject);
    s.on('close', hadError => { if (!hadError) resolve(); });
  });
}

async function poll() {
  if (busy) return;
  busy = true;
  try {
    if (!token) await login();
    let orders;
    try { orders = await rpc('argo_admin_orders', { p_token: token }); }
    catch (e) {
      if (/unauthorized/i.test(String(e))) { token = null; await login(); orders = await rpc('argo_admin_orders', { p_token: token }); }
      else throw e;
    }

    // First poll establishes a baseline so restarting the bridge never reprints old tickets.
    if (!baselineReady) {
      for (const o of orders) seen.set(o.id, Number(o.print_count || 0));
      baselineReady = true;
      console.log(`Baseline ready. Watching ${cfg.host}:${cfg.port}`);
      return;
    }

    for (const o of orders) {
      const count = Number(o.print_count || 0);
      const prev = seen.get(o.id) ?? count;
      if (count > prev) {
        try {
          await sendToPrinter(ticket(o));
          seen.set(o.id, count);
          console.log(`PRINTED order #${o.order_number} (${count})`);
        } catch (e) {
          console.error(`PRINT FAILED order #${o.order_number}: ${e.message}`);
          // Do not advance seen: retry on the next poll.
        }
      } else seen.set(o.id, count);
    }
  } catch (e) {
    console.error(new Date().toISOString(), e.message);
  } finally { busy = false; }
}

console.log(`ARGO K44 bridge starting -> ${cfg.host}:${cfg.port}`);
poll();
setInterval(poll, cfg.poll);
