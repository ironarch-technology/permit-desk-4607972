const { start, id } = require('../lib/server');

// Inspection Scheduler. Slots are shared across the whole city, so the one
// you were looking at can be gone by the time you click.
const taken = new Set();
const bookings = new Map();

const CAPACITY = {
  footing: 3,
  framing: 4,
  final: 2
};

function slotsFor(type) {
  const perDay = CAPACITY[type] || 2;
  const out = [];
  const base = new Date();
  base.setHours(8, 0, 0, 0);

  for (let day = 2; day <= 6; day += 1) {
    for (let n = 0; n < perDay; n += 1) {
      const starts = new Date(base);
      starts.setDate(starts.getDate() + day);
      starts.setHours(8 + n * 2);
      const slotId = `${type}-${starts.toISOString().slice(0, 10)}-${starts.getHours()}`;
      if (taken.has(slotId)) continue;
      out.push({ id: slotId, starts_at: starts.toISOString(), inspection_type: type });
    }
  }

  return out;
}

start('scheduling', [
  {
    method: 'GET',
    path: /^\/slots$/,
    handle: ({ query }) => {
      const type = query.get('inspection_type') || 'footing';
      return { status: 200, body: { slots: slotsFor(type) } };
    }
  },
  {
    method: 'POST',
    path: /^\/bookings$/,
    handle: ({ body }) => {
      const slotId = body.slot_id;
      const type = body.inspection_type || 'footing';

      if (taken.has(slotId)) {
        return {
          status: 409,
          body: { error: 'slot already booked', alternatives: slotsFor(type) }
        };
      }

      taken.add(slotId);
      const bookingId = id('bk');
      const scheduledFor = slotId.split('-').slice(1).join('-');
      bookings.set(bookingId, { slotId, reference: body.reference });

      return {
        status: 201,
        body: {
          booking_id: bookingId,
          slot_id: slotId,
          scheduled_for: new Date(`${scheduledFor.slice(0, 10)}T${String(scheduledFor.slice(11)).padStart(2, '0')}:00:00Z`).toISOString()
        }
      };
    }
  }
]);
