# Issues the permit once cashiering confirms capture.
class Issuance
  VALIDITY = 180.days

  def self.call(application, capture_reference:, amount_cents:)
    application.payments.create!(
      capture_reference: capture_reference,
      amount_cents: amount_cents,
      status: 'captured'
    )

    application.update!(
      state: 'issued',
      permit_number: PermitNumbering.next_number,
      issued_at: Time.current,
      valid_until: Time.current + VALIDITY
    )

    application.transitions.create!(
      from_state: 'fees_assessed',
      to_state: 'issued',
      actor: 'cashiering',
      source_system: 'cashiering',
      reason: "capture #{capture_reference}"
    )

    application
  end
end
