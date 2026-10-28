class Parcel < ApplicationRecord
  has_many :permit_applications, dependent: :nullify

  validates :address, :district, :zoning_code, presence: true

  def self.resolve(address)
    return nil if address.blank?

    where('lower(address) = ?', address.to_s.strip.downcase).first
  end

  def self.suggest(term, limit: 10)
    return none if term.blank?

    where('address ILIKE ?', "%#{sanitize_sql_like(term.to_s.strip)}%").order(:address).limit(limit)
  end
end
