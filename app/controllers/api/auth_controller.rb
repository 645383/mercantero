class Api::AuthController < ApiController
  skip_before_action :authorize, only: %i[login]

  def login
    @merchant = Merchant.find_by(email: merchant_params[:email])

    if @merchant && @merchant.authenticate(merchant_params[:password])
      token = encode_token({ merchant_id: @merchant.id })
      render json: { merchant: @merchant, token: token }
    else
      render json: { error: "Invalid email or password" }
    end
  end

  private

  def merchant_params
    params.permit(:email, :password)
  end
end
