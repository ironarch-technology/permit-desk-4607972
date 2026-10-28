module Clients
  # Cashiering Service. Fee calculation is synchronous; capture is confirmed by
  # webhook. Payment instrument data is handled entirely on their side.
  class CashieringClient
    def initialize(http = Http.new(ENV.fetch('CASHIERING_URL')))
      @http = http
    end

    def quote(application)
      response = @http.post('/quotes', {
        reference: application.reference,
        work_type: application.work_type,
        valuation_cents: application.valuation_cents,
        district: application.parcel&.district
      })
      raise ServiceError.new('fee quote failed', status: response.status) unless response.ok?

      response.body
    end

    def start_capture(reference:, amount_cents:, quote_reference:)
      response = @http.post('/captures', {
        reference: reference,
        amount_cents: amount_cents,
        quote_reference: quote_reference
      })
      raise ServiceError.new('capture could not be started', status: response.status) unless response.ok?

      response.body
    end
  end
end
