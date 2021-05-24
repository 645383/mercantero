class Transaction::Refund < Transaction
  include Transactions::StateMachine::Refund

  belongs_to :parent_transaction, class_name: 'Transaction'

  validate :parent_referable

  def amount_allocatable?
    amount <= (parent_transaction.amount - related_refunds_sum)
  end

  private

  def parent_referable
    return if parent_transaction.approved? || parent_transaction.refunded?

    errors.add(:parent_transaction, 'Parent transaction should have status approved or refunded')
  end

  def related_refunds_sum
    parent_transaction.transactions
      .where(type: 'Transaction::Refund', status: 'approved').sum(:amount)
  end
end
