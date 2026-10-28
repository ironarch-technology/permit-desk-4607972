ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'
require 'rspec/rails'

abort('The Rails environment is running in production mode!') if Rails.env.production?

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

def an_account(role: 'applicant')
  Account.create!(
    email: "#{SecureRandom.hex(4)}@example.com",
    name: 'Test Applicant',
    password: 'harborlight',
    role: role
  )
end

def a_parcel
  Parcel.create!(
    address: "#{SecureRandom.hex(3)} Test Row",
    district: 'Westfield',
    zoning_code: 'R-1'
  )
end

def an_application(account: nil, state: 'draft', **attrs)
  (account || an_account).permit_applications.create!(
    {
      parcel: a_parcel,
      work_type: 'residential_remodel',
      scope_narrative: 'Convert the back porch into a study.',
      valuation_cents: 4_500_000,
      applicant_name: 'Test Applicant',
      applicant_email: 'test@example.com',
      state: state
    }.merge(attrs)
  )
end
