class TransactionProcessor::Capture < TransactionProcessor::Base
  NOT_ALLOCATABLE_AMOUNT = 'Captured amount is more than authorized amount'

  def call
    @transaction = Transaction::Capture.create(params)
    validate

    if errors?
      transaction.decline
    else
      transaction.approve
      transaction.parent_transaction.capture
    end
  end

  private

  def validate
    transaction.save
    errors << transaction.errors unless transaction.valid?
    errors << { 'base' => [NOT_ALLOCATABLE_AMOUNT] } unless transaction.amount_allocatable?
  end
end
