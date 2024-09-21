class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :name, presence: { message: "Name is required"}
  validates :code, presence: { message: "Code is required"}
  validates :code, uniqueness: {message: "This coupon code already exists"}
  validates :discount_type, presence: {message: "Must be 'dollar' or 'percent'"}
  validates :active, presence: {message: "Status is required"}
end