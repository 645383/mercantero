class ApiController < ActionController::API
  include Authentication
  before_action :authorize

  def authorize
    render json: { message: 'Unauthorized' }, status: :unauthorized unless logged_in?
  end
end
