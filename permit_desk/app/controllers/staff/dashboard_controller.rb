module Staff
  class DashboardController < ApplicationController
    before_action :require_session
    before_action :require_staff

    def show
      @counts = PermitApplication.group(:state).count
      @recent = PermitApplication.order(created_at: :desc).limit(10)
    end
  end
end
