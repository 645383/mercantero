module Authentication
  extend ActiveSupport::Concern

  def encode_token(payload)
    JWT.encode(payload, Rails.configuration.x.jwt_secret)
  end

  def logged_in?
    !!logged_in_merchant
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

  def auth_header
    request.headers['Authorization']
  end

  def logged_in_merchant
    @merchant ||= Merchant.find(decoded_token[0]['merchant_id']) if decoded_token
  end
end