class CreateTransaction
  def initialize(params, merchant)
    @params = params
    @merchant = merchant
  end

  def call
    transaction = create
    post_process(transaction)
    transaction
  end

  private

  def create
    type = "Transaction::#{@params.delete(:type).camelize}".constantize
    type.create(@params.merge(merchant_id: @merchant.id))
  end

  def post_process(transaction)
    ProcessTransaction.new(transaction).call
  end
end
