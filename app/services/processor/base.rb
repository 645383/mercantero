class Processor::Base
  def initialize(transaction)
    @transaction = transaction
  end

  def call
    raise NotImplementedError
  end
end