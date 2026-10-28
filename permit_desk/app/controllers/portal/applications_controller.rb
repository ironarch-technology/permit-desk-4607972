module Portal
  class ApplicationsController < ApplicationController
    before_action :require_session
    before_action :load_application, only: %i[show submit withdraw]

    def index
      @applications = current_account.permit_applications.order(created_at: :desc)
    end

    def new
      @application = current_account.permit_applications.new(work_type: 'residential_remodel')
      @errors = {}
    end

    def create
      @application = current_account.permit_applications.new(draft_attributes)
      @application.parcel = Parcel.resolve(params[:parcel_address])
      @application.submission_key = params[:submission_key]

      @errors = SubmissionValidator.new(@application, parcel_address: params[:parcel_address]).call.errors

      if @errors.any?
        render :new, status: :unprocessable_entity
        return
      end

      @application.save!
      redirect_to portal_application_path(@application.reference)
    end

    def show
      @transitions = @application.transitions.order(:created_at)
      @quote = @application.current_quote
    end

    def submit
      @application.update!(submitted_at: Time.current)
      Lifecycle.transition!(@application, to: 'submitted', actor: current_account.name, reason: 'submitted on the portal')
      redirect_to portal_application_path(@application.reference)
    rescue Lifecycle::InvalidTransition
      redirect_to portal_application_path(@application.reference), alert: 'That application has already been submitted.'
    end

    def withdraw
      Lifecycle.transition!(@application, to: 'withdrawn', actor: current_account.name, reason: params[:reason])
      redirect_to portal_applications_path
    rescue Lifecycle::InvalidTransition
      redirect_to portal_application_path(@application.reference), alert: 'That application can no longer be withdrawn.'
    end

    private

    def load_application
      @application = current_account.permit_applications.find_by!(reference: params[:reference])
    end

    def draft_attributes
      {
        work_type: params[:work_type],
        scope_narrative: params[:scope_narrative],
        valuation_cents: (params[:valuation].to_f * 100).round,
        applicant_name: params[:applicant_name],
        applicant_email: params[:applicant_email],
        applicant_phone: params[:applicant_phone],
        contractor_licence: params[:contractor_licence].presence,
        contractor_licence_expiry: params[:contractor_licence_expiry].presence
      }
    end
  end
end
