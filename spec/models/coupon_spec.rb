require "rails_helper"

RSpec.describe Coupon, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoices) }
  end

  describe 'validations' do
    it {should validate_presence_of(:name).with_message("Name is required")}
    it {should validate_presence_of(:code).with_message("Code is required")}
    it {should validate_uniqueness_of(:code).with_message("This coupon code already exists")}
    it {should validate_presence_of(:discount_type).with_message("Must be 'dollar' or 'percent'")}
    it {should validate_presence_of(:active).with_message("Status is required")}
  end

  describe 'active coupon limit' do
    it 'merchant may not have more than 5 active coupons' do
      merchant = Merchant.create!(name: "Kozey Group")
      coupon1 = Coupon.create!(name: 'Welcome Offer', code: 'TAKE10', discount_type: 'percent', value: 10, merchant_id: merchant.id, active: true)
      coupon2 = Coupon.create!(name: 'Summer Special', code: 'SUNSHINE20', discount_type: 'percent', value: 20, merchant_id: merchant.id, active: true)
      coupon3 = Coupon.create!(name: 'Holiday Sale', code: 'HOLIDAY50', discount_type: 'percent', value: 50, merchant_id: merchant.id, active: true)
      coupon4 = Coupon.create!(name: 'Free Money', code: 'FREE20', discount_type: 'dollar', value: 20, merchant_id: merchant.id, active: true)
      coupon5 = Coupon.create!(name: 'VIP Offer', code: 'VIP30', discount_type: 'dollar', value: 30, merchant_id: merchant.id, active: true)
      expect(Coupon.count).to eq(5)

      bad_coupon = Coupon.build(name: 'Over The Line', code: 'TOOMUCH10', discount_type: 'dollar', value: 10, merchant_id: merchant.id, active: true)
      expect(bad_coupon).not_to be_valid
      expect(bad_coupon.errors[:merchant]).to eq(["Merchant can only have a maximum of 5 active coupons at once."])
      expect(Coupon.count).to eq(5)
    end

    it 'merchant may have more coupons as long as less than 5 are active' do
      merchant = Merchant.create!(name: "Cozy Group")
      dud_coupon1 = Coupon.create!(name: 'Welcome Offer1', code: 'TAKE10', discount_type: 'percent', value: 10, merchant_id: merchant.id, active: false)
      dud_coupon2 = Coupon.create!(name: 'Welcome Offer2', code: 'TAKE20', discount_type: 'percent', value: 20, merchant_id: merchant.id, active: false)
      dud_coupon3 = Coupon.create!(name: 'Welcome Offer3', code: 'TAKE30', discount_type: 'percent', value: 30, merchant_id: merchant.id, active: false)
      dud_coupon4 = Coupon.create!(name: 'Welcome Offer4', code: 'TAKE40', discount_type: 'percent', value: 40, merchant_id: merchant.id, active: false)
      dud_coupon5 = Coupon.create!(name: 'Welcome Offer5', code: 'TAKE50', discount_type: 'percent', value: 50, merchant_id: merchant.id, active: false)
      active_coupon = Coupon.create!(name: 'Holiday Offer', code: 'WOW60', discount_type: 'percent', value: 60, merchant_id: merchant.id, active: true)

      expect(active_coupon).to be_valid
      expect(Coupon.count).to eq(6)
      expect(Coupon.where(merchant: merchant, active: true).count).to eq(1)
    end
  end

  describe '#sort_by_active' do
    it 'returns all active coupons for the specific merchant' do
      merchant = Merchant.create!(name: "Cozy Group")
      dud_coupon1 = Coupon.create!(name: 'Test Offer1', code: 'TAKE54', discount_type: 'percent', value: 10, merchant_id: merchant.id, active: false)
      dud_coupon2 = Coupon.create!(name: 'Test Offer2', code: 'TAKE53', discount_type: 'percent', value: 20, merchant_id: merchant.id, active: false)
      active_coupon = Coupon.create!(name: 'Test Offer Good', code: 'TAKE52', discount_type: 'percent', value: 60, merchant_id: merchant.id, active: true)

      active_coupons = Coupon.sort_by_active(merchant.id, true)
      expect(active_coupons).to eq([active_coupon])
    end

    it 'returns all inactive coupons for the specific merchant' do
      merchant = Merchant.create!(name: "Cozy Group")
      dud_coupon1 = Coupon.create!(name: 'Test Offer1', code: 'TAKE54', discount_type: 'percent', value: 10, merchant_id: merchant.id, active: false)
      dud_coupon2 = Coupon.create!(name: 'Test Offer2', code: 'TAKE53', discount_type: 'percent', value: 20, merchant_id: merchant.id, active: false)
      active_coupon = Coupon.create!(name: 'Test Offer Good', code: 'TAKE52', discount_type: 'percent', value: 60, merchant_id: merchant.id, active: true)

      inactive_coupons = Coupon.sort_by_active(merchant.id, false)
      expect(inactive_coupons).to eq([dud_coupon1, dud_coupon2])
    end
  end
end