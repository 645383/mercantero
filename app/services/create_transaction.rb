class CreateTransaction
  def initialize(params, merchant)
    @params = params
    @merchant = merchant
  end

  def call
    type = "Transaction::#{@params.delete(:type).camelize}".constantize
    type.create(@params)
  end
end
