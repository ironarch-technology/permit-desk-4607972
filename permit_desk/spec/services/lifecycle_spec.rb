require 'rails_helper'

RSpec.describe Lifecycle do
  before { allow(ZoningDispatchJob).to receive(:perform_async) }

  it 'moves a draft to submitted' do
    application = an_application
    described_class.transition!(application, to: 'submitted', actor: 'Rosa Linden')

    expect(application.reload.state).to eq('submitted')
  end

  it 'records the transition with its actor' do
    application = an_application
    described_class.transition!(application, to: 'submitted', actor: 'Rosa Linden', reason: 'portal')

    entry = application.transitions.last
    expect(entry.from_state).to eq('draft')
    expect(entry.to_state).to eq('submitted')
    expect(entry.actor).to eq('Rosa Linden')
  end

  it 'refuses a transition the specification does not allow' do
    application = an_application

    expect {
      described_class.transition!(application, to: 'issued', actor: 'Rosa Linden')
    }.to raise_error(Lifecycle::InvalidTransition)
  end

  it 'refuses any transition out of a terminal state' do
    application = an_application(state: 'withdrawn')

    expect {
      described_class.transition!(application, to: 'plan_review', actor: 'counter')
    }.to raise_error(Lifecycle::InvalidTransition)
  end

  it 'allows a withdrawal from a state that is still open' do
    application = an_application(state: 'plan_review')
    described_class.transition!(application, to: 'withdrawn', actor: 'Rosa Linden')

    expect(application.reload.state).to eq('withdrawn')
  end
end
