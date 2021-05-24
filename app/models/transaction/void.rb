class Transaction::Void < Transaction
  include Transactions::StateMachine::Void

  belongs_to :parent_transaction, class_name: 'Transaction::Authorize'

  validate :parent_referable

  private

  def parent_referable
    return if parent_transaction.approved?

    errors.add(:parent_transaction, 'Parent transaction should have status approved')
  end
end
