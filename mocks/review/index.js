const { start, id } = require('../lib/server');

// Plan Review Service. A reviewer picks the application up, and the first
// pass almost always comes back with corrections.
const reviews = new Map();
const DECIDE_AFTER_MS = 12000;

const CORRECTIONS = [
  {
    code: 'STR-204',
    narrative: 'Framing plan does not show the header size over the new opening on the north elevation.',
    citation: 'MBC 2308.4.1'
  },
  {
    code: 'EGR-110',
    narrative: 'Egress window in the converted bedroom is below the minimum clear opening.',
    citation: 'MBC 1030.2'
  }
];

start('review', [
  {
    method: 'POST',
    path: /^\/reviews$/,
    handle: ({ body }) => {
      const reviewId = id('rv');
      const cycle = Number(body.cycle || 1);

      reviews.set(reviewId, {
        status: 'queued',
        cycle,
        reference: body.reference,
        decideAt: Date.now() + DECIDE_AFTER_MS
      });

      return { status: 202, body: { review_id: reviewId, status: 'queued' } };
    }
  },
  {
    method: 'GET',
    path: /^\/reviews\/([\w-]+)$/,
    handle: ({ params }) => {
      const review = reviews.get(params[0]);
      if (!review) return { status: 404, body: { error: 'unknown review' } };

      if (Date.now() < review.decideAt) {
        return { status: 200, body: { status: 'in_progress' } };
      }

      if (review.cycle === 1) {
        return {
          status: 200,
          body: {
            status: 'decided',
            outcome: 'corrections_required',
            summary: 'Two items to resolve before this can be approved.',
            items: CORRECTIONS
          }
        };
      }

      return {
        status: 200,
        body: {
          status: 'decided',
          outcome: 'approved',
          summary: 'Corrections resolved. Approved for fee assessment.'
        }
      };
    }
  }
]);
