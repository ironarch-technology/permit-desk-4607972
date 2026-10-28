# Submits the zoning check and records the handle the service gives us.
class ZoningDispatchJob < ApplicationJob
  INLINE_ATTEMPTS = 3
  INLINE_WAIT = 2

  def perform(application_id)
    application = PermitApplication.find(application_id)
    return unless application.state == 'submitted'

    client = Clients::ZoningClient.new
    handle = client.submit(application)
    check = application.zoning_checks.create!(handle: handle)

    Lifecycle.transition!(
      application,
      to: 'zoning_check',
      actor: 'system',
      source_system: 'zoning',
      reason: "handle #{handle}"
    )

    # The webhook is the normal path. A quick read straight after dispatch
    # catches the parcels that come back immediately.
    INLINE_ATTEMPTS.times do
      sleep INLINE_WAIT
      payload = client.result(handle)
      next unless payload['status'] == 'settled'

      ZoningResult.new(application.reload).apply(check, payload['result'], payload['detail'])
      break
    end
  end
end
