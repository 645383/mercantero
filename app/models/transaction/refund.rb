class Transaction::Refund < Transaction
  include Transactions::StateMachine::Refund

  belongs_to :parent_transaction, class_name: 'Transaction'

  validate :parent_referable

  def amount_allocatable?
    amount <= (parent_transaction.amount - related_refunds_sum)
  end

  private

  def parent_referable
    # Can refer only to an approved or refunded Capture transaction
    return if parent_transaction.approved? || parent_transaction.refunded?

    errors.add(:parent_transaction, 'Parent transaction should have status approved or refunded')
  end

  def related_refunds_sum
    # Should allow more than one Refund transaction to be submitted
    # as long as the total refunded amount is less than or equal to the
    # captured amount
    parent_transaction.transactions
      .where(type: 'Transaction::Refund', status: 'approved').sum(:amount)
  end
end
