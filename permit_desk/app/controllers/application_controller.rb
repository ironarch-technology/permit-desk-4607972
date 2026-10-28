class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_account, :signed_in?

  private

  def current_account
    return @current_account if defined?(@current_account)

    account_id = SessionToken.account_id(cookies[:portal_session])
    @current_account = account_id ? Account.find_by(id: account_id) : nil
  end

  def signed_in?
    current_account.present?
  end

  def require_session
    return if signed_in?

    redirect_to portal_sign_in_path
  end

  def require_staff
    return if current_account&.staff?

    render 'shared/forbidden', status: :forbidden
  end

  def session_expires_at
    SessionToken.expires_at(cookies[:portal_session])
  end
  helper_method :session_expires_at
end
