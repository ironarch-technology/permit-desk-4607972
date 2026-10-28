# Hands the application to the plan review queue and starts chasing the
# decision.
class ReviewSubmissionJob < ApplicationJob
  def perform(application_id)
    application = PermitApplication.find(application_id)
    return unless application.state == 'plan_review'

    cycle = application.current_cycle + 1
    review_id = Clients::ReviewClient.new.enqueue(application, cycle: cycle)

    if review_id.nil?
      ReviewSubmissionJob.perform_in(30, application_id)
      return
    end

    ReviewDecisionJob.perform_in(10, application_id, review_id)
  end
end
