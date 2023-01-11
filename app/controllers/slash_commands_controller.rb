# Handles incoming requests from a slash command you configure
class SlashCommandsController < ApplicationController
  include SlackVerification

  before_action :verify_request
  before_action :override_slack_response_format

  def index
    return unless valid_command?

    # TODO: handle your command and return json with your response
  end

  private

  def command_params
    params.permit(:command, :team_id, :channel_id, :text)
  end

  def valid_command?
    # TODO: check that the command is a valid command your app responds to
    command_params[:command]
  end

  def override_slack_response_format
    request.format = :json
  end
end
