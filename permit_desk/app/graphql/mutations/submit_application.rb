module Mutations
  class SubmitApplication < BaseMutation
    argument :reference, String
    argument :submission_key, String, required: false

    field :application, Types::ApplicationType, null: true
    field :errors, [String], null: false

    def resolve(reference:, submission_key: nil)
      application = find_application(reference)
      return { application: nil, errors: ['Not found'] } if application.nil?

      application.update!(submitted_at: Time.current, submission_key: submission_key)
      Lifecycle.transition!(application, to: 'submitted', actor: account.name, reason: 'submitted from the portal')

      { application: application, errors: [] }
    rescue Lifecycle::InvalidTransition => e
      { application: application, errors: [e.message] }
    end
  end
end
