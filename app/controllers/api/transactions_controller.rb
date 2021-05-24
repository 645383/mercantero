class Api::TransactionsController < ApiController
  before_action :authorize

  # rescue_from AASM::InvalidTransition, with: :render_transition_error

  def create
    result = CreateTransaction.new(transaction_params, @merchant).call

    if result.errors?
      render json: { errors: result.errors }, status: :unprocessable_entity
    else
      render json: result.transaction.to_json, status: :created
    end
  end

  private

  def authorize
    render json: { message: 'Merchant is not active' }, status: :unauthorized unless merchant.active?
  end

  def transaction_params
    params.require(:transaction).permit(:type, :amount, :uuid, :customer_phone, :customer_email, :notification_url, :parent_transaction_id)
  end

  def render_transition_error(error)
    render json: { errors: [error.to_s] }, status: :unprocessable_entity
  end
end
