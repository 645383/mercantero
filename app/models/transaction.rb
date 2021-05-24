class Transaction < ApplicationRecord
  belongs_to :merchant
  has_many :transactions, foreign_key: 'parent_transaction_id'
end
