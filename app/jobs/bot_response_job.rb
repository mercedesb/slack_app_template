# background job for posting bot responses to Slack
class BotResponseJob < ApplicationJob
  queue_as :default

  def perform(args)
    text = args[:text]
    team_id = args[:team_id]
    channel = args[:channel]

    # TODO: take any necessary action and respond

    response = [] # array of Slack blocks
    slack_client = SlackChannelClient.new(team_id, channel)
    slack_client.post_message(response)
  end
end
