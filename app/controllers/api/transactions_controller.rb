class Api::TransactionsController < ApiController
  before_action :authorize

  def create
    transaction = CreateTransaction.new(transaction_params, @merchant).call

    if transaction.valid?
      render json: transaction.to_json
    else
      render json: transaction.errors, status: :unprocessable_entity
    end
  end

  private

  def authorize
    render json: { message: 'Merchant is not active' }, status: :unauthorized unless merchant.active?
  end

  def transaction_params
    params.require(:transaction).permit(:type, :amount, :uuid, :customer_phone, :customer_email, :notification_url)
  end
end
