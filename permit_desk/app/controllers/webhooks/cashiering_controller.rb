module Webhooks
  class CashieringController < ApplicationController
    skip_forgery_protection

    def create
      application = PermitApplication.find_by(reference: params[:reference])
      return head :not_found if application.nil?
      return head :ok unless params[:status] == 'captured'

      Issuance.call(
        application,
        capture_reference: params[:capture_reference],
        amount_cents: params[:amount_cents].to_i
      )

      head :ok
    end
  end
end
