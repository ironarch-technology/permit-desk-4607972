module Types
  class FeeQuoteType < BaseObject
    field :quote_reference, String, null: false
    field :total_cents, Integer, null: false
    field :breakdown, GraphQL::Types::JSON, null: false
    field :expires_at, GraphQL::Types::ISO8601DateTime, null: false
    field :expired, Boolean, null: false

    def expired
      object.expired?
    end
  end
end
