module SlackVerification
  TIMESTAMP_HEADER = 'X-Slack-Request-Timestamp'.freeze
  SIGNATURE_HEADER = 'X-Slack-Signature'.freeze
  FIVE_MINUTES = 300
  VERSION = 'v0'.freeze

  def verify_request
    request_body = request.body.read
    timestamp = request.headers[TIMESTAMP_HEADER]
    render status: :forbidden, json: {} if Time.now.to_i - timestamp.to_i > FIVE_MINUTES # could be replay attack

    signing_basestring = "#{VERSION}:#{timestamp}:#{request_body}"
    hashed_basestring = OpenSSL::HMAC.hexdigest('sha256', ENV.fetch('SIGNING_SECRET'), signing_basestring)

    generated_signature = "#{VERSION}=#{hashed_basestring}"
    slack_signature = request.headers[SIGNATURE_HEADER]
    OpenSSL.secure_compare(generated_signature, slack_signature)
  end
end
