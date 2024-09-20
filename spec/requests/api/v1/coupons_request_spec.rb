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

    it 'Can return one coupon' do
      get "/api/v1/coupons/#{@coupon2.id}"
      expect(response).to be_successful
      coupon = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(coupon[:id]).to eq(@coupon2.id.to_s)

      coupon = coupon[:attributes]

      expect(coupon[:name]).to eq(@coupon2.name)
      expect(coupon[:code]).to eq(@coupon2.code)
      expect(coupon[:discount_type]).to eq(@coupon2.discount_type)
      expect(coupon[:value]).to eq(@coupon2.value)
      expect(coupon[:merchant_id]).to eq(@coupon2.merchant_id)
      expect(coupon[:active]).to eq(@coupon2.active)
    end

    it 'Can create a coupon' do
      expect(Coupon.count).to eq(6)

      new_coupon_params = {name: 'Spooktacular Savings', code: '50Ween', discount_type: 'percent', value: 50, merchant_id: @hot_topic.id, active: true}

      post '/api/v1/coupons', params: {coupon: new_coupon_params}, as: :json

      expect(response).to be_successful
      expect(Coupon.count).to eq(7)
      new_coupon = Coupon.last

      expect(new_coupon.name).to eq(new_coupon_params[:name])
      expect(new_coupon.code).to eq(new_coupon_params[:code])
      expect(new_coupon.discount_type).to eq(new_coupon_params[:discount_type])
      expect(new_coupon.value).to eq(new_coupon_params[:value])
      expect(new_coupon.merchant_id).to eq(new_coupon_params[:merchant_id])
      expect(new_coupon.active).to eq(new_coupon_params[:active])
    end

    it 'Can update active status attribute' do
      new_coupon_status_params = {active: false}
      expect(@coupon1.active).to be(true)

      patch "/api/v1/coupons/#{@coupon1.id}", params: {coupon: new_coupon_status_params}, as: :json
      @coupon1.reload
      expect(@coupon1.active).to be(false)
    end
  end
end