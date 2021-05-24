class TransactionProcessor::Base
  attr_reader :params, :merchant, :transaction
  attr_accessor :errors

  def initialize(params, merchant)
    @params = params.merge(merchant_id: merchant.id)
    @merchant = merchant
    @errors = []
  end

  def call
    raise NotImplementedError
  end

  def errors?
    errors.present?
  end
end