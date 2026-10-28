class PermitApplication < ApplicationRecord
  WORK_TYPES = %w[residential_addition residential_remodel commercial_tenant_improvement reroof solar_pv].freeze

  STATES = %w[
    draft submitted zoning_check zoning_hold plan_review corrections_required
    fees_assessed issued denied withdrawn expired
  ].freeze

  TERMINAL_STATES = %w[denied withdrawn expired].freeze

  VALUATION_CEILING_CENTS = 200_000_000

  belongs_to :account
  belongs_to :parcel, optional: true

  has_many :transitions, -> { order(:created_at) }, dependent: :destroy
  has_many :zoning_checks, dependent: :destroy
  has_many :correction_items, -> { order(:cycle, :code) }, dependent: :destroy
  has_many :fee_quotes, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :inspection_bookings, dependent: :destroy
  has_many :payments, dependent: :destroy

  validates :reference, presence: true, uniqueness: true
  validates :work_type, inclusion: { in: WORK_TYPES }
  validates :state, inclusion: { in: STATES }
  validates :valuation_cents,
            numericality: { greater_than: 0, less_than_or_equal_to: VALUATION_CEILING_CENTS },
            if: :submitted?

  before_validation :assign_reference, on: :create

  scope :visible_to, ->(account) { account.staff? ? all : where(account_id: account.id) }

  def terminal?
    TERMINAL_STATES.include?(state)
  end

  def submitted?
    submitted_at.present?
  end

  def contractor?
    contractor_licence.present?
  end

  def current_quote
    fee_quotes.first
  end

  def current_cycle
    correction_items.maximum(:cycle) || 0
  end

  def outstanding_corrections
    correction_items.where(cycle: current_cycle)
  end

  private

  def assign_reference
    self.reference ||= "MP-#{Time.current.year}-#{SecureRandom.hex(4).upcase}"
  end
end
