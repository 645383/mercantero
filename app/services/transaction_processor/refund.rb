class TransactionProcessor::Refund < TransactionProcessor::Base
  NOT_ALLOCATABLE_AMOUNT = 'Refunded amount is more than captured amount'

  def call
    @transaction = Transaction::Refund.create(params)
    validate

    if errors?
      transaction.decline
    else
      transaction.approve
      transaction.parent_transaction.refund
    end
  end

  private

  def validate
    transaction.save
    errors << transaction.errors unless transaction.valid?
    errors << { 'base' => [NOT_ALLOCATABLE_AMOUNT] } unless transaction.amount_allocatable?
  end
end
