class CreateMerchants < ActiveRecord::Migration[6.1]
  def change
    create_table :merchants do |t|
      t.string :name
      t.text :description
      t.string :email
      t.string :status

      t.timestamps
    end
  end
end
