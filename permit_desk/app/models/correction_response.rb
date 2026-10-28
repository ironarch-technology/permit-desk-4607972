class CorrectionResponse < ApplicationRecord
  belongs_to :correction_item

  validates :body, presence: true
end
