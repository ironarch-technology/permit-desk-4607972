module Staff
  class SearchesController < ApplicationController
    before_action :require_session

    PER_PAGE = 25

    def show
      @page = [params[:page].to_i, 1].max
      @results = filtered.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
      @total = filtered.count
    end

    private

    def filtered
      scope = PermitApplication.includes(:parcel, :account).order(created_at: :desc)
      scope = scope.where(state: params[:state]) if params[:state].present?
      if params[:parcel].present?
        scope = scope.joins(:parcel).where('parcels.address ILIKE ?', "%#{Parcel.sanitize_sql_like(params[:parcel])}%")
      end
      if params[:applicant].present?
        scope = scope.where('permit_applications.applicant_name ILIKE ?',
                            "%#{PermitApplication.sanitize_sql_like(params[:applicant])}%")
      end
      scope = scope.where('permit_applications.created_at >= ?', params[:from]) if params[:from].present?
      scope = scope.where('permit_applications.created_at <= ?', params[:to]) if params[:to].present?
      scope
    end
  end
end
