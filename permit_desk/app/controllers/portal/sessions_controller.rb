module Portal
  class SessionsController < ApplicationController
    def new
      redirect_to portal_applications_path if signed_in?
    end

    def create
      account = Account.find_by('lower(email) = ?', params[:email].to_s.strip.downcase)

      if account&.authenticate(params[:password])
        cookies[:portal_session] = {
          value: SessionToken.issue(account),
          httponly: true,
          same_site: :lax
        }
        redirect_to portal_applications_path
      else
        @error = 'We could not match that email address and password.'
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      cookies.delete(:portal_session)
      redirect_to portal_sign_in_path
    end
  end
end
