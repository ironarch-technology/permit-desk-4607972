module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    private

    def account
      context[:account]
    end

    def find_application(reference)
      account.permit_applications.find_by(reference: reference)
    end
  end
end
