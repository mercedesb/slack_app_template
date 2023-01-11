# Client for Slack API for requests that require team/channel info
class SlackChannelClient
  SLACK_RESPONSE_LIMIT = 100

  def initialize(team_id, channel)
    @team = Team.find_by!(slack_id: team_id)
    @channel = channel
  end

  def members
    query_params = {
      limit: SLACK_RESPONSE_LIMIT,
      channel:
    }
    user_ids = []
    cursor = nil

    loop do
      query_params[:cursor] = cursor if cursor.present?

      response = HTTParty.get("#{ENV.fetch('NOTIFICATION_BASE_URL')}/conversations.members",
                              headers: { 'Authorization': "Bearer #{team.access_token}",
                                         "Content-Type": "application/json" },
                              query: query_params)

      Rails.logger.error(response['error']) unless response['ok']

      user_ids += response['members'] || []
      cursor = response.try(:[], 'response_metadata').try(:[], 'next_cursor')

      break if cursor.blank?
    end

    user_ids
  end

  def user_info(user_id)
    query_params = {
      user: user_id
    }

    response = HTTParty.get("#{ENV.fetch('NOTIFICATION_BASE_URL')}/users.info",
                            headers: { 'Authorization': "Bearer #{team.access_token}",
                                       "Content-Type": "application/json" },
                            query: query_params)
    return response['user'] if response['ok']

    Rails.logger.error(response['error'])
    {}
  end

  def post_message(blocks)
    body_params = {
      channel:,
      blocks:
    }
    response = HTTParty.post("#{ENV.fetch('NOTIFICATION_BASE_URL')}/chat.postMessage",
                             headers: { 'Authorization': "Bearer #{team.access_token}",
                                        "Content-Type": "application/json" },
                             body: body_params.to_json)

    Rails.logger.error(response['error']) unless response['ok']
    response['ok']
  end

  private

  attr_reader :team, :channel
end
