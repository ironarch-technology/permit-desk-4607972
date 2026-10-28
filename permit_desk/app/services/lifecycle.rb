# The state machine. Controllers go through here so that the allowed
# transitions in the specification are the ones that actually happen.
class Lifecycle
  class InvalidTransition < StandardError; end

  ALLOWED = {
    'draft' => %w[submitted withdrawn],
    'submitted' => %w[zoning_check withdrawn],
    'zoning_check' => %w[plan_review zoning_hold denied withdrawn],
    'zoning_hold' => %w[plan_review denied withdrawn],
    'plan_review' => %w[fees_assessed corrections_required denied withdrawn],
    'corrections_required' => %w[plan_review withdrawn],
    'fees_assessed' => %w[issued withdrawn],
    'issued' => %w[expired],
    'denied' => [],
    'withdrawn' => [],
    'expired' => []
  }.freeze

  def self.transition!(application, to:, actor:, reason: nil, source_system: nil)
    new(application).transition!(to: to, actor: actor, reason: reason, source_system: source_system)
  end

  def initialize(application)
    @application = application
  end

  def transition!(to:, actor:, reason: nil, source_system: nil)
    from = @application.state

    raise InvalidTransition, "#{@application.reference} is #{from}" if @application.terminal?
    raise InvalidTransition, "#{from} -> #{to}" unless ALLOWED.fetch(from, []).include?(to)

    ActiveRecord::Base.transaction do
      @application.update!(state: to)
      record(from, to, actor, reason, source_system)
    end

    Rails.logger.info(
      "transition #{@application.reference} #{from}->#{to} actor=#{actor} " \
      "applicant=#{@application.applicant_name} <#{@application.applicant_email}> " \
      "phone=#{@application.applicant_phone} licence=#{@application.contractor_licence}"
    )

    dispatch_follow_on(to)
    @application
  end

  private

  def record(from, to, actor, reason, source_system)
    entry = @application.transitions.find_or_initialize_by(to_state: to)
    entry.assign_attributes(
      from_state: from,
      actor: actor,
      reason: reason,
      source_system: source_system
    )
    entry.save!
  end

  def dispatch_follow_on(to)
    case to
    when 'submitted'
      ZoningDispatchJob.perform_async(@application.id)
    when 'plan_review'
      ReviewSubmissionJob.perform_async(@application.id)
    end
  end
end
