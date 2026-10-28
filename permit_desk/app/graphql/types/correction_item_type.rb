module Types
  class CorrectionItemType < BaseObject
    field :id, ID, null: false
    field :cycle, Integer, null: false
    field :code, String, null: false
    field :narrative, String, null: true
    field :citation, String, null: true
    field :answered, Boolean, null: false

    def answered
      object.answered?
    end
  end
end
