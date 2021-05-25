class Transaction::Void < Transaction
  include Transactions::StateMachine::Void

  belongs_to :parent_transaction, class_name: 'Transaction::Authorize', optional: true

  validate :parent_referable

  private

  def parent_referable
    # Can refer only to an approved Authorize transaction
    return if parent_transaction.nil? || parent_transaction.approved?

    errors.add(:parent_transaction, 'Parent transaction should have status approved')
  end
end
