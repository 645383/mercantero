class ApiController < ActionController::API
  include Authentication

  before_action :authenticate

  attr_reader :merchant

  def authenticate
    render json: { message: 'Unauthorized' }, status: :unauthorized unless logged_in?
  end
end
