class Merchant < ApplicationRecord
  belongs_to :role
  has_many :transactions

end
