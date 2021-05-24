class TransactionProcessor::Authorize < TransactionProcessor::Base
  def call
    @transaction = Transaction::Authorize.create(params)
    AuthorizeTransactionJob.perform_later(@transaction)
  end
end
