class ApplicationController < ActionController::API
  def index
    render status: 200, json: {}
  end
end
