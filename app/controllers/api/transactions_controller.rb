class Api::TransactionsController < ApiController
  def create
    transaction = CreateTransaction.new(transaction_params).call
    if transaction.errors?
      render transaction.errors, status: :unprocessable_entity
    else
      render transaction
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:type, :amount, :uuid, :customer_phone, :customer_email, :notification_url)
  end
end
