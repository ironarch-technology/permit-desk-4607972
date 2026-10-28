# Applies a zoning outcome to an application, whichever way it arrived.
# The webhook and the read-back can land at the same moment, so the check is
# claimed with a conditional update and only the winner moves the application.
class ZoningResult
  def initialize(application)
    @application = application
  end

  def apply(check, result, detail = nil)
    claimed = ZoningCheck.where(id: check.id, settled_at: nil)
                         .update_all(result: result, detail: detail, settled_at: Time.current)
    return if claimed.zero?

    application = @application.reload
    return unless application.state == 'zoning_check'

    case result
    when 'pass'
      Lifecycle.transition!(application, to: 'plan_review', actor: 'system',
                                         source_system: 'zoning', reason: 'zoning cleared')
    when 'fail'
      Lifecycle.transition!(application, to: 'denied', actor: 'system',
                                         source_system: 'zoning', reason: detail || 'zoning refused the scope')
    when 'indeterminate'
      Lifecycle.transition!(application, to: 'zoning_hold', actor: 'system',
                                         source_system: 'zoning', reason: detail || 'parcel records conflict')
    end
  end
end
