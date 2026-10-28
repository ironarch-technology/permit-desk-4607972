class ZoningCheck < ApplicationRecord
  belongs_to :permit_application

  validates :handle, presence: true

  scope :outstanding, -> { where(settled_at: nil) }
end
