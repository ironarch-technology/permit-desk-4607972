require 'rails_helper'

RSpec.describe Clients::ZoningClient do
  let(:http) { instance_double(Clients::Http) }
  let(:client) { described_class.new(http) }
  let(:application) { an_application }

  describe '#submit' do
    before do
      allow(client).to receive(:submit).and_return('zc-8f21ad44')
    end

    it 'returns the handle the service issued' do
      expect(client.submit(application)).to eq('zc-8f21ad44')
    end
  end

  describe '#result' do
    before do
      allow(client).to receive(:result).and_return(
        'status' => 'settled',
        'result' => 'pass',
        'detail' => 'Scope is permissible under the current designation.'
      )
    end

    it 'reports the settled outcome' do
      expect(client.result('zc-8f21ad44')['result']).to eq('pass')
    end

    it 'carries the detail through' do
      expect(client.result('zc-8f21ad44')['detail']).to include('permissible')
    end
  end
end
