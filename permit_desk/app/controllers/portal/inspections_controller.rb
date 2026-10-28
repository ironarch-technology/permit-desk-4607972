module Portal
  class InspectionsController < ApplicationController
    before_action :require_session
    before_action :load_application

    TYPES = %w[footing framing final].freeze

    def show
      @inspection_type = params[:inspection_type].presence_in(TYPES) || TYPES.first
      outcome = client.slots(inspection_type: @inspection_type, district: @application.parcel&.district)

      if outcome.ok?
        @slots = outcome.data
      else
        @slots = []
        @notice = 'The scheduler is not answering at the moment. Try again shortly.'
      end

      @bookings = @application.inspection_bookings.order(created_at: :desc)
    end

    def create
      outcome = client.book(
        slot_id: params[:slot_id],
        reference: @application.reference,
        inspection_type: params[:inspection_type]
      )

      if outcome.ok?
        @application.inspection_bookings.create!(
          slot_id: params[:slot_id],
          inspection_type: params[:inspection_type],
          scheduled_for: outcome.data['scheduled_for'],
          status: 'confirmed'
        )
        redirect_to portal_inspections_path(@application.reference)
      elsif outcome.error == 'slot_taken'
        @inspection_type = params[:inspection_type]
        @slots = outcome.data
        @bookings = @application.inspection_bookings.order(created_at: :desc)
        @notice = 'Somebody took that slot while you were choosing. Here are the ones still open.'
        render :show, status: :ok
      else
        redirect_to portal_inspections_path(@application.reference),
                    alert: 'The scheduler could not take that booking.'
      end
    end

    private

    def client
      @client ||= Clients::SchedulingClient.new
    end

    def load_application
      @application = current_account.permit_applications.find_by!(reference: params[:reference])
    end
  end
end
