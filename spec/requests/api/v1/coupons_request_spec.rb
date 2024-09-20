require 'rails_helper'

RSpec.describe 'Coupon Endpoints' do
  before (:each) do
    @macho_man = Merchant.create!(name: "Randy Savage")
    @kozey_group = Merchant.create!(name: "Kozey Group")
    @hot_topic = Merchant.create!(name: "Hot Topic")

    @coupon1 = Coupon.create!(name: 'Welcome Offer', code: 'TAKE10', discount_type: 'percent', value: 10, merchant_id: @macho_man.id, active: true)
    @coupon2 = Coupon.create!(name: 'Summer Special', code: 'SUNSHINE20', discount_type: 'percent', value: 20, merchant_id: @macho_man.id, active: true)
    @coupon3 = Coupon.create!(name: 'Holiday Sale', code: 'HOLIDAY50', discount_type: 'percent', value: 50, merchant_id: @macho_man.id, active: false)
    @coupon4 = Coupon.create!(name: 'Free Money', code: 'FREE20', discount_type: 'dollar', value: 20, merchant_id: @macho_man.id, active: true)
    @coupon5 = Coupon.create!(name: 'VIP Offer', code: 'VIP30', discount_type: 'dollar', value: 30, merchant_id: @macho_man.id, active: true)
    @coupon6 = Coupon.create!(name: 'Black Friday', code: 'BF40', discount_type: 'percent', value: 40, merchant_id: @macho_man.id, active: false)
  end

  describe 'HTTP Methods' do
    it 'Can return all coupons' do
      get '/api/v1/coupons'
      expect(response).to be_successful
      # require 'pry'; binding.pry
      coupons = JSON.parse(response.body, symbolize_names: true)[:data]

      coupons.each do |coupon|

        expect(coupon).to have_key(:id)
        expect(coupon[:id]).to be_a(String)

        expect(coupon).to have_key(:type)
        expect(coupon[:type]).to eq('coupon')

        coupon = coupon[:attributes]

        expect(coupon).to have_key(:name)
        expect(coupon[:name]).to be_a(String)

        expect(coupon).to have_key(:code)
        expect(coupon[:code]).to be_a(String)

        expect(coupon).to have_key(:discount_type)
        expect(coupon[:discount_type]).to be_a(String)

        expect(coupon).to have_key(:value)
        expect(coupon[:value]).to be_an(Integer)

        expect(coupon).to have_key(:merchant_id)
        expect(coupon[:merchant_id]).to be_a(Integer)

        expect(coupon).to have_key(:active)
        expect(coupon[:active]).to be_in([true, false])
      end

      
    end
  end
end