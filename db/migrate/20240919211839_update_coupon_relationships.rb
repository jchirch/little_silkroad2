class UpdateCouponRelationships < ActiveRecord::Migration[7.1]
  def change
    add_index :coupons, :merchant_id
    add_foreign_key :coupons, :merchants
  end
end