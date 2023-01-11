class OauthController < ActionController::API
  def index
    request_params = {
      client_id: ENV.fetch('CLIENT_ID'),
      scope: 'TODO: add your needed scopes here'
    }

    redirect_to URI::HTTPS.build(host: "slack.com", path: "/oauth/v2/authorize", query: request_params.to_query).to_s,
                allow_other_host: true
  end

  def callback
    response = SlackAuthClient.new.oauth_access(params[:code])
    return unless response['team']

    slack_id = response['team']['id']
    name = response['team']['name']
    access_token = response['access_token']
    bot_user_id = response['bot_user_id']

    team = Team.find_or_initialize_by(slack_id:)
    team.update!(name:, access_token:, bot_user_id:)
    render status: :ok # TODO: what to render?
  end
end
