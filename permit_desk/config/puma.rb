threads_count = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
threads threads_count, threads_count

environment ENV.fetch('RAILS_ENV', 'development')

bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"
