class TransactionProcessor::Refund < TransactionProcessor::Base
  NOT_ALLOCATABLE_AMOUNT = 'Refunded amount is more than captured amount'

  def call
    @transaction = Transaction::Refund.create(params)
    validate

    # The status of the transaction must be error in case of validation
    # error, otherwise approved
    if errors?
      transaction.decline
    else
      transaction.approve
      # Transitions the Capture transaction to status refunded
      transaction.parent_transaction.refund
      transaction.parent_transaction.save
    end
    transaction.save
  end

  private

  def validate
    transaction.save
    errors << transaction.errors unless transaction.valid?
    errors << { 'base' => [NOT_ALLOCATABLE_AMOUNT] } unless transaction.amount_allocatable?
  end
end
