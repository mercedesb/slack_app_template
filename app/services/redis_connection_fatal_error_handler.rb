class RedisConnectionFatalErrorHandler
  def call(job, exception)
    return unless exception.is_a?(RedisHealthCheckFailedError)

    Honeybadger.notify(
      exception.cause,
      context: {
        context: {
          tags: "death_handler"
        },
        parameters: job,
        component: job["class"]
      }
    )
  end
end
