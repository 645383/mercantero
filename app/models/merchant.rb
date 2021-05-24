class Merchant < ApplicationRecord
  has_secure_password

  has_many :transactions

  def active?
    status == 'active'
  end
end
