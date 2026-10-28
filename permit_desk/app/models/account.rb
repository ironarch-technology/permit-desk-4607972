class Account < ApplicationRecord
  has_secure_password

  ROLES = %w[applicant technician].freeze

  has_many :permit_applications, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :role, inclusion: { in: ROLES }

  def staff?
    role == 'technician'
  end
end
