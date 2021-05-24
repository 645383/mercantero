class Transaction < ApplicationRecord
  belongs_to :merchant
  belongs_to :parent_transaction, class_name: 'Transaction', optional: true
  has_many :transactions, foreign_key: 'parent_transaction_id'
end
