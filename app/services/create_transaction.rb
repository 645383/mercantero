class CreateTransaction
  def initialize(params, merchant)
    @params = params
    @merchant = merchant
  end

  def call
    processor_name = "TransactionProcessor::#{@params.delete(:type).camelize}"
    processor = processor_name.constantize.new(@params, @merchant)
    processor.call
    processor
  end
end
