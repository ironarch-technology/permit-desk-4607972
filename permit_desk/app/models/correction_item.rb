class CorrectionItem < ApplicationRecord
  belongs_to :permit_application
  has_many :correction_responses, dependent: :destroy

  validates :code, presence: true

  def answered?
    correction_responses.any?
  end
end
