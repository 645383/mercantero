class AddPasswordToMerchant < ActiveRecord::Migration[6.1]
  def change
    add_column :merchants, :password, :string
    add_column :merchants, :password_digest, :string
  end
end
