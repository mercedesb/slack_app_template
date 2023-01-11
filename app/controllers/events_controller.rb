class EventsController < ApplicationController
  include SlackVerification

  def incoming
    if params[:type] == "url_verification"
      handle_challenge
    else
      verify_request
      handle_event
    end
  end

  private

  def handle_challenge
    # deprecated but according to their docs it's still the way to verify this webhook
    if params[:token] == ENV.fetch('VERIFICATION_TOKEN')
      render json: { "challenge": params[:challenge] }
    else
      render status: :forbidden
    end
  end

  def handle_event
    # TODO: handle the various events your app will respond to using event_type
    render status: :ok, json: {}
  end

  def event_params
    params.permit(:team_id, :event_time, event: [:type, :user, :item_user, :text, :channel, { item: %i[type channel ts] }])
  end

  def event_type
    event_params[:event][:type]
  end

  def team_id
    event_params[:team_id]
  end
end
