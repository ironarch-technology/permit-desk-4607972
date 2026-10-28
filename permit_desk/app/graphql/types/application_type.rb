module Types
  class ApplicationType < BaseObject
    field :reference, String, null: false
    field :state, String, null: false
    field :work_type, String, null: false
    field :scope_narrative, String, null: true
    field :valuation_cents, Integer, null: false
    field :applicant_name, String, null: true
    field :permit_number, String, null: true
    field :issued_at, GraphQL::Types::ISO8601DateTime, null: true
    field :valid_until, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :parcel, ParcelType, null: true
    field :transitions, [TransitionType], null: false
    field :correction_items, [CorrectionItemType], null: false
    field :fee_quote, FeeQuoteType, null: true

    def fee_quote
      object.current_quote
    end
  end
end
