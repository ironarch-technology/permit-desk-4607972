Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  config.log_level = :info
  config.logger = ActiveSupport::Logger.new($stdout)

  config.hosts.clear
end
