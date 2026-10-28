module Types
  class MutationType < BaseObject
    field :initiate_payment, mutation: Mutations::InitiatePayment
    field :submit_application, mutation: Mutations::SubmitApplication
  end
end
