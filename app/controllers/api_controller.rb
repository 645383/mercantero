class ApiController < ActionController::API
  before_action :authorize

  def authorize
    render json: { message: 'Unauthorized' }, status: :unauthorized unless logged_in?
  end

  def encode_token(payload)
    JWT.encode(payload, Rails.configuration.x.jwt_secret)
  end

  def auth_header
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      begin
        JWT.decode(token, Rails.configuration.x.jwt_secret)
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def logged_in_merchant
    @merchant = Merchant.find(decoded_token[0]['merchant_id']) if decoded_token
  end

  def logged_in?
    !!@merchant
  end
end
