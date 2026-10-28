class GraphqlController < ApplicationController
  before_action :require_session

  def execute
    result = PermitDeskSchema.execute(
      params[:query],
      variables: params[:variables] || {},
      operation_name: params[:operationName],
      context: { account: current_account }
    )
    render json: result
  rescue GraphQL::ExecutionError => e
    render json: { errors: [{ message: e.message }] }, status: :unprocessable_entity
  end
end
