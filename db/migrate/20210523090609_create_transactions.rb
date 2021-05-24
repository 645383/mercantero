class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.string :type
      t.string :uuid
      t.decimal :amount, precision: 10, scale: 2
      t.string :status
      t.string :customer_email
      t.string :customer_phone
      t.string :notification_url
      t.references :merchant
      t.references :parent_transaction

      t.timestamps
    end
  end
end
