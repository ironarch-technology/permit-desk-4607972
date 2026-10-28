module Clients
  # Inspection Scheduler. Slot searches are contended, so every call comes back
  # as a result object the caller has to look at rather than an exception.
  class SchedulingClient
    Outcome = Struct.new(:ok, :data, :error, keyword_init: true) do
      def ok?
        ok
      end
    end

    def initialize(http = Http.new(ENV.fetch('SCHEDULING_URL')))
      @http = http
    end

    def slots(inspection_type:, district:)
      response = @http.get('/slots', { inspection_type: inspection_type, district: district })
      return Outcome.new(ok: false, error: 'slot search unavailable') unless response.ok?

      Outcome.new(ok: true, data: response.body['slots'] || [])
    rescue ServiceError => e
      Outcome.new(ok: false, error: e.message)
    end

    def book(slot_id:, reference:, inspection_type:)
      response = @http.post('/bookings', {
        slot_id: slot_id, reference: reference, inspection_type: inspection_type
      })

      if response.status == 409
        return Outcome.new(ok: false, error: 'slot_taken', data: response.body['alternatives'] || [])
      end

      return Outcome.new(ok: false, error: 'booking rejected') unless response.ok?

      Outcome.new(ok: true, data: response.body)
    rescue ServiceError => e
      Outcome.new(ok: false, error: e.message)
    end
  end
end
