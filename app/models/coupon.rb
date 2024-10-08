class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :name, presence: { message: "Name is required"}
  validates :code, presence: { message: "Code is required"}
  validates :code, uniqueness: {message: "This coupon code already exists"}
  validates :discount_type, presence: {message: "Must be 'dollar' or 'percent'"}
  validates :active, inclusion: { in: [true, false], message: "Status is required"}
  validate :five_coupon_limit, on: :create

  def five_coupon_limit
    if active && merchant.coupons.where(active: true).count >= 5
      errors.add(:merchant, "Merchant can only have a maximum of 5 active coupons at once.")
    end
  end

  # def self.sort_by_active(status)
  #   if status == true
  #     Coupon.where("active = true")
  #   elsif status == false
  #     Coupon.where("active = false")
  #   else
  #     all
  #   end
  # end

  def self.sort_by_active(merchant_id, status)
    where(merchant_id: merchant_id, active: status)
  end
end