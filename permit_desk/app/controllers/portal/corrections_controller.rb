module Portal
  class CorrectionsController < ApplicationController
    before_action :require_session
    before_action :load_application

    def show
      @items = @application.outstanding_corrections
    end

    def create
      responses = params.fetch(:responses, {})
      items = @application.outstanding_corrections.index_by { |item| item.id.to_s }

      @missing = items.keys.reject { |id| responses[id].present? }

      if @missing.any?
        @items = @application.outstanding_corrections
        render :show, status: :unprocessable_entity
        return
      end

      items.each do |id, item|
        item.correction_responses.create!(body: responses[id])
      end

      Lifecycle.transition!(@application, to: 'plan_review', actor: current_account.name,
                                          reason: "responses to cycle #{@application.current_cycle}")
      redirect_to portal_application_path(@application.reference)
    end

    private

    def load_application
      @application = current_account.permit_applications.find_by!(reference: params[:reference])
    end
  end
end
