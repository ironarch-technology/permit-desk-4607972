module Mutations
  class InitiatePayment < BaseMutation
    argument :reference, String
    argument :amount_cents, Integer
    argument :quote_reference, String

    field :capture_reference, String, null: true
    field :errors, [String], null: false

    def resolve(reference:, amount_cents:, quote_reference:)
      application = find_application(reference)
      return { capture_reference: nil, errors: ['Not found'] } if application.nil?

      capture = Clients::CashieringClient.new.start_capture(
        reference: application.reference,
        amount_cents: amount_cents,
        quote_reference: quote_reference
      )

      { capture_reference: capture['capture_reference'], errors: [] }
    rescue Clients::ServiceError => e
      { capture_reference: nil, errors: [e.message] }
    end
  end
end
