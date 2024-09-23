class Merchant < ApplicationRecord
	has_many :coupons
	has_many :items, dependent: :destroy
	has_many :invoices, dependent: :destroy
  has_many :customers, through: :invoices
	has_many :invoice_items, through: :invoices

	validates :name, presence: { message: "is required to create new Merchant" }
	validates :name, uniqueness: { message: "This merchant has already been created" }
	

	def self.sort_by_age(sorted)
		if sorted == "age"
			order(created_at: :desc)
		else
			all
		end
	end

	def self.status_returned(status)
		if status == "returned"
			joins(:items, :invoices).where(invoices: {status: 'returned'}).distinct
		else
			all
		end
	end
	
	def self.count_items(count)
		if count == "true"
			joins(:items).select('merchants.*, COUNT(items.id) AS item_count')
			.group('merchants.id').order(:id)
		else
			all
		end
	end

	def self.search(param)
		self.where("name ILIKE ?", "%#{param}%").order(:name).first
	end

	def total_cost(invoice, coupon = nil)
		cost = invoice.invoice_items.joins(:item).where(items: {merchant_id: self.id}).sum('invoice_items.quantity * invoice_items.unit_price')
		if coupon && coupon.merchant_id == self.id
			if coupon.discount_type == 'dollar'
				[cost - coupon.value, 0].max
			elsif coupon.discount_type == 'percent'
				cost - (cost * (coupon.value.to_f / 100))
			else
				cost
			end
		else
			cost
		end
	end

	def coupon_counter
		coupons.count
	end

	def invoice_coupon_counter
		invoices.where.not(coupon_id: nil).count
	end
end