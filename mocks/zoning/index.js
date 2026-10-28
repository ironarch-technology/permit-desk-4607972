const { start, id } = require('../lib/server');

// Parcel & Zoning Service. Checks settle a little while after they are
// submitted. The index rebuild runs nightly at 2am and the service is out
// for about ten minutes while it runs.
const checks = new Map();
const SETTLE_AFTER_MS = 6000;
const PERMIT_DESK_URL = process.env.PERMIT_DESK_URL;

// Parcels whose records disagree with the county layer. The counter has to
// sort these out by hand.
const CONFLICTED = ['640 Quarry Bend'];

function rebuilding() {
  const now = new Date();
  return now.getHours() === 2 && now.getMinutes() < 10;
}

function outcomeFor(address) {
  if (CONFLICTED.includes(address)) {
    return { result: 'indeterminate', detail: 'Parcel boundary disagrees with the county layer.' };
  }
  return { result: 'pass', detail: 'Scope is permissible under the current designation.' };
}

async function notify(handle, record) {
  if (!PERMIT_DESK_URL) return;
  try {
    await fetch(`${PERMIT_DESK_URL}/hooks/zoning`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ handle, result: record.result, detail: record.detail })
    });
  } catch (err) {
    console.error(`[zoning] webhook for ${handle} failed: ${err.message}`);
  }
}

start('zoning', [
  {
    method: 'POST',
    path: /^\/checks$/,
    handle: ({ body }) => {
      if (rebuilding()) {
        return { status: 503, body: { error: 'parcel index rebuilding' } };
      }

      const handle = id('zc');
      const outcome = outcomeFor(body.parcel_address);
      const record = { status: 'pending', settleAt: Date.now() + SETTLE_AFTER_MS, ...outcome };
      checks.set(handle, record);

      setTimeout(() => {
        record.status = 'settled';
        notify(handle, record);
      }, SETTLE_AFTER_MS);

      return { status: 202, body: { handle, status: 'pending' } };
    }
  },
  {
    method: 'GET',
    path: /^\/checks\/([\w-]+)$/,
    handle: ({ params }) => {
      if (rebuilding()) {
        return { status: 503, body: { error: 'parcel index rebuilding' } };
      }

      const record = checks.get(params[0]);
      if (!record) return { status: 404, body: { error: 'unknown handle' } };

      return {
        status: 200,
        body: { status: record.status, result: record.result, detail: record.detail }
      };
    }
  }
]);
