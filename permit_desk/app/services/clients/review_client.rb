module Clients
  # Plan Review Service. Returns nil when the queue will not take the
  # application, which the caller treats as "try again on the next pass".
  class ReviewClient
    def initialize(http = Http.new(ENV.fetch('REVIEW_URL')))
      @http = http
    end

    def enqueue(application, cycle:)
      response = @http.post('/reviews', {
        reference: application.reference,
        cycle: cycle,
        work_type: application.work_type,
        valuation_cents: application.valuation_cents,
        scope: application.scope_narrative
      })
      return nil unless response.ok?

      response.body['review_id']
    rescue ServiceError
      nil
    end

    def decision(review_id)
      response = @http.get("/reviews/#{review_id}")
      return nil unless response.ok?

      response.body
    rescue ServiceError
      nil
    end
  end
end
