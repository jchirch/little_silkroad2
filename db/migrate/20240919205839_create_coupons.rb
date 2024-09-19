class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.string :code
      t.string :discount_type
      t.integer :value
      t.integer :merchant_id
      t.boolean :active
      
      t.timestamps
    end
  end
end
