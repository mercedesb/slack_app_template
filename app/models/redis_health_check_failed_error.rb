# frozen_string_literal: true

# custom error used for circuit breaker in jobs for redis connection errors
class RedisHealthCheckFailedError < StandardError; end
