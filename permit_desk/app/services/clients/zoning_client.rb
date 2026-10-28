module Clients
  # Parcel & Zoning Service. Submit returns a handle immediately; the result
  # arrives either on the webhook or from a direct read of the handle.
  class ZoningClient
    def initialize(http = Http.new(ENV.fetch('ZONING_URL')))
      @http = http
    end

    def submit(application)
      response = @http.post('/checks', {
        parcel_address: application.parcel&.address,
        work_type: application.work_type,
        valuation_cents: application.valuation_cents,
        scope: application.scope_narrative
      })
      raise ServiceError.new('zoning rejected the check', status: response.status) unless response.ok?

      response.body['handle']
    end

    def result(handle)
      response = @http.get("/checks/#{handle}")
      raise ServiceError.new('zoning handle not readable', status: response.status) unless response.ok?

      response.body
    end
  end
end
