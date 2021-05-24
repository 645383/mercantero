class TransactionProcessor::Void < TransactionProcessor::Base
  def call
    @transaction = Transaction::Void.create(params)
    validate

    if errors?
      transaction.decline
    else
      transaction.approve
      transaction.parent_transaction.void
    end
  end

  private

  def validate
    transaction.save
    errors << transaction.errors unless transaction.valid?
  end
end
