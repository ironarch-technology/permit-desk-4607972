# Plan review runs for hours or days, so this keeps asking until the reviewer
# has finished with it.
class ReviewDecisionJob < ApplicationJob
  RECHECK = 10

  def perform(application_id, review_id)
    application = PermitApplication.find(application_id)
    return unless application.state == 'plan_review'

    decision = Clients::ReviewClient.new.decision(review_id)

    if decision.nil? || decision['status'] != 'decided'
      ReviewDecisionJob.perform_in(RECHECK, application_id, review_id)
      return
    end

    case decision['outcome']
    when 'approved'
      FeeAssessment.new(application).call
    when 'denied'
      Lifecycle.transition!(application, to: 'denied', actor: 'plan reviewer',
                                         source_system: 'review', reason: decision['summary'])
    when 'corrections_required'
      record_corrections(application, decision)
    end
  end

  private

  def record_corrections(application, decision)
    cycle = application.current_cycle + 1

    Array(decision['items']).each do |item|
      application.correction_items.create_with(
        narrative: item['narrative'],
        citation: item['citation']
      ).find_or_create_by!(cycle: cycle, code: item['code'])
    end

    application.update!(state: 'corrections_required')
    application.transitions.create!(
      from_state: 'plan_review',
      to_state: 'corrections_required',
      actor: 'plan reviewer',
      source_system: 'review',
      reason: decision['summary']
    )
  end
end
