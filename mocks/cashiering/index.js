const { start, id } = require('../lib/server');

// Cashiering Service. Fee calculation is synchronous. Capture happens on the
// city payment page and is confirmed back over the webhook.
const PERMIT_DESK_URL = process.env.PERMIT_DESK_URL;
const CAPTURE_AFTER_MS = 5000;
const QUOTE_VALID_DAYS = 30;

const BASE_FEE_CENTS = {
  residential_addition: 42000,
  residential_remodel: 31000,
  commercial_tenant_improvement: 98000,
  reroof: 18000,
  solar_pv: 15000
};

const DISTRICT_SURCHARGE_CENTS = {
  'Harbor District': 12000,
  'Quarry Hill': 8000
};

function quoteFor(body) {
  const base = BASE_FEE_CENTS[body.work_type] || 25000;
  const valuation = Number(body.valuation_cents || 0);
  const planCheck = Math.round(valuation * 0.0045);
  const surcharge = DISTRICT_SURCHARGE_CENTS[body.district] || 0;
  const records = 4500;

  const breakdown = {
    base_permit_fee: base,
    plan_check: planCheck,
    records_retention: records
  };
  if (surcharge > 0) breakdown.district_surcharge = surcharge;

  const total = Object.values(breakdown).reduce((sum, cents) => sum + cents, 0);
  const expires = new Date(Date.now() + QUOTE_VALID_DAYS * 24 * 60 * 60 * 1000);

  return {
    quote_reference: id('fq'),
    total_cents: total,
    breakdown,
    expires_at: expires.toISOString()
  };
}

async function confirm(reference, captureReference, amountCents) {
  if (!PERMIT_DESK_URL) return;
  try {
    await fetch(`${PERMIT_DESK_URL}/hooks/cashiering`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        reference,
        capture_reference: captureReference,
        amount_cents: amountCents,
        status: 'captured'
      })
    });
  } catch (err) {
    console.error(`[cashiering] confirmation for ${reference} failed: ${err.message}`);
  }
}

start('cashiering', [
  {
    method: 'POST',
    path: /^\/quotes$/,
    handle: ({ body }) => ({ status: 200, body: quoteFor(body) })
  },
  {
    method: 'POST',
    path: /^\/captures$/,
    handle: ({ body }) => {
      const captureReference = id('cap');

      setTimeout(() => {
        confirm(body.reference, captureReference, Number(body.amount_cents || 0));
      }, CAPTURE_AFTER_MS);

      return {
        status: 202,
        body: { capture_reference: captureReference, status: 'pending' }
      };
    }
  }
]);
