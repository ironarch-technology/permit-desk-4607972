class InspectionBooking < ApplicationRecord
  belongs_to :permit_application

  validates :slot_id, :inspection_type, presence: true
end
