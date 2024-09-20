class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :code, uniqueness: {message: "This coupon code already exists"}
end