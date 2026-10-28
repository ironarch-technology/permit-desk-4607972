class FeeQuote < ApplicationRecord
  belongs_to :permit_application

  validates :total_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :quote_reference, :expires_at, presence: true

  after_create :move_application_to_fees_assessed

  def expired?
    expires_at <= Time.current
  end

  def total
    total_cents / 100.0
  end

  private

  def move_application_to_fees_assessed
    permit_application.update_column(:state, 'fees_assessed')
  end
end
