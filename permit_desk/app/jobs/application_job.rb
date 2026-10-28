class ApplicationJob
  include Sidekiq::Job

  sidekiq_options queue: 'orchestration', retry: 5
end
