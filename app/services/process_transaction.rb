class ProcessTransaction
  def initialize(transaction)
    @transaction = transaction
  end

  def call
    processor_name = "Processor::#{@transaction.type.demodulize}"
    return unless Object.const_defined?(processor_name)

    processor_name.constantize.new(@transaction).call
  end
end
