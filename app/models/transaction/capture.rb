class Transaction::Capture < Transaction
  include Transactions::StateMachine::Capture

  belongs_to :parent_transaction, class_name: 'Transaction'

  validate :parent_referable

  def amount_allocatable?
    amount <= (parent_transaction.amount - related_captures_sum)
  end

  private

  def parent_referable
    # Can refer only to an approved or captured Authorize transaction
    return if parent_transaction.approved? || parent_transaction.captured?

    errors.add(:parent_transaction, 'Parent transaction should have status approved or captured')
  end

  def related_captures_sum
    # Should allow more than one Capture transaction to be submitted
    # as long as the total captured amount is less than or equal to the
    # authorized amount
    parent_transaction.transactions
      .where(type: 'Transaction::Capture', status: 'approved').sum(:amount)
  end
end
