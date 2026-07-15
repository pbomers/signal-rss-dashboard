// Ember sync proxy — Vercel serverless function.
// Holds the Supabase service_role key server-side; the browser never sees it.
// The client authenticates with a token = sha256(passcode), sent as `x-ember-owner`.
// That token is also the tenant key (ember_state.owner), so each passcode maps to
// exactly one JSON blob. RLS on ember_state has no policies, so only this route
// (service_role) can read/write it.
//
// Env vars (set in Vercel project settings):
//   SUPABASE_URL           e.g. https://fuzisxdefycuwkhbuynx.supabase.co
//   SUPABASE_SERVICE_ROLE  the project's service_role (secret) key

const TABLE = 'ember_state';

function send(res, status, body) {
  res.statusCode = status;
  res.setHeader('content-type', 'application/json');
  res.setHeader('cache-control', 'no-store');
  res.end(JSON.stringify(body));
}

async function readBody(req) {
  if (req.body !== undefined) return typeof req.body === 'string' ? JSON.parse(req.body || '{}') : req.body;
  const chunks = [];
  for await (const c of req) chunks.push(c);
  const raw = Buffer.concat(chunks).toString('utf8');
  return raw ? JSON.parse(raw) : {};
}

module.exports = async (req, res) => {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE;
  if (!url || !key) return send(res, 500, { error: 'server not configured' });

  const owner = String(req.headers['x-ember-owner'] || '');
  if (!/^[0-9a-f]{64}$/.test(owner)) return send(res, 401, { error: 'bad or missing owner token' });

  const rest = `${url}/rest/v1/${TABLE}`;
  const headers = { apikey: key, authorization: `Bearer ${key}`, 'content-type': 'application/json' };

  try {
    if (req.method === 'GET') {
      const r = await fetch(`${rest}?owner=eq.${owner}&select=data,updated_at`, { headers });
      if (!r.ok) return send(res, 502, { error: 'supabase read failed', detail: await r.text() });
      const rows = await r.json();
      const row = rows[0];
      return send(res, 200, row ? { data: row.data, updatedAt: row.updated_at } : { data: null, updatedAt: null });
    }

    if (req.method === 'PUT' || req.method === 'POST') {
      const body = await readBody(req);
      if (!body || typeof body.data !== 'object' || body.data === null) return send(res, 400, { error: 'data object required' });
      const row = { owner, data: body.data, updated_at: new Date().toISOString() };
      const r = await fetch(rest, {
        method: 'POST',
        headers: { ...headers, prefer: 'resolution=merge-duplicates,return=representation' },
        body: JSON.stringify(row),
      });
      if (!r.ok) return send(res, 502, { error: 'supabase write failed', detail: await r.text() });
      const saved = (await r.json())[0];
      return send(res, 200, { data: saved.data, updatedAt: saved.updated_at });
    }

    res.setHeader('allow', 'GET, PUT');
    return send(res, 405, { error: 'method not allowed' });
  } catch (e) {
    return send(res, 500, { error: 'sync failed', detail: String(e && e.message || e) });
  }
};
