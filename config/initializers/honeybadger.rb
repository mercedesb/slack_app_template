if defined?(Honeybadger)
  Honeybadger.configure do |config|
    config.sidekiq.attempt_threshold = 1
  end
end
