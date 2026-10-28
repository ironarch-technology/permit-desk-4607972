module Types
  class QueryType < BaseObject
    field :my_applications, [ApplicationType], null: false,
          description: 'Applications belonging to the signed-in account.'

    field :application, ApplicationType, null: true do
      argument :reference, String
    end

    def my_applications
      context[:account].permit_applications.order(created_at: :desc)
    end

    def application(reference:)
      context[:account].permit_applications.find_by(reference: reference)
    end
  end
end
