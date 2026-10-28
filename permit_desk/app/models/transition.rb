class Transition < ApplicationRecord
  belongs_to :permit_application

  validates :to_state, :actor, presence: true
end
