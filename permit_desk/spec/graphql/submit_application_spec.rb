require 'rails_helper'

RSpec.describe 'submitApplication mutation' do
  before { allow(ZoningDispatchJob).to receive(:perform_async) }

  let(:account) { an_account }
  let(:application) { an_application(account: account) }

  def execute(reference)
    PermitDeskSchema.execute(
      'mutation Submit($reference: String!) {
         submitApplication(reference: $reference) { application { state } errors }
       }',
      variables: { 'reference' => reference },
      context: { account: account }
    )
  end

  it 'submits an application the account owns' do
    result = execute(application.reference)
    expect(result.dig('data', 'submitApplication', 'application', 'state')).to eq('submitted')
  end

  it 'does not find an application belonging to somebody else' do
    theirs = an_application(account: an_account)
    result = execute(theirs.reference)

    expect(result.dig('data', 'submitApplication', 'errors')).to include('Not found')
  end
end
