class Api::TransactionsController < ApiController
  def create
    transaction = CreateTransaction.new(transaction_params, @merchant).call

    if transaction.valid?
      render json: transaction.to_json
    else
      render transaction.errors, status: :unprocessable_entity
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:type, :amount, :uuid, :customer_phone, :customer_email, :notification_url)
  end
end
