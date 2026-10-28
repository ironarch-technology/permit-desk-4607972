require 'rails_helper'

RSpec.describe PermitApplication do
  it 'assigns a reference on create' do
    application = an_application
    expect(application.reference).to match(/\AMP-\d{4}-[0-9A-F]{8}\z/)
  end

  it 'treats denied, withdrawn and expired as terminal' do
    %w[denied withdrawn expired].each do |state|
      expect(an_application(state: state)).to be_terminal
    end
  end

  it 'does not treat an issued permit as terminal' do
    expect(an_application(state: 'issued')).not_to be_terminal
  end

  it 'scopes visibility to the owning account for applicants' do
    owner = an_account
    other = an_account
    mine = an_application(account: owner)
    an_application(account: other)

    expect(PermitApplication.visible_to(owner)).to contain_exactly(mine)
  end

  it 'lets counter staff see everything' do
    an_application
    an_application
    staff = an_account(role: 'technician')

    expect(PermitApplication.visible_to(staff).count).to eq(2)
  end

  it 'reports the highest correction cycle' do
    application = an_application(state: 'corrections_required')
    application.correction_items.create!(cycle: 1, code: 'STR-204')
    application.correction_items.create!(cycle: 2, code: 'EGR-110')

    expect(application.current_cycle).to eq(2)
  end
end
