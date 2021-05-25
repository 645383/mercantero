class TransactionProcessor::Void < TransactionProcessor::Base
  def call
    @transaction = Transaction::Void.create(params)
    validate

    # The status of the transaction must be error in case of validation
    # error, otherwise approved
    if errors?
      transaction.decline
    else
      transaction.approve
      # Transitions the Authorize transaction to status voided
      transaction.parent_transaction.void
      transaction.parent_transaction.save
      transaction.parent_transaction = nil
    end
    transaction.save
  end

  private

  def validate
    transaction.save
    errors << transaction.errors unless transaction.valid?
  end
end
