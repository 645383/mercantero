class Processor::Authorize
  def initialize(transaction)
    @transaction = transaction
  end

  def call
    AuthorizeTransactionJob.perform_later(@transaction)
  end
end
