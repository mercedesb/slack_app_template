# Client for Slack API for auth-related requests
class SlackAuthClient
  def oauth_access(code)
    body_params = {
      code:
    }

    auth = { username: ENV.fetch('CLIENT_ID'), password: ENV.fetch('CLIENT_SECRET') }

    response = HTTParty.post("#{ENV.fetch('NOTIFICATION_BASE_URL')}/oauth.v2.access",
                             headers: { "Content-Type": "application/x-www-form-urlencoded" },
                             basic_auth: auth,
                             body: body_params)
    return response if response['ok']

    Rails.logger.error(response['error'])
    {}
  end
end
