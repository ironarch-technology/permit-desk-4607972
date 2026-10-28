module Webhooks
  class ZoningController < ApplicationController
    skip_forgery_protection

    def create
      check = ZoningCheck.find_by(handle: params[:handle])
      return head :not_found if check.nil?

      ZoningResult.new(check.permit_application).apply(check, params[:result], params[:detail])

      head :ok
    end
  end
end
