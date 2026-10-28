class Payment < ApplicationRecord
  belongs_to :permit_application

  validates :capture_reference, presence: true
end
