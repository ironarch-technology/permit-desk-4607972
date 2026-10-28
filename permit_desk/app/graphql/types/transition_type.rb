module Types
  class TransitionType < BaseObject
    field :from_state, String, null: true
    field :to_state, String, null: false
    field :actor, String, null: false
    field :source_system, String, null: true
    field :reason, String, null: true
    field :recorded_at, GraphQL::Types::ISO8601DateTime, null: false

    def recorded_at
      object.created_at
    end
  end
end
